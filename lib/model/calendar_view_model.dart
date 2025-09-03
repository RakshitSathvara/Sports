import 'package:oqdo_mobile_app/model/CoachDetailsResponseModel.dart';
import 'package:oqdo_mobile_app/model/GetFacilityByIdModel.dart';

class CalendarViewModel {
  String? type;
  GetFacilityByIdModel? getFacilityByIdModel;
  CoachDetailsResponseModel? coachDetailsResponseModel;
  DateTime? selectedDateTime;
  String? facilityFreezeId = '0';
  String? coachFreezeId = '0';
  int? facilitySetupId = 0;
  int? coachBatchSetupId = 0;
  String? remainingTime = '';
  String? selectedAddressId;
  DateTime? bookingStartTime;

  CalendarViewModel(
      {this.type,
      this.getFacilityByIdModel,
      this.coachDetailsResponseModel,
      this.selectedDateTime,
      this.facilityFreezeId,
      this.coachFreezeId,
      this.facilitySetupId,
      this.coachBatchSetupId,
      this.remainingTime,
      this.selectedAddressId});
}
