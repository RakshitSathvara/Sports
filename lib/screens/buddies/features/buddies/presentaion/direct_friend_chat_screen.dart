import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:oqdo_mobile_app/components/custom_app_bar.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/friend_chat_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/online_response.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';
import 'package:oqdo_mobile_app/utils/network_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

class DirectFriendChatScreen extends StatefulWidget {
  final Conversation? model;

  const DirectFriendChatScreen({Key? key, this.model}) : super(key: key);

  @override
  _DirectFriendChatScreenState createState() => _DirectFriendChatScreenState();
}

class _DirectFriendChatScreenState extends State<DirectFriendChatScreen> {
  final TextEditingController _enterMessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int pageCount = 0;
  int resultPerPage = 20;
  int totalCount = 0;
  List<FriendMessage> messageList = [];
  bool mainLoader = true;
  bool isEmpty = false;
  HubConnection? _hubConnection;
  Logger? _logger;
  bool? connectionIsOpen;
  bool isSending = false;
  bool isOnline = false;
  Timer? timer;
  bool isMsgSent = false;

  @override
  void initState() {
    super.initState();

    Logger.root.level = Level.ALL;
    _logger = Logger("ChatPage");

    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) => getFriendOnline());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getFriendMessage();
      getFriendOnline();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (totalCount != messageList.length) {
          getFriendMessage();
        }
      }
    });

    openChatConnection();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: 'Chat',
            onBack: () {
              if (!isMsgSent) {
                Navigator.of(context).pop(false);
              } else {
                Navigator.of(context).pop(true);
              }
            }),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      child: ClipPath(
                        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Opacity(
                          opacity: 1,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onBackground),
                            child: widget.model!.profileImage != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.model!.profileImage!,
                                    fit: BoxFit.fill,
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextView(
                            label: '${widget.model!.firstName} ${widget.model!.lastName}',
                            maxLine: 1,
                            textOverFlow: TextOverflow.ellipsis,
                            type: styleSubTitle,
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: const Color(0xFF2B2B2B), fontSize: 16.0, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(children: [
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                  color: isOnline ? OQDOThemeData.onlineColor : OQDOThemeData.offlineColor, borderRadius: BorderRadius.circular(100)
                                  //more than 50% of width makes circle
                                  ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            CustomTextView(
                              label: isOnline ? 'Online' : 'Offline',
                              maxLine: 1,
                              textOverFlow: TextOverflow.ellipsis,
                              type: styleSubTitle,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: const Color(0xFF2B2B2B), fontSize: 14.0, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              Expanded(
                child: createChatList(),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  child: Padding(
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
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              autocorrect: false,
                              autofocus: false,
                              cursorColor: OQDOThemeData.greyColor,
                              keyboardType: TextInputType.multiline,
                              maxLength: 512,
                              maxLines: null,
                              textInputAction: TextInputAction.next,
                              controller: _enterMessageController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                                hintText: 'Enter message...',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          !isSending
                              ? GestureDetector(
                                  onTap: () async {
                                    if (_enterMessageController.text.toString().trim().isEmpty) {
                                      showSnackBar('Please add your message', context);
                                    } else {
                                      FocusScope.of(context).requestFocus(FocusNode());

                                      int? endUserId;
                                      if (widget.model!.fromEndUserId.toString() == OQDOApplication.instance.endUserID) {
                                        endUserId = widget.model!.toEndUserId;
                                      } else {
                                        endUserId = widget.model!.fromEndUserId;
                                      }

                                      if (_hubConnection!.state == HubConnectionState.Connected) {
                                        setState(() {
                                          isSending = true;
                                        });
                                        var result = await _hubConnection?.invoke("SendMessage", args: <Object>[
                                          _enterMessageController.text.toString(),
                                          OQDOApplication.instance.endUserID.toString(),
                                          endUserId.toString()
                                        ]);

                                        setState(() {
                                          isMsgSent = true;
                                        });

                                        if (result != null) {
                                          var encodedString = jsonEncode(result);
                                          Map<String, dynamic> valueMap = json.decode(encodedString);
                                          FriendMessage friend = FriendMessage.fromJson(valueMap);
                                          friend.isSentFromMe = true;

                                          setState(() {
                                            isSending = false;
                                            messageList.insert(0, friend);
                                            widget.model!.lastMessage = friend.message.toString();
                                            isEmpty = false;
                                            _enterMessageController.text = "";
                                          });
                                        } else {
                                          setState(() {
                                            isSending = false;
                                          });
                                          showSnackBarErrorColor(
                                              'We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
                                        }
                                      } else {
                                        setState(() {
                                          isSending = false;
                                        });
                                        await _hubConnection!.start();
                                        connectionIsOpen = true;
                                        showSnackBar('Send again', context);
                                      }
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/images/ic_send_message.png',
                                    height: 34,
                                    width: 34,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createChatList() {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: messageList.isNotEmpty ? messageList.length : 0,
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          itemBuilder: (context, index) {
            DateTime tempDate = DateFormat("yyyy-MM-dd'T'hh:mm:ss").parse(messageList[index].sentAt.toString());
            String formattedDate = DateFormat('MM-dd hh:mm').format(tempDate);

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 2),
                  child: Align(
                    alignment: (messageList[index].isSentFromMe == false ? Alignment.topLeft : Alignment.topRight),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: (messageList[index].isSentFromMe == false ? ColorsUtils.messageLeft : ColorsUtils.messageRight),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: messageList[index].isSentFromMe == false ? MainAxisAlignment.start : MainAxisAlignment.end,
                          crossAxisAlignment: messageList[index].isSentFromMe == false ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            CustomTextView(
                              maxLine: 10,
                              label: messageList[index].message.toString(),
                              textStyle: const TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        )),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 2, bottom: 10),
                  child: Align(
                    alignment: (messageList[index].isSentFromMe == false ? Alignment.topLeft : Alignment.topRight),
                    child: Column(
                      mainAxisAlignment: messageList[index].isSentFromMe == false ? MainAxisAlignment.start : MainAxisAlignment.end,
                      crossAxisAlignment: messageList[index].isSentFromMe == false ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        CustomTextView(
                          label: formattedDate.toString(),
                          textStyle: const TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (mainLoader) ...[
          Align(
            alignment: messageList.isNotEmpty ? Alignment.topCenter : Alignment.center,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
            ),
          )
        ],
        if (isEmpty) ...[
          Align(
            alignment: Alignment.center,
            child: CustomTextView(
              label: "No history found",
              textStyle: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          )
        ],
      ],
    );
  }

  Future<void> getFriendMessage() async {
    int? endUserId;
    if (widget.model!.fromEndUserId.toString() == OQDOApplication.instance.endUserID) {
      endUserId = widget.model!.toEndUserId;
    } else {
      endUserId = widget.model!.fromEndUserId;
    }

    setState(() {
      mainLoader = true;
    });
    try {
      String requestStr = '';
      requestStr =
          'FilterParamsDto.PageStart=$pageCount&FilterParamsDto.ResultPerPage=$resultPerPage&FilterParamsDto.EndUserId=${OQDOApplication.instance.endUserID.toString()}&FilterParamsDto.ToEndUserId=$endUserId';
      FriendChatResponse friendChatResponse = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getFriendChatList(requestStr);
      if (!mounted) return;
      showLog('Response -> ${friendChatResponse.data!.length}');
      if (friendChatResponse.data!.isNotEmpty) {
        setState(() {
          messageList.addAll(friendChatResponse.data!);
          totalCount = friendChatResponse.totalCount!;
          pageCount = pageCount + 1;
          mainLoader = false;

          if (messageList.isEmpty) {
            isEmpty = true;
          } else {
            isEmpty = false;
          }
        });
      } else {
        setState(() {
          mainLoader = false;
          if (messageList.isEmpty) {
            isEmpty = true;
          }
        });
      }
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
      if (!mounted) return;
      setState(() {
        mainLoader = false;
      });
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
          .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 20000])
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
      _hubConnection!.on("ReceiveMessages", _handleIncomingChatMessage);
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
      // print(result);
      connectionIsOpen = true;
    }
  }

  Future<void> getFriendOnline() async {
    int? endUserId;
    if (widget.model!.fromEndUserId.toString() == OQDOApplication.instance.endUserID) {
      endUserId = widget.model!.toEndUserId;
    } else {
      endUserId = widget.model!.fromEndUserId;
    }

    try {
      String requestStr = '';
      requestStr = 'endUserId=$endUserId';
      dynamic response = await Provider.of<GetAllBuddiesReposotory>(context, listen: false).getFriendOnline(requestStr);
      if (!mounted) return;

      List<OnlineResponse> onlineList = response.map((item) => OnlineResponse.fromJson(item)).toList().cast<OnlineResponse>();

      if (onlineList.isNotEmpty) {
        for (int i = 0; i < onlineList.length; i++) {
          if (onlineList[i].endUserId == endUserId) {
            setState(() {
              isOnline = true;
            });
          }
        }
      } else {
        setState(() {
          isOnline = false;
        });
      }
    } on CommonException catch (error) {
      showLog('common $error');
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
      if (!mounted) return;
      showSnackBarColor(Constants.internetConnectionErrorMsg, context, true);
    } catch (e) {
      if (!mounted) return;
      showLog(e.toString());
      showSnackBarErrorColor('We\'re unable to connect to server. Please contact administrator or try after some time', context, true);
    }
  }

  void _handleIncomingChatMessage(List<Object?>? args) {
    // print("Received >> ${args![0]} - ${args[1]}");

    if (args![1] != null) {
      var encodedString = jsonEncode(args[1]);
      Map<String, dynamic> valueMap = json.decode(encodedString);
      FriendMessage friend = FriendMessage.fromJson(valueMap);
      friend.isSentFromMe = false;

      if (widget.model!.fromEndUserId == friend.fromEndUserId || widget.model!.fromEndUserId == friend.toEndUserId) {
        if (widget.model!.toEndUserId == friend.fromEndUserId || widget.model!.toEndUserId == friend.toEndUserId) {
          setState(() {
            isEmpty = false;
            messageList.insert(0, friend);
            widget.model!.lastMessage = friend.message.toString();
          });
        }
      }
    }
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    // Navigator.of(context).pop(true);
    // return Future.value(true);
    if (!isMsgSent) {
      Navigator.of(context).pop(false);
      return Future.value(false);
    } else {
      Navigator.of(context).pop(true);
      return Future.value(true);
    }
  }

  @override
  void dispose() {
    _enterMessageController.dispose();
    timer?.cancel();
    _hubConnection!.stop();
    super.dispose();
  }
}
