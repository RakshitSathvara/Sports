import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/model/CancelCoachAppointmentModel.dart';
import 'package:oqdo_mobile_app/model/CancelFacilityAppointmentModel.dart';
import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/EndUserAddressResponseModel.dart';
import 'package:oqdo_mobile_app/model/GetCoachBySetupIDModel.dart';
import 'package:oqdo_mobile_app/model/GetFacilityByIdModel.dart';
import 'package:oqdo_mobile_app/model/calendar_view_model.dart';
import 'package:oqdo_mobile_app/model/cancel_reason_view_model.dart';
import 'package:oqdo_mobile_app/model/common_passing_args.dart';
import 'package:oqdo_mobile_app/model/end_user_appointment_model_details.dart';
import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';
import 'package:oqdo_mobile_app/model/selecte_home_model.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/CoachEndUserCancelAppointment.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/EndUserFacilityAppointmentDetails.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/FacilityEndUserCancelAppointment.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/appointment_view_order_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/cancel_appointment_reason_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/coach_appointment_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/coach_details_appointment_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/coach_enduser_verification_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/copoun_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/enduser_appointment_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/facility_appointment_details_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/facility_appointment_screen.dart';
import 'package:oqdo_mobile_app/features/appointment/presentation/review_appointment_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/add_ads_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/ads_view.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/category_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/intent/ads_intent.dart';
import 'package:oqdo_mobile_app/screens/bazaar/ads_screen/viewmodel/ads_view_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/bazaar_home/bazaar_home_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/buy_fav_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/buy_product_details_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/buy/category_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/selling/selling_chat_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/viewmodel/chat_view_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/edit_view_equipment_intent_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/models/sell_equipment_response_model.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/product/edit_sell_product_detail_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/product/sell_product_detail_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/chats/buying/buying_chat_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/product_category_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/sell_product_category_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/viewmodel/sell_viewmodel.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/get_all_buddies_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_all_buddies_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/get_conversation_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/data/model/group_list_response.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/add_participants_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/buddies_profile.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/buddies_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/create_chat_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/create_group_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/direct_friend_chat_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/direct_group_chat_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/friend_chat_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/group_chat_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/group_detail_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/group_info_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/group_list_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/buddies/presentaion/my_friends_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meet_up_repository.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/data/meetup_response_model.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/presentation/add_meetup_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/presentation/meetup_details_screen.dart';
import 'package:oqdo_mobile_app/screens/buddies/features/meetups/presentation/meetup_list_screen.dart';
import 'package:oqdo_mobile_app/screens/calendar/batch_setup_page.dart';
import 'package:oqdo_mobile_app/screens/calendar/calendar_view_page.dart';
import 'package:oqdo_mobile_app/screens/cancellation%20request/enduser_cancellation_request_page.dart';
import 'package:oqdo_mobile_app/screens/chat/chat_screen.dart';
import 'package:oqdo_mobile_app/screens/coach/coach_details_booking_screen.dart';
import 'package:oqdo_mobile_app/screens/coach/coach_details_screen.dart';
import 'package:oqdo_mobile_app/screens/coach/coach_list_page.dart';
import 'package:oqdo_mobile_app/screens/common_widget/activity_interest_filter_screen.dart';
import 'package:oqdo_mobile_app/screens/common_widget/filter_screen.dart';
import 'package:oqdo_mobile_app/screens/facilities/facilities_list_page.dart';
import 'package:oqdo_mobile_app/screens/facilities/facility_details_screen.dart';
import 'package:oqdo_mobile_app/screens/favorites/coach_favorites_list_page.dart';
import 'package:oqdo_mobile_app/screens/favorites/facilities_favorites_list_page.dart';
import 'package:oqdo_mobile_app/screens/forgot_password/create_password_page.dart';
import 'package:oqdo_mobile_app/screens/forgot_password/forgot_otp_verification_page.dart';
import 'package:oqdo_mobile_app/screens/forgot_password/forgot_password_page.dart';
import 'package:oqdo_mobile_app/screens/home/about_us_page.dart';
import 'package:oqdo_mobile_app/screens/home/change_password_page.dart';
import 'package:oqdo_mobile_app/screens/home/contact_us_page.dart';
import 'package:oqdo_mobile_app/screens/home/notifications_page.dart';
import 'package:oqdo_mobile_app/screens/home/other_home_screen.dart';
import 'package:oqdo_mobile_app/screens/home/selected_activity_home_screen.dart';
import 'package:oqdo_mobile_app/screens/home/transaction_history_page.dart';
import 'package:oqdo_mobile_app/screens/login/login_page.dart';
import 'package:oqdo_mobile_app/screens/login/pre_login_page.dart';
import 'package:oqdo_mobile_app/screens/other/coming_soon_screen.dart';
import 'package:oqdo_mobile_app/screens/bazaar/sell/product/create_product_screen.dart';
import 'package:oqdo_mobile_app/screens/profile/add_trainind_address_page.dart';
import 'package:oqdo_mobile_app/screens/profile/coach_profile.dart';
import 'package:oqdo_mobile_app/screens/profile/coach_training_address_page.dart';
import 'package:oqdo_mobile_app/screens/profile/intent/refer_earn_intent.dart';
import 'package:oqdo_mobile_app/screens/profile/refer_earn_screen.dart';
import 'package:oqdo_mobile_app/screens/register/pre_register_page.dart';
import 'package:oqdo_mobile_app/screens/register/register_page.dart';
import 'package:oqdo_mobile_app/screens/service_provider/choose_service_provider_page.dart';
import 'package:oqdo_mobile_app/screens/service_provider/coach/coach_activities_selection_screen.dart';
import 'package:oqdo_mobile_app/screens/service_provider/coach/coach_add_page.dart';
import 'package:oqdo_mobile_app/screens/service_provider/coach/coach_add_page_one.dart';
import 'package:oqdo_mobile_app/screens/service_provider/coach/coach_add_page_two.dart';
import 'package:oqdo_mobile_app/screens/service_provider/coach/coach_otp_page.dart';
import 'package:oqdo_mobile_app/screens/service_provider/facility/facility_add_page.dart';
import 'package:oqdo_mobile_app/screens/service_provider/facility/facility_add_page_one.dart';
import 'package:oqdo_mobile_app/screens/service_provider/facility/facility_add_page_two.dart';
import 'package:oqdo_mobile_app/screens/service_provider/facility/facility_otp_page.dart';
import 'package:oqdo_mobile_app/screens/setup/add_batch_setup_page.dart';
import 'package:oqdo_mobile_app/screens/setup/add_facility_page.dart';
import 'package:oqdo_mobile_app/screens/setup/batch_setup_list_page.dart';
import 'package:oqdo_mobile_app/screens/setup/calendar_service_provider_page.dart';
import 'package:oqdo_mobile_app/screens/setup/cancellation_request_page.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_vacation_setup_screen.dart';
import 'package:oqdo_mobile_app/screens/setup/coach_vacationlist_screen.dart';
import 'package:oqdo_mobile_app/screens/setup/edit_batch_setup.dart';
import 'package:oqdo_mobile_app/screens/setup/edit_facility_setup.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup_page.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_vacation_setup_screen.dart';
import 'package:oqdo_mobile_app/screens/setup/vacationlist_screen.dart';
import 'package:oqdo_mobile_app/screens/setup/view_order_detail_page.dart';
import 'package:oqdo_mobile_app/screens/slot_management/coach_cancel_slot_management_screen.dart';
import 'package:oqdo_mobile_app/screens/slot_management/slot_management_calendar_screen.dart';
import 'package:oqdo_mobile_app/screens/slot_management/slot_selection_screen.dart';
import 'package:oqdo_mobile_app/utils/common_web_view_screen.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/network_issse_screen.dart';
import 'package:oqdo_mobile_app/viewmodels/BookingViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/DashboardViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/ProfileViewModel.dart';
import 'package:oqdo_mobile_app/viewmodels/appointment_view_model.dart';
import 'package:oqdo_mobile_app/viewmodels/end_user_resgistration_view_model.dart';
import 'package:oqdo_mobile_app/viewmodels/login_view_model.dart';
import 'package:oqdo_mobile_app/viewmodels/service_provider_setup_viewmodel.dart';
import 'package:oqdo_mobile_app/viewmodels/service_providers_cancellation_view_model.dart';
import 'package:oqdo_mobile_app/viewmodels/slot_management_view_model.dart';
import 'package:provider/provider.dart';

import 'model/coach_training_address.dart';
import 'features/appointment/presentation/cancel_coach_appointment_reason_screen.dart';
import 'features/appointment/presentation/cancel_facility_appointment_reason_screen.dart';
import 'features/appointment/presentation/facility_enduser_verification_screen.dart';
import 'screens/dashboard/dashboard_page.dart';
import 'screens/login/location_choose_page.dart';
import 'screens/slot_management/cancel_slot_reson_screen.dart';
import 'screens/slot_management/coach_slot_selection_screen.dart';
import 'screens/slot_management/facility_cancel_slot_management_screen.dart';
import 'screens/slot_management/review_coach_booking_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var args = settings.arguments;
    switch (settings.name) {
      case Constants.LOCATIONCHOOSEPAGE:
        return MaterialPageRoute(builder: (_) => const LocationChoosePage());

      case Constants.PRELOGIN:
        return MaterialPageRoute(builder: (_) => PreLoginPage());

      case Constants.PREREGISTER:
        return MaterialPageRoute(builder: (_) => const PreRegisterPage());

      case Constants.LOGIN:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<LoginViewModel>(
            create: (BuildContext context) => LoginViewModel(),
            child: const LoginPage(),
          ),
        );

      case Constants.FORGOTPASSWORD:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<LoginViewModel>(
            create: (BuildContext context) => LoginViewModel(),
            child: const ForgotPasswordPage(),
          ),
        );

      case Constants.FORGOTOTPVERIFICATION:
        var passingArgs = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<LoginViewModel>(
            create: (BuildContext context) => LoginViewModel(),
            child: ForgotOTPVerificationPage(email: passingArgs),
          ),
        );

      case Constants.CREATEPASSWORD:
        var passingArgs = settings.arguments as EmailOTPModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<LoginViewModel>(
            create: (BuildContext context) => LoginViewModel(),
            child: CreatePasswordPage(userDetails: passingArgs),
          ),
        );

      case Constants.APPPAGES:
        return MaterialPageRoute(
            builder: (_) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider<ProfileViewModel>(create: (_) => ProfileViewModel()),
                    ChangeNotifierProvider<DashboardViewModel>(create: (_) => DashboardViewModel()),
                  ],
                  child: DashboardPages(tabNumber: args as int),
                ));
      // return MaterialPageRoute(
      //     builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ProfileViewModel(), child: DashboardPages(tabNumber: args as int)));

      case Constants.changePassword:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ProfileViewModel(), child: const ChangePasswordPage()));

      case Constants.contactUs:
        return MaterialPageRoute(builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ProfileViewModel(), child: const ContactUsPage()));

      case Constants.aboutUs:
        return MaterialPageRoute(builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ProfileViewModel(), child: const AboutUsPage()));

      case Constants.REGISTER:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<EndUserRegistrationViewModel>(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: const RegisterPage(),
          ),
        );

      case Constants.FACILITYADD:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => EndUserRegistrationViewModel(), child: const FacilityAddPage()));

      case Constants.CHOOSESERVICEPROVIDER:
        return MaterialPageRoute(builder: (_) => ChooseServiceProviderPage());

      case Constants.FACILITYOTP:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: FacilityOTPPage(passingArgs),
          ),
        );

      case Constants.FACILITYADDONE:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: FacilityAddPageOne(passingArgs),
          ),
        );

      case Constants.FACILITYADDTWO:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: FacilityAddPageTwo(passingArgs),
          ),
        );

      case Constants.COACHADD:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => EndUserRegistrationViewModel(), child: const CoachAddPage()));

      case Constants.COACHOTP:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: CoachOTPPage(passingArgs),
          ),
        );

      case Constants.COACHADDONE:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: CoachAddPageOne(passingArgs),
          ),
        );

      case Constants.COACHADDTWO:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: CoachAddPageTwo(passingArgs),
          ),
        );

      case Constants.CALENDARVIEWPAGE:
        return MaterialPageRoute(builder: (_) => const CalendarViewPage());

      case Constants.BATCHSETUPPAGE:
        return MaterialPageRoute(builder: (_) => BatchSetupPage());

      case Constants.FACILITYSETUPPAGE:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ServiceProviderSetupViewModel(), child: const FacilitySetupPage()));

      case Constants.BATCHSETUPLISTPAGE:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ServiceProviderSetupViewModel(), child: const BatchSetupListPage()));

      case Constants.ADDFACILITYPAGE:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ServiceProviderSetupViewModel(), child: const AddFacilityPage()));

      case Constants.ADDBATCHSETUPPAGE:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (BuildContext context) => ServiceProviderSetupViewModel(), child: const AddBatchSetupPage()));

      case Constants.editFacilitySetup:
        var getFacilitySetupModel = settings.arguments as GetFacilityByIdModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => ServiceProviderSetupViewModel(),
            child: EditFacilitySetupScreen(
              getFacilityByIdModel: getFacilitySetupModel,
            ),
          ),
        );

      case Constants.editBatchSetup:
        var getCoachBatchModel = settings.arguments as GetCoachBySetupIdModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => ServiceProviderSetupViewModel(),
            child: EditBatchSetupScreen(
              getCoachBySetupIdModel: getCoachBatchModel,
            ),
          ),
        );

      case Constants.CALENDARSERVICEPROVIDERPAGE:
        return MaterialPageRoute(builder: (_) => const CalendarServiceProviderPage());

      case Constants.VIEWORDERDETAILPAGE:
        return MaterialPageRoute(builder: (_) => ViewOrderDetailPage());

      case Constants.CANCELLATIONREQUESTPAGE:
        return MaterialPageRoute(builder: (_) => const CancellationRequestPage());

      case Constants.coach_detail_booking_screen:
        return MaterialPageRoute(builder: (_) => const CoachDetailsBookingScreen());

      // case Constants.facilityCoachReviewScreen:
      //   return MaterialPageRoute(builder: (_) => FacilityCoachReviewScreen());

      case Constants.cancelAppointmentReasonScreen:
        return MaterialPageRoute(builder: (_) => const CancelAppointmentReasonScreen());

      case Constants.activityInterestFilterScreen:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: ActivityInterestFilterScreen(commonPassingArgs: passingArgs),
          ),
        );

      case Constants.coachActivityInterestFilterScreen:
        var passingArgs = settings.arguments as Map<String, List<SubActivitiesBean>>;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => EndUserRegistrationViewModel(),
            child: CoachActivitiesSelectionScreen(endUserActivitySelection: passingArgs),
          ),
        );

      case Constants.profileCoach:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => ProfileViewModel(),
            child: const CoachProfilePage(),
          ),
        );

      case Constants.addTrainingAddress:
        CoachTrainingAddress? model = settings.arguments as CoachTrainingAddress?;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => ServiceProviderSetupViewModel(),
            child: CoachTrainingAddressPage(
              type: 'c',
              model: model,
            ),
          ),
        );

      case Constants.endUserTrainingAddress:
        EndUserAddressResponseModel? model = settings.arguments as EndUserAddressResponseModel?;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => ServiceProviderSetupViewModel(),
            child: AddTrainingAddressPage(
              type: 'e',
              model: model,
            ),
          ),
        );

      case Constants.comingSoonScreen:
        return MaterialPageRoute(builder: (_) => const ComingSoonScreen());

      case Constants.FACILITIESLISTPAGE:
        SelectedHomeModel selectedHomeModel = settings.arguments as SelectedHomeModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => BookingViewModel(),
            child: FacilitiesListPage(selectedHomeModel: selectedHomeModel),
          ),
        );

      case Constants.COACHLISTPAGE:
        SelectedHomeModel selectedHomeModel = settings.arguments as SelectedHomeModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => BookingViewModel(),
            child: CoachListPage(
              selectedHomeModel: selectedHomeModel,
            ),
          ),
        );

      case Constants.facilityDetailsScreen:
        var getFacilitySetupModel = settings.arguments as GetFacilityByIdModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => BookingViewModel(),
            child: FacilityDetailsScreen(
              getFacilityByIdModel: getFacilitySetupModel,
            ),
          ),
        );

      case Constants.coachDetailScreen:
        var coachDetailsModel = settings.arguments as CoachDetailsResponseModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => BookingViewModel(),
            child: CoachDetailsScreen(
              coachDetailsResponseModel: coachDetailsModel,
            ),
          ),
        );

      case Constants.filterViewScreen:
        var passingArgs = settings.arguments as CommonPassingArgs;
        return MaterialPageRoute(
          builder: (_) => FilterViewScreen(
            commonPassingArgs: passingArgs,
          ),
        );

      case Constants.slotManagementCaledaerScreen:
        CalendarViewModel calendarViewModel = settings.arguments as CalendarViewModel;
        return MaterialPageRoute(
          builder: (_) => SlotManagementCalendarScreen(calendarViewModel: calendarViewModel),
        );

      case Constants.slotSelectionScreen:
        CalendarViewModel calendarViewModel = settings.arguments as CalendarViewModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SlotManagementViewModel(),
            child: SlotSelectionScreen(
              calendarViewModel: calendarViewModel,
            ),
          ),
        );

      case Constants.reviewAppointmentScreen:
        CalendarViewModel calendarViewModel = settings.arguments as CalendarViewModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SlotManagementViewModel(),
            child: ReviewAppointmentScreen(calendarViewModel: calendarViewModel),
          ),
        );

      case Constants.coachSlotSelectionScreen:
        CalendarViewModel calendarViewModel = settings.arguments as CalendarViewModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SlotManagementViewModel(),
            child: CoachSlotSelectionScreen(
              calendarViewModel: calendarViewModel,
            ),
          ),
        );

      case Constants.coachReviewBookingScreen:
        CalendarViewModel calendarViewModel = settings.arguments as CalendarViewModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SlotManagementViewModel(),
            child: ReviewCoachBookingScreen(calendarViewModel: calendarViewModel),
          ),
        );

      case Constants.ADDFACILITYVACATIONPAGE:
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(create: (context) => ServiceProviderSetupViewModel(), child: const AddFacilityVacationScreen()));

      case Constants.endUserAppointmentScreen:
        DateTime model = settings.arguments as DateTime;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: EndUserAppointmentsScreen(selectedDate: model),
          ),
        );

      case Constants.facilityAppointmentScreen:
        DateTime dateTime = settings.arguments as DateTime;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: FacilityAppointmentsScreen(dateTime: dateTime),
          ),
        );

      case Constants.coachAppointmentScreen:
        DateTime dateTime = settings.arguments as DateTime;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: CoachAppointmentsScreen(dateTime: dateTime),
          ),
        );

      case Constants.facilityAppointmentDetailScreen:
        String bookingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: FacilityAppointmentDetailsScreen(bookingId: bookingId),
          ),
        );

      case Constants.coachAppointmentDetailScreen:
        String bookingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: CoachDetailAppointmentScreen(bookingId: bookingId),
          ),
        );

      case Constants.facilityCancelSlotScreen:
        CalendarViewModel calendarViewModel = settings.arguments as CalendarViewModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SlotManagementViewModel(),
            child: FacilityCancelSlotManagementScreen(
              calendarViewModel: calendarViewModel,
            ),
          ),
        );

      case Constants.coachBatchCancelSlotScreen:
        CalendarViewModel calendarViewModel = settings.arguments as CalendarViewModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SlotManagementViewModel(),
            child: CoachCancelSlotScreen(
              calendarViewModel: calendarViewModel,
            ),
          ),
        );

      case Constants.cancelReasonScreen:
        CancelReasonViewModel cancelReasonViewModel = settings.arguments as CancelReasonViewModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: CancelReasonScreen(
              cancelReasonViewModel: cancelReasonViewModel,
            ),
          ),
        );

      case Constants.VACATIONLISTPAGE:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ServiceProviderSetupViewModel(),
            child: const VacationListScreen(),
          ),
        );

      case Constants.coachVacationScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ServiceProviderSetupViewModel(),
            child: const CoachVacationScreen(),
          ),
        );

      case Constants.coachVacationListScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ServiceProviderSetupViewModel(),
            child: const CoachVacationListScreen(),
          ),
        );

      case Constants.endUserAppointmentCoachDetails:
        EndUserAppointmentPassingModel model = settings.arguments as EndUserAppointmentPassingModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: EndUserCoachAppointmentDetailsScreen(model: model),
          ),
        );

      case Constants.endUserAppointmentFacilityDetails:
        EndUserAppointmentPassingModel model = settings.arguments as EndUserAppointmentPassingModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: EndUserFacilityAppointmentDetails(model: model),
          ),
        );

      case Constants.facilityEndUserCancelAppointment:
        EndUserAppointmentPassingModel model = settings.arguments as EndUserAppointmentPassingModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: FacilityEndUserCancelAppointment(model: model),
          ),
        );

      case Constants.coachEndUserCancelAppointment:
        EndUserAppointmentPassingModel model = settings.arguments as EndUserAppointmentPassingModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: CoachEndUserCancelAppointment(model: model),
          ),
        );

      case Constants.facilityCancelAppointmentReason:
        CancelFacilityAppointmentModel model = settings.arguments as CancelFacilityAppointmentModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: CancelFacilityAppointmentReasonScreen(cancelFacilityAppointmentModel: model),
          ),
        );

      case Constants.coachCancelAppointmentReason:
        CancelCoachAppointmentModel model = settings.arguments as CancelCoachAppointmentModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: CancelCoachAppointmentReasonScreen(cancelCoachAppointmentModel: model),
          ),
        );

      case Constants.homeScreenActivitySelectionScreen:
        String homeScreenSelection = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => DashboardViewModel(),
            child: ActivityHomeScreen(homeScreenSelection: homeScreenSelection),
          ),
        );

      case Constants.selectedActivityHomeScreen:
        SelectedHomeModel selectedHomeModel = settings.arguments as SelectedHomeModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => DashboardViewModel(),
            child: SelectedActivityHomeScreen(selectedHomeModel: selectedHomeModel),
          ),
        );

      case Constants.searchBuddiesScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: const BuddiesScreen(),
          ),
        );

      case Constants.groupListScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: const GroupListScreen(),
          ),
        );

      case Constants.createChatScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: const CreateChatScreen(),
          ),
        );

      case Constants.createGroupScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: const CreateGroupScreen(),
          ),
        );

      case Constants.groupDetailScreen:
        AllGroups groupModel = settings.arguments as AllGroups;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: GroupDetailScreen(groupModel: groupModel),
          ),
        );

      case Constants.myFriendsScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: const MyFriendsScreen(),
          ),
        );

      case Constants.buddiesProfileScreen:
        AllBuddiesModel model = settings.arguments as AllBuddiesModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: BuddiesProfilePage(allBuddiesModel: model),
          ),
        );

      case Constants.addParticipantScreen:
        List<GroupFriends> list = settings.arguments as List<GroupFriends>;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: AddParticipantsScreen(list: list),
          ),
        );

      case Constants.friendChatScreen:
        Conversation conversation = settings.arguments as Conversation;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: FriendChatScreen(model: conversation),
          ),
        );

      case Constants.directFriendChatScreen:
        Conversation conversation = settings.arguments as Conversation;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: DirectFriendChatScreen(model: conversation),
          ),
        );

      case Constants.groupInfoScreen:
        Conversation conversation = settings.arguments as Conversation;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: GroupInfoScreen(groupModel: conversation),
          ),
        );

      case Constants.groupChatScreen:
        Conversation conversation = settings.arguments as Conversation;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: GroupChatScreen(model: conversation),
          ),
        );

      case Constants.directGroupChatScreen:
        Conversation conversation = settings.arguments as Conversation;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => GetAllBuddiesReposotory(),
            child: DirectGroupChatScreen(model: conversation),
          ),
        );

      case Constants.facilityVerifyCancelApppointment:
        CancelFacilityAppointmentModel model = settings.arguments as CancelFacilityAppointmentModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: FacilityEndUserCancelAppointmentVerificationScreen(cancelFacilityAppointmentModel: model),
          ),
        );

      case Constants.coachVerifyCancelApppointment:
        CancelCoachAppointmentModel model = settings.arguments as CancelCoachAppointmentModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AppointmentViewModel(),
            child: CoachEndUserVerificationScreen(cancelCoachAppointmentModel: model),
          ),
        );

      case Constants.addMeetup:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => MeetupRepository(),
            child: const AddMeetupScreen(),
          ),
        );

      case Constants.listMeetup:
        DateTime model = settings.arguments as DateTime;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => MeetupRepository(),
            child: MeetupListScreen(
              dateTime: model,
            ),
          ),
        );

      case Constants.meetupDetails:
        MeetUps meetupResponse = settings.arguments as MeetUps;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => MeetupRepository(),
            child: MeetupDetailsScreen(
              meetupResponse: meetupResponse,
            ),
          ),
        );

      case Constants.notification:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ProfileViewModel(),
            child: const NotificationsPage(),
          ),
        );

      case Constants.transaction:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ProfileViewModel(),
            child: const TransactionHistoryPage(),
          ),
        );

      case Constants.enduserCancellationRequestPage:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ServiceProvidersCancellationViewModel(),
            child: const EnduserCancellationRequestPage(),
          ),
        );

      case Constants.networkIssueScreen:
        return MaterialPageRoute(builder: (_) => const NetworkIssueScreen());

      case Constants.webViewScreens:
        Map<String, dynamic> model = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CommonWebView(model: model),
        );

      case Constants.facilityFavoritesList:
        SelectedHomeModel selectedHomeModel = settings.arguments as SelectedHomeModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => BookingViewModel(),
            child: FacilitiesFavoritesListPage(selectedHomeModel: selectedHomeModel),
          ),
        );

      case Constants.coachFavoritesList:
        SelectedHomeModel selectedHomeModel = settings.arguments as SelectedHomeModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (BuildContext context) => BookingViewModel(),
            child: CoachFavoritesListPage(
              selectedHomeModel: selectedHomeModel,
            ),
          ),
        );

      case Constants.couponScreen:
        return MaterialPageRoute(builder: (_) => ChangeNotifierProvider(create: (context) => SlotManagementViewModel(), child: const CopounScreen()));

      case Constants.referEarnScreen:
        ReferEarnIntent model = settings.arguments as ReferEarnIntent;
        return MaterialPageRoute(
            builder: (_) => ReferEarnScreen(
                  intent: model,
                ));

      case Constants.bazaarHomeScreen:
        int args = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => BazaarHomeScreen(tabNumber: args));

      case Constants.addAdsScreen:
        return MaterialPageRoute(builder: (_) => ChangeNotifierProvider(create: (context) => AdsViewModel(), child: AddAdsScreen()));

      case Constants.sellProductListScreen:
        var intent = settings.arguments as EditViewEquipmentIntentModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SellViewmodel(),
            child: ProductCategoryScreen(
              editViewEquipmentIntentModel: intent,
            ),
          ),
        );

      case Constants.sellProductDetailScreen:
        var model = settings.arguments as EditViewEquipmentIntentModel;
        return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
                create: (context) => SellViewmodel(),
                child: CreateProductScreen(
                  editViewEquipmentIntentModel: model,
                )));

      case Constants.chatDetailsScreen:
        return MaterialPageRoute(builder: (_) => ChatScreen());

      case SellProductDetailScreen.routeName:
        var intent = settings.arguments as EditViewEquipmentIntentModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SellViewmodel(),
            child: SellProductDetailScreen(
              editViewEquipmentIntentModel: intent,
            ),
          ),
        );

      case BuyProductDetailsScreen.routeName:
        var intent = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SellViewmodel(),
            child: BuyProductDetailsScreen(
              equipmentId: intent,
            ),
          ),
        );

      case Constants.buyingChatScreen:
        var intent = settings.arguments as SellEquipmentResponseModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ChatViewModel(),
            child: BuyingChatScreen(
              equipmentDetails: intent,
            ),
          ),
        );

      case Constants.sellingChatScreen:
        var intent = settings.arguments as SellEquipmentResponseModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => ChatViewModel(),
            child: SellingChatScreen(
              equipmentDetails: intent,
            ),
          ),
        );

      case BuyFavScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => SellViewmodel(),
            child: BuyFavScreen(),
          ),
        );

      case SportsAdvertisementCarousel.routeName:
        var intent = settings.arguments as AdsIntent;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AdsViewModel(),
            child: SportsAdvertisementCarousel(
              intent: intent,
            ),
          ),
        );

      case SellProductCategoryScreen.routeName:
        var intent = settings.arguments as EditViewEquipmentIntentModel;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SellViewmodel(),
            child: SellProductCategoryScreen(
              editViewEquipmentIntentModel: intent,
            ),
          ),
        );

      case EditSellProductDetailScreen.routeName:
        var intent = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SellViewmodel(),
            child: EditSellProductDetailScreen(
              equipmentId: intent,
            ),
          ),
        );

      case CategoryScreen.routeName:
        var intent = settings.arguments as AdsIntent;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AdsViewModel(),
            child: CategoryScreen(intent: intent),
          ),
        );

      case BuyCategoryScreen.routeName:
        var intent = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => SellViewmodel(),
            child: BuyCategoryScreen(
              initialFilters: intent,
            ),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SafeArea(child: Scaffold(body: Text("Route Error"))));
    }
  }
}
// MaterialPageRoute(builder: (_) => Page())
