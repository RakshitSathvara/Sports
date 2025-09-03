class EndUserAppointmentPassingModel {
  String? type = '';
  String? selectedDate = '';
  String? bookingId = '';
  String? day = '';
  bool? isCancel = false;
  bool? isDirectCancel = false;

  EndUserAppointmentPassingModel(
      {this.bookingId, this.type, this.selectedDate, this.day, this.isCancel, this.isDirectCancel});
}
