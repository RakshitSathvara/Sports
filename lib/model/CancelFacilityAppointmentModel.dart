import 'package:oqdo_mobile_app/model/facility_appointment_details_model.dart';

class CancelFacilityAppointmentModel {
  FacilityAppointmentDetailModel? facilityAppointmentDetailModel;
  List<FacilityBookingSlotDates>? list;
  String? selectedReasonId;
  String? selectedReason;
  String? otherText;

  CancelFacilityAppointmentModel(
      {this.facilityAppointmentDetailModel, this.list, this.selectedReason, this.selectedReasonId, this.otherText});
}
