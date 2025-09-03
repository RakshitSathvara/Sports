import 'package:oqdo_mobile_app/model/get_all_activity_and_sub_activity_response.dart';

import '../../model/location_selection_response_model.dart';
import '../../model/otp_verification_response.dart';
import '../../model/upload_file_response.dart';

abstract class EndUserRegistrationRepository {
  Future<LocationSelectionResponseModel>? getAllCity();
  Future<GetAllActivityAndSubActivityResponse?> getAllActivityAndSubActivity();
  Future<String> checkUsernameExist(String userName);
  Future<String> checkEmailExist(String userName);
  Future<String> checkForMobileNoExists(String mobileNo);
  Future<String> tempEndUserRegistration(Map endUserRegistrationTempReqModel);
  Future<String> sendSMSOtp(String number);
  Future<String> sendEmailOtp(String number);
  Future<OtpVerificationResponse> verifyOtp(Map data);
  Future<UploadFileResponse> uploadImage(Map uploadImageData);
  Future<List<UploadFileResponse?>> multipleUploadImage(List<Map<String, dynamic>> uploadImageData);
  Future<String> endUserRegister(Map endUserRegisterRequest);
  Future<String> facilityProviderRegister(Map facilityProviderRequest);
  Future<String> coachProviderRegister(Map coachProviderRequest);
  Future<bool> validateReferralCode(String referralCode);
}
