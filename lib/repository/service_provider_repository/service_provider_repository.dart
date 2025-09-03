import 'package:oqdo_mobile_app/model/GetCoachBySetupIDModel.dart';
import 'package:oqdo_mobile_app/model/cancellation_request_list_response_model.dart';

import '../../model/GetFacilityByIdModel.dart';
import '../../model/coach_training_address.dart';
import '../../model/facility_list_response_model.dart';
import '../../model/get_all_activity_and_sub_activity_response.dart';
import '../../model/upload_file_response.dart';

abstract class ServiceProviderSetupRepository {
  Future<FacilityListResponseModel> getFacilityProviderList(String facilityId);

  Future<GetAllActivityAndSubActivityResponse?> getAllActivityAndSubActivity();

  Future<UploadFileResponse> uploadImage(Map uploadImageData);

  Future<String> addFacilitySetup(Map addFacilitySetupMap);

  Future<dynamic> editFacilitySetup(Map addFacilitySetupMap);

  Future<String> deleteFacility(Map facilityID);

  Future<String> deleteCoachSetup(Map deleteCoachSetupMap);

  Future<dynamic> getCoachBatchList(String coachID);

  Future<List<CoachTrainingAddress>> getCoachTrainingCenter(String coachId);

  Future<dynamic> addCoachTrainingAddress(Map coachTrainingAddressMap, bool isEdit);

  Future<dynamic> addCoachbatch(Map coachSetupMap);

  Future<dynamic> editCoachBatch(Map coachSetupMap);

  Future<GetFacilityByIdModel> getFacilityById(int facilitySetupId);

  Future<GetCoachBySetupIdModel> getBatchById(int batchSetupID);

  Future<String> addEditEndUserAddress(Map<String, dynamic> addEndUserMap , bool isEdit);

  Future<dynamic> updateCoachBasicInfo(Map request);

  Future<dynamic> updateFacilityBasicInfo(Map request);

  Future<CancellationRequestsListModel> getCoachCancellationRequests({required String endUrl});

  Future<dynamic> updateCoachBookingRefundStatus(Map request);

  Future<CancellationRequestsListModel> getFacilityCancellationRequests({required String endUrl});

  Future<dynamic> updateFacilityBookingRefundStatus(Map request);

  Future<CancellationRequestsListModel> getEnduserCancellationRequests({required String endUrl});


}
