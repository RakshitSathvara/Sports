import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/main.dart';
import 'package:oqdo_mobile_app/model/config_response_model.dart';
import 'package:oqdo_mobile_app/route_generator.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/domain/chat_provider.dart';
import 'package:oqdo_mobile_app/screens/login/splash_screen.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/shared_preferences_manager.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/location_selection_viewmodel.dart';
import 'package:oqdo_mobile_app/viewmodels/notification_provider.dart';
import 'package:oqdo_mobile_app/viewmodels/theme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

class OQDOApplication extends StatefulWidget {
  OQDOApplication._internal();

  static OQDOApplication instance = OQDOApplication._internal();

  factory OQDOApplication({GlobalKey<NavigatorState>? navigatorKey}) {
    // instance.navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
    return instance;
  }

  @override
  State<OQDOApplication> createState() => _OQDOApplicationState();

  // final storage = const FlutterSecureStorage();
  final storage = SharedPreferencesManager();
  String? endUserID = '';
  String? facilityID = '';
  String? coachID = '';
  String? userID = '';
  String? userType = '';
  String? mobileNoLength = '';
  String? isLogin = '0';
  String? fcmToken = '';
  String? token = '';
  String? tokenType = '';
  ConfigResponseModel? configResponseModel;
  String? userName = '';
  String? profileImage = '';
  String? name = '';
  String? email = '';
  String? phone = '';
  String? country = '';
  String? city = '';
  String? zipcode = '';
  int isAppIsInBackground = 0;
  String? lastNotificationId = '';
  String? defualtRefCode = '';
// GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class _OQDOApplicationState extends State<OQDOApplication> {
  String? isLogin = '0';

  @override
  void initState() {
    super.initState();
    // getData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<ProfileViewModel>(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
        ChangeNotifierProvider<LocationSelectionViewModel>(create: (_) => LocationSelectionViewModel()),
        ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return MaterialApp(
              builder: (context, widget) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                    child: ResponsiveWrapper.builder(
                      BouncingScrollWrapper.builder(context, widget!),
                      maxWidth: 1200,
                      minWidth: 450,
                      defaultScale: true,
                      breakpoints: [
                        const ResponsiveBreakpoint.resize(450, name: MOBILE),
                        const ResponsiveBreakpoint.autoScale(800, name: TABLET),
                        const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                        const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                        const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
                      ],
                    ),
                  ),
              onGenerateRoute: RouteGenerator.generateRoute,
              title: Constants.APP_NAME,
              home: const Splash(),
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: rootScaffoldMessangerKey,
              debugShowCheckedModeBanner: false,
              theme: OQDOThemeData.lightThemeData,
              darkTheme: OQDOThemeData.darkThemeData,
              themeMode: themeViewModel.themeMode);
        },
      ),
    );
  }
}
