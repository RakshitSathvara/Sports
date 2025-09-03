import 'package:oqdo_mobile_app/model/coach_slot_booking_model.dart';
import 'package:oqdo_mobile_app/model/facility_slot_booking_model.dart';

class CancelReasonViewModel {
  String? type;
  List<FacilitySlotBookingModel>? facilityBookingList;
  List<CoachSlotBookingModel>? coachBookingList;

  CancelReasonViewModel(
      {this.type, this.facilityBookingList, this.coachBookingList});
}
