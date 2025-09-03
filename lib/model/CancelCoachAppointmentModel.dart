import 'package:oqdo_mobile_app/model/coach_appointment_details_response_model.dart' as model;

class CancelCoachAppointmentModel {
  model.CoachAppointmentDetailResponseModel? coachAppointmentDetailResponseModel;
  List<model.CoachBookingSlotDates>? bookingSlotList = [];
  String? selectedReasonId;
  String? selectedReason;
  String? otherText;

  CancelCoachAppointmentModel({this.coachAppointmentDetailResponseModel, this.bookingSlotList,this.selectedReasonId,this.selectedReason,this.otherText});
}
