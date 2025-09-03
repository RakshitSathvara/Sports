import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:oqdo_mobile_app/helper/helpers.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/friend_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/domain/chat_provider.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key? key}) : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MediaQueryData get dimensions => MediaQuery.of(context);

  Size get size => dimensions.size;

  double get height => size.height;

  double get width => size.width;

  double get radius => sqrt(pow(width, 2) + pow(height, 2));
  late Helper hp;
  final TextEditingController _searchActivityController = TextEditingController();
  List<Conversation> allConversationList = [];
  List<Conversation> searchList = [];
  bool mainLoader = true;
  int pageCount = 0;
  int resultPerPage = 1000;
  int totalCount = 0;
  HubConnection? _hubConnection;
  Logger? _logger;
  bool? connectionIsOpen;
  bool isSending = false;

  @override
  void initState() {
    super.initState();

    Logger.root.level = Level.ALL;
    _logger = Logger("ChatPage");

    // print(OQDOApplication.instance.token);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getConversation();
      _searchActivityController.addListener(() {
        searchList.clear();
        if (_searchActivityController.text.isEmpty) {
          setState(() {
            searchList.clear();
            searchList.addAll(allConversationList);
          });
          return;
        }

        for (var buddies in allConversationList) {
          if (buddies.firstName!.toLowerCase().contains(_searchActivityController.text.toLowerCase())) {
            searchList.add(buddies);
          }
        }

        setState(() {});
      });
    });

    openChatConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
        elevation: 0.0,
        backgroundColor: OQDOThemeData.dividerColor,
        onPressed: () async {
          var isChange = await Navigator.of(context).pushNamed(Constants.createChatScreen);
          if (isChange != null && isChange == true) {
            pageCount = 0;
            totalCount = 0;
            getConversation();
          }
        },
        child: Image.asset(
          'assets/images/ic_create_chat.png',
          height: 26,
          width: 26,
          fit: BoxFit.fill,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _pullRefresh,
          child: Container(
            width: width,
            height: height,
            color: OQDOThemeData.whiteColor,
            child: Column(
              children: [
                Consumer<ChatProvider>(
                  builder: (context, provider, child) {
                    if (provider.sendFrndMessageArgs != null) {
                      var msg = provider.sendFrndMessageArgs;
                      provider.sendFrndMessageArgs = null;
                      if (msg != null) {
                        sendMsgFriend(msg);
                      }
                    }
                    if (provider.sendGroupMessageArgs != null) {
                      var msg = provider.sendGroupMessageArgs;
                      provider.sendGroupMessageArgs = null;
                      if (msg != null) {
                        sendMsgGroup(msg);
                      }
                    }
                    return child!;
                  },
                  child: const SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(
                          color: const Color(0xFFF5F5F5),
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: SizedBox(
                      height: 38,
                      child: TextFormField(
                        autocorrect: false,
                        autofocus: false,
                        cursorColor: OQDOThemeData.greyColor,
                        minLines: 1,
                        controller: _searchActivityController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Image.asset(
                            'assets/images/ic_search_home.png',
                            height: 20,
                            width: 20,
                            fit: BoxFit.fill,
                          ),
                          hintText: 'Search...',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                mainLoader
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Expanded(
                        child: searchList.isNotEmpty
                            ? ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: searchList.length,
                                // controller: mScrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  Conversation conversation = searchList[index];
                                  return conversationView(conversation, index);
                                },
                              )
                            : allConversationList.isEmpty
                                ? Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/ic_empty_view.png',
                                        fit: BoxFit.fill,
                                        height: 400,
                                        width: 400,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextView(
                                        label: 'Conversation not available',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(fontSize: 16, color: OQDOThemeData.greyColor, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget conversationView(Conversation conversation, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: GestureDetector(
        onTap: () async {
          context.read<ChatProvider>().resetNewMessage();

          conversation.isBold = false;
          if (conversation.chatType == "F") {
            var isChange = await Navigator.pushNamed(context, Constants.friendChatScreen, arguments: conversation);

            if (isChange != null && isChange == true) {
              setState(() {
                if (searchList.isNotEmpty) {
                  var removedItem = searchList.removeAt(index);
                  searchList.insert(0, removedItem);
                }
              });
            }
          } else {
            var isChange = await Navigator.pushNamed(context, Constants.groupChatScreen, arguments: conversation);

            if (isChange != null && isChange == true) {
              setState(() {
                if (searchList.isNotEmpty) {
                  var removedItem = searchList.removeAt(index);
                  searchList.insert(0, removedItem);
                }
              });
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: conversation.profileImage != null ? Colors.white : Colors.black12,
              elevation: 0,
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                    child: conversation.profileImage != null && conversation.profileImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: conversation.profileImage!,
                            fit: BoxFit.fill,
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
            const SizedBox(
              width: 8,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextView(
                      label: conversation.chatType == "F" ? '${conversation.firstName} ${conversation.lastName}' : conversation.groupName.toString(),
                      maxLine: 1,
                      textOverFlow: TextOverflow.ellipsis,
                      type: styleSubTitle,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: const Color(0xFF2B2B2B), fontSize: 14.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    CustomTextView(
                      label: conversation.lastMessage.toString(),
                      maxLine: 2,
                      textOverFlow: TextOverflow.ellipsis,
                      type: styleSubTitle,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: const Color(0xFF2B2B2B), fontSize: 12.0, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: conversation.isBold ?? false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 22.0, 15.0, 0.0),
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(100)
                      //more than 50% of width makes circle
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    allConversationList.clear();
    searchList.clear();
    pageCount = 0;
    setState(() {
      mainLoader = true;
    });
    totalCount = 0;
    getConversation();
  }

  Future<void> getConversation() async {
    setState(() {
      mainLoader = true;
    });
    try {
      String requestStr = '';
      requestStr =
          'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID}';
      GetConversationListResponse getConversationListResponse =
          await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getConversationList(requestStr);
      if (!mounted) return;
      if (getConversationListResponse.data!.isNotEmpty) {
        showLog('Response -> ${getConversationListResponse.data!.length}');
        setState(() {
          allConversationList.clear();
          searchList.clear();
          allConversationList.addAll(getConversationListResponse.data!);
          searchList.addAll(getConversationListResponse.data!);
          totalCount = getConversationListResponse.totalCount!;
          pageCount = pageCount + 1;
          mainLoader = false;
        });
      } else {
        setState(() {
          mainLoader = false;
        });
      }
      // }
    } on CommonException catch (error) {
      showLog('common $error');
      setState(() {
        mainLoader = false;
      });
      if (error.code == 400) {
        Map<String, dynamic> errorModel = jsonDecode(error.message);
        if (errorModel.containsKey('ModelState')) {
          Map<String, dynamic> modelState = errorModel['ModelState'];
          if (modelState.containsKey('ErrorMessage')) {
            showSnackBarColor(modelState['ErrorMessage'][0], context, true);
          } else {
            showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
          }
        } else {
          showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
        }
      } else if (error.code == 500) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      } else if (error.code == 404) {
        showSnackBarColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } on NoConnectivityException catch (_) {
      setState(() {
        mainLoader = false;
      });
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      setState(() {
        mainLoader = false;
      });
      if (!mounted) return;
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  Future<void> openChatConnection() async {
    var logger = _logger;
    if (_hubConnection == null) {
      var httpConnectionOptions =
          HttpConnectionOptions(logger: logger, skipNegotiation: true, transport: HttpTransportType.WebSockets, logMessageContent: true);

      _hubConnection = HubConnectionBuilder()
          .withUrl('${Constants.SOCKET_BASE_URL}/ChatHub',
              // .withUrl(Constants.SOCKET_BASE_URL,
              options: httpConnectionOptions)
          .withAutomaticReconnect()
          .configureLogging(logger!)
          .build();
      _hubConnection!.onclose(({error}) => connectionIsOpen = false);
      _hubConnection!.onreconnecting(({error}) {
        // print("onreconnecting called");
        connectionIsOpen = false;
      });
      _hubConnection!.onreconnected(({connectionId}) {
        // print("onreconnected called");
        connectionIsOpen = true;
      });
      _hubConnection!.on("AddMessage", _handleGroupMessage);
      _hubConnection!.on("ReceiveMessages", _handleFriendMessage);
      //  _hubConnection!.on("Online", _handleOnlineFriend);
    }

    // print(_hubConnection!.state);
    // print(_hubConnection!.baseUrl);

    if (_hubConnection!.state != HubConnectionState.Connected) {
      // print("call");
      await _hubConnection!.start();
      // print(_hubConnection!.state);
      // final result = await _hubConnection?.invoke("logIN", args: <Object>["admin"]);
      // // print(result);
      // final result2 = await _hubConnection?.invoke("SendTokenInfo", args: <Object>["admin","RecupeId"]);
      // // print(result2);

      var result = await _hubConnection?.invoke("EndUserConnected", args: <Object>[OQDOApplication.instance.endUserID.toString()]);
      connectionIsOpen = true;
    }
  }

  void _handleGroupMessage(List<Object?>? args) {
    // print("Received Conversation >> ${args![0]} - ${args[1]}");

    if (args![1] != null) {
      var encodedString = jsonEncode(args[1]);
      Map<String, dynamic> valueMap = json.decode(encodedString);
      GroupMessage friend = GroupMessage.fromJson(valueMap);
      friend.isSentFromMe = false;

      context.read<ChatProvider>().receivedNewMsgFromGroup(friend);

      for (var i = 0; i < searchList.length; i++) {
        if (searchList[i].groupId == friend.groupId) {
          searchList[i].lastMessage = friend.message.toString();
          searchList[i].isBold = true;
          if (i > 0) {
            var removedItem = searchList.removeAt(i);
            searchList.insert(0, removedItem);
          }
        }
      }

      setState(() {});
    }
  }

  void _handleFriendMessage(List<Object?>? args) {
    // print("Received Conversation>> ${args![0]} - ${args[1]}");

    if (args![1] != null) {
      var encodedString = jsonEncode(args[1]);
      Map<String, dynamic> valueMap = json.decode(encodedString);
      FriendMessage friend = FriendMessage.fromJson(valueMap);
      friend.isSentFromMe = false;

      context.read<ChatProvider>().receivedNewMsgFromFriend(friend);

      for (var i = 0; i < searchList.length; i++) {
        if (searchList[i].fromEndUserId == friend.fromEndUserId || searchList[i].fromEndUserId == friend.toEndUserId) {
          if (searchList[i].toEndUserId == friend.fromEndUserId || searchList[i].toEndUserId == friend.toEndUserId) {
            searchList[i].lastMessage = friend.message.toString();
            searchList[i].isBold = true;
            if (i > 0) {
              var removedItem = searchList.removeAt(i);
              searchList.insert(0, removedItem);
            }
          }
        }
      }

      setState(() {});
    }
  }

  void _handleOnlineFriend(List<Object?>? args) {
    // print("Received Online>> ${args![0]} - ${args[1]}");
  }

  void sendMsgFriend(List<Object> msg) async {
    if (_hubConnection!.state == HubConnectionState.Connected) {
      // print(msg);
      var result = await _hubConnection?.invoke("EndUserConnected", args: <Object>[OQDOApplication.instance.endUserID.toString()]);
      // print(result);
      var result2 = await _hubConnection?.invoke("SendMessage", args: msg);
      // print(result2);
      if (result2 != null) {
        var encodedString = jsonEncode(result2);
        Map<String, dynamic> valueMap = json.decode(encodedString);
        FriendMessage friend = FriendMessage.fromJson(valueMap);
        friend.isSentFromMe = true;

        if (!mounted) return;
        context.read<ChatProvider>().isSending = false;
        context.read<ChatProvider>().receivedNewMsgFromFriend(friend);
      } else {
        if (!mounted) return;
        context.read<ChatProvider>().isSending = false;
        context.read<ChatProvider>().notifyChanges();
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } else {
      await _hubConnection!.start();
    }
  }

  void sendMsgGroup(List<Object> msg) async {
    if (_hubConnection!.state == HubConnectionState.Connected) {
      // print("call group");
      var result = await _hubConnection?.invoke("EndUserConnected", args: <Object>[OQDOApplication.instance.endUserID.toString()]);
      // print(result);
      var result2 = await _hubConnection?.invoke("SendMessageToGroup", args: msg);
      // print(result2);
      if (result2 != null) {
        var encodedString = jsonEncode(result2);
        Map<String, dynamic> valueMap = json.decode(encodedString);
        GroupMessage friend = GroupMessage.fromJson(valueMap);
        friend.isSentFromMe = true;

        if (!mounted) return;
        context.read<ChatProvider>().isSending = false;
        context.read<ChatProvider>().receivedNewMsgFromGroup(friend);
      } else {
        if (!mounted) return;
        context.read<ChatProvider>().isSending = false;
        context.read<ChatProvider>().notifyChanges();
        showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
      }
    } else {
      await _hubConnection!.start();
    }
  }

  @override
  void dispose() {
    // print("call dispose");
    _hubConnection!.stop();
    super.dispose();
  }
}
