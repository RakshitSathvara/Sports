import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chat_enums.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/model/equipment_chat_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/model/user_details_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/socket_service.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/viewmodel/chat_view_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/views/close_deal_view.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/views/offer_price_bottom_sheet_view.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:oqdo_mobile_app/utils/string_manager.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class SellingChatScreen extends StatefulWidget {
  const SellingChatScreen({super.key, required this.equipmentDetails});

  final SellEquipmentResponseModel equipmentDetails;

  @override
  State<SellingChatScreen> createState() => _SellingChatScreenState();
}

class _SellingChatScreenState extends State<SellingChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  bool madeOffer = true;
  final offerPriceController = TextEditingController();

  // Socket service reference
  final BuyingSocketService _socketService = BuyingSocketService();
  bool _isConnected = false;
  late StreamSubscription _socketSubscription;
  late StreamSubscription _connectionStatusSubscription;

  List<ChatMessage> chatMessageResponseModelList = [];
  // Changed from late to nullable
  EquipmentChatResponseModel? chatResponseModel;
  final ScrollController _scrollController = ScrollController();
  double price = 0.0;
  String sellerName = '';
  // Added loading state
  bool isLoading = true;

  bool showCloseDealView = false;

  late ProgressDialog _progressDialog;
  int? chatId;

  @override
  initState() {
    super.initState();
    Logger.root.level = Level.ALL;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatId = widget.equipmentDetails.equipmentChatId;
      debugPrint("Chat obj: ${widget.equipmentDetails.equipmentChatId}");
      debugPrint("Chat ID: $chatId");
      getChatDetails();
    });

    _setupSocketConnection();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final lastPosition = _scrollController.position;

      _scrollController.animateTo(
        lastPosition.maxScrollExtent + lastPosition.maxScrollExtent / 2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If controller doesn't have clients yet, try again after a short delay
      Future.delayed(Duration(milliseconds: 100), () => _scrollToBottom());
    }
  }

  void _setupSocketConnection() {
    // Listen for socket events
    _socketSubscription = _socketService.socketListenerStream.listen((pair) {
      if (pair.first == BuyingSocketService.listenEquipmentMessages) {
        _handleIncomingChatMessage(pair.second);
      } else if (pair.first == BuyingSocketService.listenEquipmentCloseDealMessages) {
        _handleCloseDealMessage(pair.second);
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
    _ensureSocketConnection();
  }

  void _ensureSocketConnection() async {
    if (!_socketService.isConnected) {
      debugPrint('Socket not connected. Connecting...');
      await _socketService.connect();
    }
    if (_socketService.isConnected) {
      debugPrint('Socket already connected');
      _registerUserWithHub();
    }
  }

  void _registerUserWithHub() async {
    try {
      await _socketService.registerUser(OQDOApplication.instance.userID!);
    } catch (e) {
      debugPrint('Error registering user with hub: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFEAF3F7),
        appBar: AppBar(
          toolbarHeight: 80,
          centerTitle: false,
          elevation: 0.0,
          leadingWidth: 0.0,
          leading: const SizedBox(),
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), // Added padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 18),
                    ClipPath(
                      clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.equipmentDetails.equipmentImages[0].filePath,
                            fit: BoxFit.fill,
                          )),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.equipmentDetails.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widget.equipmentDetails.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'S\$ ${widget.equipmentDetails.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF006590),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _buildChatMessages(),
              ),
              _buildBottomSection(isKeyboardVisible),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (chatMessageResponseModelList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: const Color(0xFF006590),
            ),
            const SizedBox(height: 16),
            Text(
              "Please send a message to start the chat",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        reverse: false,
        itemCount: chatMessageResponseModelList.isNotEmpty ? chatMessageResponseModelList.length : 0,
        itemBuilder: (context, index) {
          final message = chatMessageResponseModelList[index];
          final bool isSentByMe = message.fromUserId == int.parse(OQDOApplication.instance.userID!);
          final String time = _formatDateTime(message.createdAt ?? DateTime.now());
          final bool isOfferMessage = message.messageType == EquipmentChatMessageType.offer.toString();
          final bool isOfferAcceptanceMessage = message.messageType == EquipmentChatMessageType.offerAccepted.toString();
          final double price = message.price ?? 0.0;

          return _buildMessageBubble(
            message: message.message!,
            isSentByMe: isSentByMe,
            time: time,
            isOfferMessage: isOfferMessage,
            isOfferAcceptanceMessage: isOfferAcceptanceMessage,
            price: price,
          );
        },
      );
    }
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isSentByMe,
    required String time,
    bool? isOfferMessage = false,
    bool? isOfferAcceptanceMessage = false,
    double price = 0.0,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: (MediaQuery.sizeOf(context).width / 1.4)),
            margin: const EdgeInsets.only(bottom: 5),
            padding: EdgeInsets.fromLTRB(16, 15, isOfferAcceptanceMessage! ? 16 : 32, 15),
            decoration: BoxDecoration(
              color: isOfferMessage!
                  ? const Color(0xFF006590)
                  : (((!isSentByMe) && isOfferAcceptanceMessage))
                      ? Colors.white
                      : isSentByMe
                          ? const Color(0xFFC7DDE7)
                          : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isOfferAcceptanceMessage
                    ? Column(
                        children: [
                          isSentByMe
                              ? Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          maxLines: 2,
                                          "Offer: S\$ ${price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "ACCEPTED",
                                        style: TextStyle(
                                          color: Color(0xFF06BF12),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  color: Color(0xFFEBEBEB),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          maxLines: 2,
                                          "Offer: S\$ ${price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "ACCEPTED",
                                        style: TextStyle(
                                          color: Color(0xFF06BF12),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 15),
                          Text(
                            message,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      )
                    : isOfferMessage
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${isSentByMe ? "YOUR" : "BUYER'S"} OFFER",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'S\$ $message',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          )
                        : Text(
                            message,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat',
                            ),
                          ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isKeyboardVisible) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          showCloseDealView
              ? DisabledAdNotification(
                  onDelete: () {
                    deleteChat();
                  },
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isKeyboardVisible
                        ? const SizedBox(
                            width: 18,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF006590),
                                shape: BoxShape.circle,
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  cardColor: Color(0xFF006590),
                                  dividerTheme: DividerThemeData(
                                    color: Colors.white,
                                  ),
                                ),
                                child: PopupMenuButton<String>(
                                  // offset: const Offset(0, -115),
                                  offset: Offset(0, MediaQuery.of(context).viewInsets.bottom > 0 ? -115 : -150),
                                  // popUpAnimationStyle: AnimationStyle.noAnimation,
                                  popUpAnimationStyle: AnimationStyle.noAnimation,
                                  menuPadding: EdgeInsets.zero,
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  onSelected: (value) {
                                    debugPrint('Selected: $value');
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      value: 'Offer Price',
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'Offer Price',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      onTap: () {
                                        offerPriceController.text = price.toStringAsFixed(2);
                                        showMakeAnOfferBottomSheet();
                                      },
                                    ),
                                    PopupMenuDivider(
                                      height: 5,
                                    ),
                                    PopupMenuItem(
                                      value: 'Ok, Done',
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: madeOffer
                                          ? GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                offerAccepted();
                                              },
                                              child: RichText(
                                                text: TextSpan(
                                                    text: 'Ok, Done |',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: ' S\$ ${price.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w800,
                                                          fontFamily: 'Montserrat',
                                                        ),
                                                      )
                                                    ]),
                                              ),
                                            )
                                          : Text(
                                              'Ok, Done',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                    ),
                                    PopupMenuDivider(
                                      height: 5,
                                    ),
                                    PopupMenuItem(
                                      value: 'Close the Deal',
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'Close the Deal',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      onTap: () {
                                        showDeleteConfirmationDialog(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    Expanded(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                    hintText: 'Message',
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(255, 100, 98, 98),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 12, top: 5),
                                    constraints: BoxConstraints(minHeight: 55)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_messageController.text.isNotEmpty) {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  sendMessage(_messageController.text.toString().trim());
                                } else {
                                  showSnackBar('Please add your message', context);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Image.asset(
                                  "assets/images/ic_send.png",
                                  height: 22,
                                  width: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                  ],
                ),
        ],
      ),
    );
  }

  void showMakeAnOfferBottomSheet() {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: OQDOThemeData.whiteColor,
        builder: (context) => OfferPriceBottomSheetView(
              title: 'Offer Price',
              offerPriceController: offerPriceController,
              onSendOffer: () => sendOfferPrice(offerPriceController.text.toString().trim().toString()),
            ));
  }

  @override
  void dispose() {
    print("Disposing SellingChatScreen");
    _socketSubscription.cancel();
    _connectionStatusSubscription.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> getChatDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> request = {
        "isBuyer": false,
        "equipmentChatId": chatId,
        "pageStart": 0,
        "resultPerPage": 1000,
        "searchQuery": null,
      };

      await Provider.of<ChatViewModel>(context, listen: false).getChatDetails(request).then(
        (value) {
          Response res = value;
          debugPrint("Response: ${res.body}");

          if (res.statusCode == 500 || res.statusCode == 404) {
            setState(() {
              isLoading = false;
            });
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            chatResponseModel = EquipmentChatResponseModel.fromJson(jsonDecode(res.body));
            // Clear existing messages first to avoid duplicates
            chatMessageResponseModelList.clear();
            chatMessageResponseModelList.addAll(chatResponseModel!.chatDetails.data);

            chatMessageResponseModelList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

            if (chatMessageResponseModelList.isNotEmpty) {
              price = chatMessageResponseModelList.last.price!;
              _ensureLastMessageIsVisible();
            } else {
              price = widget.equipmentDetails.price;
            }

            setState(() {
              isLoading = false;
            });

            if ((chatResponseModel?.equipmentChatId != null || chatResponseModel?.equipmentChatId == 0) &&
                (chatResponseModel?.equipmentStatusCode != null && chatResponseModel?.equipmentStatusCode != '')) {
              if (chatResponseModel?.isActive == false) {
                setState(() {
                  showCloseDealView = true;
                });
                return showCloseDealView;
              } else {
                if (chatResponseModel?.equipmentStatusCode == EquipmentStatusCode.sold.toString() ||
                    chatResponseModel?.equipmentStatusCode == EquipmentStatusCode.removed.toString() ||
                    chatResponseModel?.equipmentStatusCode == EquipmentStatusCode.expired.toString() ||
                    chatResponseModel?.equipmentStatusCode == EquipmentStatusCode.inactive.toString() ||
                    chatResponseModel?.equipmentStatusCode == EquipmentStatusCode.pending.toString()) {
                  setState(() {
                    showCloseDealView = true;
                  });
                  return showCloseDealView;
                } else {
                  setState(() {
                    showCloseDealView = false;
                  });
                  return showCloseDealView;
                }
              }
            }
          } else {
            setState(() {
              isLoading = false;
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
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      setState(() {
        isLoading = false;
      });
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> deleteChat() async {
    _progressDialog = ProgressDialog(context, type: ProgressDialogType.normal, isDismissible: false);
    _progressDialog.style(message: "Please wait..");
    _progressDialog.show();
    try {
      Map<String, dynamic> request = {};

      request["EquipmentId"] = widget.equipmentDetails.equipmentId;
      request["EquipmentChatId"] = chatId;
      request["IsBuyer"] = false;
      await Provider.of<ChatViewModel>(context, listen: false).deleteChat(request).then(
        (value) async {
          Response res = value;
          debugPrint("Response: ${res.body}");
          await _progressDialog.hide();
          if (res.statusCode == 500 || res.statusCode == 404) {
            await _progressDialog.hide();
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            await _progressDialog.hide();
            showSnackBarColor("Chat deleted successfully", context, true);
            Navigator.pop(context, true);
          } else {
            await _progressDialog.hide();
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
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      await _progressDialog.hide();
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      await _progressDialog.hide();
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  Future<void> getUserDetails() async {
    if (chatResponseModel == null) {
      showSnackBarErrorColor("Unable to get user details: Chat data not loaded", context, true);
      return;
    }

    try {
      await Provider.of<ChatViewModel>(context, listen: false).getUserDetails(chatResponseModel!.buyerId.toString()).then(
        (value) {
          Response res = value;
          debugPrint("Response: ${res.body}");

          if (res.statusCode == 500 || res.statusCode == 404) {
            showSnackBarErrorColor(AppStrings.internalServerErrorMessage, context, true);
          } else if (res.statusCode == 200) {
            Map<String, dynamic> userResponse = jsonDecode(res.body);
            UserDetails userDetails = UserDetails.fromJson(userResponse);
            sellerName = userDetails.fullName;
            setState(() {});
          } else {
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
      showSnackBarErrorColor(AppStrings.noInternet, context, true);
    } on TimeoutException catch (_) {
      showSnackBarErrorColor(AppStrings.timeout, context, true);
    } on ServerException catch (_) {
      showSnackBarErrorColor(AppStrings.serverError, context, true);
    } catch (exception) {
      showSnackBarErrorColor(exception.toString(), context, true);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return "$day/$month $hour:$minute";
  }

  void _handleIncomingChatMessage(List<Object?>? args) {
    debugPrint("chat details ->  Incoming Chat Message: $args");
    if (args != null && args.length >= 2) {
      var encodedString = jsonEncode(args[1]);
      Map<String, dynamic> valueMap = json.decode(encodedString);
      ChatMessage chatMessage = ChatMessage.fromJson(valueMap);

      if (chatId == chatMessage.equipmentChatId && chatMessage.fromUserId == widget.equipmentDetails.sysUserId) {
        setState(() {
          chatMessageResponseModelList.insert(0, chatMessage);
          chatMessageResponseModelList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
          _messageController.clear();
          _ensureLastMessageIsVisible();
        });
      }
    }
  }

  void _handleCloseDealMessage(List<Object?>? args) {
    debugPrint("close deal Chat Message: $args");
    if (args != null && args.length >= 2) {
      var encodedString = jsonEncode(args[1]);
      Map<String, dynamic> valueMap = json.decode(encodedString);
      ChatMessage chatMessage = ChatMessage.fromJson(valueMap);

      var seller = int.parse(OQDOApplication.instance.userID!);
      var buyer = widget.equipmentDetails.sysUserId == 0 ? chatMessage.sellerId : widget.equipmentDetails.sysUserId;

      var isMsgValidforInsert = chatMessage.fromUserId == seller &&
          chatMessage.toUserId == buyer &&
          chatMessage.equipmentId == widget.equipmentDetails.equipmentId &&
          (chatId == null || chatId == chatMessage.equipmentChatId);

      if (isMsgValidforInsert) {
        final closeView = checkForShowCloseDealView(chatMessage);

        if (closeView) {
          setState(() {
            showCloseDealView = true;
          });
        }
      }
    }
  }

  Future<void> sendMessage(String message) async {
    if (!_socketService.isConnected) {
      showAlertDialog(context);
      return;
    }

    try {
      int? userId = int.tryParse(OQDOApplication.instance.userID!);
      var messageObj = {
        "EquipmentId": widget.equipmentDetails.equipmentId,
        "EquipmentChatId": chatId,
        "IsBuyer": false,
        "FromUserId": userId,
        "ToUserId": chatResponseModel!.buyerId == 0 ? widget.equipmentDetails.sysUserId : chatResponseModel!.buyerId,
        "status": "Active",
        "messageType": EquipmentChatMessageType.regular.toString(),
        "message": message,
        "price": price,
      };

      debugPrint("Message Object: ${jsonEncode(messageObj)}");

      final result = await _socketService.sendMessage("SendEquipmentMessage", [messageObj]);

      if (result != null) {
        var encodedString = jsonEncode(result);
        Map<String, dynamic> valueMap = json.decode(encodedString);
        ChatMessage chatMessage = ChatMessage.fromJson(valueMap);

        if (!checkForShowCloseDealView(chatMessage)) {
          setState(() {
            price = chatMessage.price!;
            chatId = chatMessage.equipmentChatId;
            chatMessageResponseModelList.insert(0, chatMessage);
            chatMessageResponseModelList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
            _messageController.clear();
            _ensureLastMessageIsVisible();
          });
        }
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      showSnackBarErrorColor('Failed to send message. Please try again.', context, true);
    }
  }

  Future<void> sendOfferPrice(String offerPrice) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_socketService.isConnected) {
      showAlertDialog(context);
      return;
    }

    try {
      int? userId = int.tryParse(OQDOApplication.instance.userID!);
      var offerObj = {
        "EquipmentId": widget.equipmentDetails.equipmentId,
        "EquipmentChatId": chatId,
        "IsBuyer": false,
        "FromUserId": userId,
        "ToUserId": chatResponseModel!.buyerId == 0 ? widget.equipmentDetails.sysUserId : chatResponseModel!.buyerId,
        "status": "Active",
        "messageType": EquipmentChatMessageType.offer.toString(),
        "message": offerPrice,
        "price": double.parse(offerPrice),
      };

      debugPrint("Offer Object: ${jsonEncode(offerObj)}");

      var result = await _socketService.sendMessage("SendEquipmentMessage", [offerObj]);

      debugPrint("Result: $result");

      if (result != null) {
        var encodedString = jsonEncode(result);
        Map<String, dynamic> valueMap = json.decode(encodedString);

        // Check if the response contains an error message
        if (valueMap.containsKey('ErrorMessage')) {
          showSnackBarErrorColor(valueMap['ErrorMessage'], context, true);
          return;
        }

        ChatMessage chatMessage = ChatMessage.fromJson(valueMap);

        if (!checkForShowCloseDealView(chatMessage)) {
          setState(() {
            chatId = chatMessage.equipmentChatId;
            chatMessageResponseModelList.add(chatMessage);
            // Re-sort the messages by date/time
            chatMessageResponseModelList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
            price = double.parse(offerPrice);
            madeOffer = true; // Update UI to show offer was made
          });

          // Scroll to bottom after adding offer message
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } catch (e) {
      debugPrint('Error sending offer: $e');
      showSnackBarErrorColor('Failed to send offer. Please try again.', context, true);
    }
  }

  Future<void> offerAccepted() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_socketService.isConnected) {
      showAlertDialog(context);
      return;
    }

    try {
      int? userId = int.tryParse(OQDOApplication.instance.userID!);
      var acceptObj = {
        "EquipmentId": widget.equipmentDetails.equipmentId,
        "EquipmentChatId": chatId,
        "IsBuyer": false,
        "FromUserId": userId,
        "ToUserId": chatResponseModel!.buyerId == 0 ? widget.equipmentDetails.sysUserId : chatResponseModel!.buyerId,
        "status": "Active",
        "messageType": EquipmentChatMessageType.offerAccepted.toString(),
        "message": "Offer Accepted, Let's close this deal fast.",
        "price": price,
      };

      debugPrint("Offer Acceptance Object: ${jsonEncode(acceptObj)}");

      var result = await _socketService.sendMessage("SendEquipmentMessage", [acceptObj]);

      debugPrint("Result: $result");

      if (result != null) {
        var encodedString = jsonEncode(result);
        Map<String, dynamic> valueMap = json.decode(encodedString);

        ChatMessage chatMessage = ChatMessage.fromJson(valueMap);

        if (!checkForShowCloseDealView(chatMessage)) {
          setState(() {
            chatId = chatMessage.equipmentChatId;
            chatMessageResponseModelList.add(chatMessage);
            price = chatMessage.price!;
            // Re-sort the messages by date/time
            chatMessageResponseModelList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
          });

          // Scroll to bottom after adding offer message
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } catch (e) {
      debugPrint('Error accepting offer: $e');
      showSnackBarErrorColor('Failed to accept offer. Please try again.', context, true);
    }
  }

  Future<void> closeDeal() async {
    if (!_socketService.isConnected) {
      showAlertDialog(context);
      return;
    }

    try {
      int? userId = int.tryParse(OQDOApplication.instance.userID!);
      var closeObj = {
        "EquipmentId": widget.equipmentDetails.equipmentId,
        "EquipmentChatId": chatId,
        "IsBuyer": true,
        "FromUserId": userId,
        "ToUserId": chatResponseModel!.buyerId == 0 ? widget.equipmentDetails.sysUserId : chatResponseModel!.buyerId,
        "status": "Active",
        "messageType": EquipmentChatStatus.closeDeal.toString(),
        "message": 'Deal closed. Thank you!',
        "price": price == 0.0 ? widget.equipmentDetails.price : price,
      };

      debugPrint("Close Deal Object: ${jsonEncode(closeObj)}");

      var result = await _socketService.sendMessage("EquipmentCloseDealMessage", [closeObj]);

      debugPrint("Result: $result");

      if (result != null) {
        var encodedString = jsonEncode(result);
        Map<String, dynamic> valueMap = json.decode(encodedString);

        ChatMessage chatMessage = ChatMessage.fromJson(valueMap);

        setState(() {
          chatId = chatMessage.equipmentChatId;
          chatMessageResponseModelList.add(chatMessage);
          chatMessageResponseModelList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
          price = chatMessage.price!;
          madeOffer = true; // Update UI to show offer was made
        });

        final showView = checkForShowCloseDealView(chatMessage);

        if (showView) {
          setState(() {
            showCloseDealView = true;
          });
        }
      } else {
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } catch (e) {
      debugPrint('Error closing deal: $e');
      showSnackBarErrorColor('Failed to close deal. Please try again.', context, true);
    }
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure?',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF2B2B2B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You want to remove the product. The action can not be reversed ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2B2B2B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                height: 4,
                color: Colors.black,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF006590),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          closeDeal();
                        },
                        child: const Text('Yes'),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool checkForShowCloseDealView(ChatMessage chatMessage) {
    if (chatMessage.isActive == false) {
      setState(() {
        showCloseDealView = true;
      });
      return showCloseDealView;
    } else {
      if (chatMessage.equipmentStatusCode == EquipmentStatusCode.sold.toString() ||
          chatMessage.equipmentStatusCode == EquipmentStatusCode.removed.toString() ||
          chatMessage.equipmentStatusCode == EquipmentStatusCode.expired.toString() ||
          chatMessage.equipmentStatusCode == EquipmentStatusCode.inactive.toString() ||
          chatMessage.equipmentStatusCode == EquipmentStatusCode.pending.toString()) {
        setState(() {
          showCloseDealView = true;
        });
        return showCloseDealView;
      } else {
        setState(() {
          showCloseDealView = false;
        });
        return showCloseDealView;
      }
    }
  }

  void _ensureLastMessageIsVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text('Chat timed out. Relaunch from list.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
