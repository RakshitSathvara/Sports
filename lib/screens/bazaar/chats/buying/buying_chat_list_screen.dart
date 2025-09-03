import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chat_notification_service.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/model/chat_list_models.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/model/chat_list_response_model.dart' as chat_model;
import 'package:oqdo_mobile_app/screens/bazaar/chats/model/equipment_chat_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/socket_service.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/viewmodel/chat_view_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'dart:convert';

import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:provider/provider.dart';

class BuyingChatListScreen extends StatefulWidget {
  const BuyingChatListScreen({super.key});

  @override
  State<BuyingChatListScreen> createState() => BuyingChatListScreenState();
}

class BuyingChatListScreenState extends State<BuyingChatListScreen> with AutomaticKeepAliveClientMixin {
  final List<chat_model.ChatItem> _chatList = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _pageStart = 0;
  final int _resultPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // Socket service reference
  final BuyingSocketService _socketService = BuyingSocketService();
  bool _isConnected = false;
  late StreamSubscription _socketSubscription;
  late StreamSubscription _connectionStatusSubscription;
  late ChatNotificationService _notificationService;

  @override
  bool get wantKeepAlive => true; // Keep state when tab is not visible

  @override
  void initState() {
    super.initState();
    _notificationService = ChatNotificationService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchChatList();
    });
    _scrollController.addListener(_scrollListener);
    _setupSocketConnection();
  }

  @override
  void dispose() {
    _socketSubscription.cancel();
    _connectionStatusSubscription.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading && _hasMoreData) {
      _fetchChatList();
    }
  }

  // Public method for refreshing data
  void refreshData() {
    _refreshData();
  }

  Future<void> _fetchChatList() async {
    if (_isLoading) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Fetching buying chat list data...');
      final request = ChatListRequestModel(
        isBuyer: true,
        pageStart: _pageStart,
        resultPerPage: _resultPerPage,
        searchQuery: null,
      );

      await Provider.of<ChatViewModel>(context, listen: false).getChatList(request.toJson()).then(
        (value) {
          Response res = value;
          debugPrint('API Response: ${res.statusCode}');
          debugPrint(res.body);

          if (!mounted) return;

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            final chat_model.ChatListResponseModel chatListResponseModel = chat_model.ChatListResponseModel.fromJson(jsonDecode(res.body));
            debugPrint('Received ${chatListResponseModel.data.length} chat items');

            if (chatListResponseModel.data.isNotEmpty) {
              setState(() {
                // Sync with notification service status
                for (var chatItem in chatListResponseModel.data) {
                  // Check if this chat has unread status in notification service
                  chatItem.isNewMsg = _notificationService.isUnread(chatItem.equipmentChatId);
                }

                _chatList.addAll(chatListResponseModel.data);
                _pageStart += _resultPerPage;
                _isLoading = false;
              });
            } else {
              setState(() {
                _hasMoreData = false;
                _isLoading = false;
              });
            }
          } else {
            setState(() {
              _isLoading = false;
            });
            Map<String, dynamic> errorModel = jsonDecode(res.body);
            if (errorModel.containsKey('ModelState')) {
              Map<String, dynamic> modelState = errorModel['ModelState'];
              if (modelState.containsKey('ErrorMessage')) {
                showSnackBarColor(modelState['ErrorMessage'][0], context, true);
              }
            }
          }
        },
      );
    } on NoConnectivityException catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> _refreshData() async {
    debugPrint('Refreshing buying chat list data...');
    setState(() {
      _chatList.clear();
      _pageStart = 0;
      _hasMoreData = true;
    });
    await _fetchChatList();
    // _ensureSocketConnection();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Get access to the notification service
    _notificationService = Provider.of<ChatNotificationService>(context);

    return Material(
      color: Colors.white,
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: _chatList.isEmpty && !_isLoading
            ? CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Text('No conversations found'),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: _chatList.length + (_isLoading && _hasMoreData ? 1 : 0),
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  if (index == _chatList.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final chatItem = _chatList[index];

                  // Check the notification status from the service
                  chatItem.isNewMsg = _notificationService.isUnread(chatItem.equipmentChatId);

                  return conversationView(chatItem, index, context);
                },
              ),
      ),
    );
  }

  Widget conversationView(chat_model.ChatItem chatItem, int index, BuildContext context) {
    final String imageUrl = chatItem.equipmentImages.isNotEmpty ? chatItem.equipmentImages[0].filePath : '';

    // Debug output to verify notification dot state
    debugPrint('Chat item at index $index: isNewMsg=${chatItem.isNewMsg}');

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () async {
          // Mark as read when opening the chat
          if (chatItem.isNewMsg == true) {
            _notificationService.setUnread(chatItem.equipmentChatId, false);
            setState(() {
              chatItem.isNewMsg = false;
            });
          }

          List<EquipmentImage> equipmentImages = [];
          for (var item in chatItem.equipmentImages) {
            equipmentImages.add(EquipmentImage(
              equipmentImageId: item.equipmentImageId,
              fileStorageId: item.fileStorageId,
              filePath: item.filePath,
              fileName: item.fileName,
            ));
          }

          final intent = SellEquipmentResponseModel(
              equipmentId: chatItem.equipmentId,
              title: chatItem.title,
              brand: chatItem.brand,
              description: chatItem.description,
              postDate: DateTime.now(),
              price: chatItem.price,
              isActive: chatItem.isActive,
              sysUserId: 0,
              equipmentCategoryId: 0,
              isEquipmentOwner: false,
              fullName: chatItem.sellerUserName,
              mobileNumber: '',
              email: '',
              userType: '',
              isFavourite: false,
              sellEquipmentCategory: SellEquipmentCategory(name: '', code: ''),
              equipmentConditionId: 0,
              sellEquipmentCondition: SellEquipmentCondition(name: '', code: ''),
              equipmentStatusId: 0,
              equipmentStatus: EquipmentStatus(name: '', code: ''),
              equipmentSubActivities: [],
              equipmentImages: equipmentImages,
              equipmentChatId: chatItem.equipmentChatId);
          final value = await Navigator.pushNamed(
            context,
            Constants.buyingChatScreen,
            arguments: intent,
          );

          if (value != null && value is bool && value) {
            _refreshData();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/ic_group_circle.png',
                              height: 50,
                              width: 50,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Image.asset(
                            'assets/images/ic_group_circle.png',
                            height: 50,
                            width: 50,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomTextView(
                            label: chatItem.sellerUserName,
                            maxLine: 1,
                            textOverFlow: TextOverflow.ellipsis,
                            type: styleSubTitle,
                            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  color: const Color(0xFF2B2B2B),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextView(
                      label: chatItem.title,
                      maxLine: 2,
                      textOverFlow: TextOverflow.ellipsis,
                      type: styleSubTitle,
                      textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFF2B2B2B),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            // Notification dot - with unique key for proper updating
            Visibility(
              key: Key('notification_dot_${chatItem.equipmentChatId}_${chatItem.isNewMsg}'),
              visible: chatItem.isNewMsg ?? false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 22.0, 15.0, 0.0),
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupSocketConnection() {
    // Listen for socket events
    _socketSubscription = _socketService.socketListenerStream.listen((pair) {
      if (pair.first == BuyingSocketService.listenEquipmentMessages) {
        // _handleIncomingChatMessage(pair.second);
      } else if (pair.first == BuyingSocketService.listenEquipmentCloseDealMessages) {
        // _handleCloseDealMessage(pair.second);
      }
    });

    // Listen for connection status changes
    _connectionStatusSubscription = _socketService.connectionStatusStream.listen((status) {
      debugPrint('Connection status changed: $status');
      if (status == ConnectionStatus.connected) {
        setState(() {
          _isConnected = true;
        });
        // _registerUserWithHub();
      } else if (status == ConnectionStatus.disconnected || status == ConnectionStatus.failed) {
        setState(() {
          _isConnected = false;
        });
      }
    });

    // Check if already connected, otherwise connect
    // _ensureSocketConnection();
  }

  // void _ensureSocketConnection() async {
  //   if (!_socketService.isConnected) {
  //     debugPrint('Socket not connected. Connecting...');
  //     // await _socketService.connect();
  //   }
  //   if (_socketService.isConnected) {
  //     debugPrint('Socket already connected');
  //     _registerUserWithHub();
  //   }
  // }

  // void _registerUserWithHub() async {
  //   try {
  //     await _socketService.registerUser(OQDOApplication.instance.userID!);
  //   } catch (e) {
  //     debugPrint('Error registering user with hub: $e');
  //   }
  // }

  void _handleIncomingChatMessage(List<Object?>? args) {
    debugPrint("On Connect ===> $args");
    if (args != null && args.length >= 2) {
      var encodedString = jsonEncode(args[1]);
      debugPrint("Encoded message: $encodedString");

      Map<String, dynamic> valueMap = json.decode(encodedString);
      ChatMessage chatMessage = ChatMessage.fromJson(valueMap);
      debugPrint("Processed chat message: equipmentChatId=${chatMessage.equipmentChatId}");

      // Mark as unread in the notification service
      _notificationService.setUnread(chatMessage.equipmentChatId!, true);

      bool foundMatch = false;
      for (var i = 0; i < _chatList.length; i++) {
        if (_chatList[i].equipmentChatId == chatMessage.equipmentChatId) {
          debugPrint("Match found at index $i");
          foundMatch = true;
          _chatList[i].isNewMsg = true;
          if (i > 0) {
            var removeItem = _chatList.removeAt(i);
            _chatList.insert(0, removeItem);
            debugPrint("Moved chat to top of list");
          }
        }
      }

      if (!foundMatch) {
        debugPrint("No matching chat found in list for equipmentChatId: ${chatMessage.equipmentChatId}");
        // Refresh the entire list if the message is for a chat that's not in our current list
        _refreshData();
      } else {
        if (mounted) {
          setState(() {
            debugPrint("setState called to refresh UI with new message indicator");
          });
        }
      }
    } else {
      debugPrint("Invalid args format or empty args");
    }
  }

  void _handleCloseDealMessage(List<Object?>? args) {
    debugPrint("Close deal Chat Message: $args");
    if (args != null && args.length >= 2) {
      var encodedString = jsonEncode(args[1]);
      debugPrint("Encoded close deal message: $encodedString");

      Map<String, dynamic> valueMap = json.decode(encodedString);
      ChatMessage chatMessage = ChatMessage.fromJson(valueMap);
      debugPrint("Processed close deal message: equipmentChatId=${chatMessage.equipmentChatId}");

      // Mark as unread in the notification service
      _notificationService.setUnread(chatMessage.equipmentChatId!, true);

      bool foundMatch = false;
      for (var i = 0; i < _chatList.length; i++) {
        if (_chatList[i].equipmentChatId == chatMessage.equipmentChatId) {
          debugPrint("Match found at index $i");
          foundMatch = true;
          _chatList[i].isNewMsg = true;
          if (i > 0) {
            var removeItem = _chatList.removeAt(i);
            _chatList.insert(0, removeItem);
            debugPrint("Moved chat to top of list");
          }
        }
      }

      if (!foundMatch) {
        debugPrint("No matching chat found for close deal: ${chatMessage.equipmentChatId}");
        // Refresh the entire list if the message is for a chat that's not in our current list
        _refreshData();
      } else {
        if (mounted) {
          setState(() {
            debugPrint("setState called to refresh UI with close deal indicator");
          });
        }
      }
    }
  }
}
