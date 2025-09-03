import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/buying/buying_chat_list_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/chat_notification_service.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/selling/selling_chat_list_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/socket_service.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/viewmodel/chat_view_model.dart';
import 'package:provider/provider.dart';
import 'package:oqdo_mobile_app/oqdo_application.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TabController? controller;
  int _selectedIndex = 0;
  int? _previousIndex;

  final ChatViewModel _chatViewModel = ChatViewModel();
  final ChatNotificationService _notificationService = ChatNotificationService();

  // Socket service reference
  final BuyingSocketService _socketService = BuyingSocketService();

  // Create global keys to access child screen states
  final GlobalKey<BuyingChatListScreenState> _buyingKey = GlobalKey<BuyingChatListScreenState>();
  final GlobalKey<SellingChatListScreenState> _sellingKey = GlobalKey<SellingChatListScreenState>();

  @override
  void initState() {
    super.initState();
    // Set initial index
    _previousIndex = _selectedIndex;

    // Initialize socket connection
    _initializeSocketConnection();
  }

  void _initializeSocketConnection() async {
    // Check if socket is already connected
    if (!_socketService.isConnected) {
      try {
        await _socketService.connect();
        // Register user after successful connection
        if (_socketService.isConnected) {
          await _socketService.registerUser(OQDOApplication.instance.userID!);
          debugPrint('User registered with socket service');
        }
      } catch (e) {
        debugPrint('Error connecting to socket: $e');
      }
    } else {
      debugPrint('Socket already connected');
    }
  }

  @override
  void dispose() {
    // Note: We don't disconnect the socket here since it should remain available
    // for other screens in the app. The socket service should be disposed at app level.
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Check if we're tapping the same tab that's already selected
    bool isSameTab = _selectedIndex == index;

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });

    // Refresh data when tab is changed or when same tab is tapped again
    if (index == 0) {
      // Refresh buying tab data
      if (_buyingKey.currentState != null) {
        _buyingKey.currentState!.refreshData();
      }
    } else {
      // Refresh selling tab data
      if (_sellingKey.currentState != null) {
        _sellingKey.currentState!.refreshData();
      }
    }

    // Log for debugging
    debugPrint('Tab tapped: $index, Same tab: $isSameTab');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _chatViewModel),
          ChangeNotifierProvider.value(value: _notificationService),
        ],
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                  child: Container(
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFD4EEF9),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onTabTapped(0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                                  decoration: BoxDecoration(
                                    color: _selectedIndex == 0 ? const Color(0xFF006590) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Text(
                                    'Buying',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: _selectedIndex == 0 ? Colors.white : Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onTabTapped(1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: _selectedIndex == 1 ? const Color(0xFF006590) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Text(
                                    'Selling',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: _selectedIndex == 1 ? Colors.white : Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      BuyingChatListScreen(key: _buyingKey),
                      SellingChatListScreen(key: _sellingKey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
