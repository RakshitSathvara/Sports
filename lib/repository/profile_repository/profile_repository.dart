import 'package:oqdo_mobile_app/model/coach_profile_response.dart';
import 'package:oqdo_mobile_app/model/end_user_profile_response.dart';
import 'package:oqdo_mobile_app/model/facility_profile_response.dart';

import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../model/upload_file_response.dart';

abstract class ProfileRepository {
  Future<EndUserProfileResponseModel> getEndUserProfile(String endUserId);

  Future<FacilityProfileResponse> getFacilityUserProfile(String facilityId);

  Future<CoachProfileResponseModel> getCoachUserProfile(String coachId);

  Future<UploadFileResponse> uploadImage(Map uploadImageData);
  Future<GetAllActivityAndSubActivityResponse?> getAllActivityAndSubActivity();
  Future<dynamic> coachProviderRegister(Map coachProviderRequest);
  Future<dynamic> facilityProfileUpdate(Map request);
  Future getEndUserAddress(String userId);
  Future<String> deleteEndUserAddress(Map<String, dynamic> request);
  Future<List<UploadFileResponse?>> multipleUploadImage(List<Map<String, dynamic>> uploadImageData);
  Future<String> deleteSingleNotification(String notificationId);
  Future<String> deleteAllNotifications(String userId);
}
