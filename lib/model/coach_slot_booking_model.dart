class CoachSlotBookingModel {
  String? date;
  List<CoachSlotListModel>? listOfSlots;

  CoachSlotBookingModel({this.date, this.listOfSlots});
}

class CoachSlotListModel {
  int? coachBatchSetupDetailId;
  int? coachBatchSetupDaySlotMapId;
  String? startTime;
  String? endTime;
  int totalSeat;
  int bookedSeat;
  int availableSeat = 0;
  bool isSlotSelected = false;
  double totalAmount = 0.00;
  int coachBookingFreezeId = 0;
  bool isSlotTimePassed = false;
  String bookingDate = '';
  bool? isSlotCancelled;
  bool? isMeetupConflict;

  CoachSlotListModel(
      {this.coachBatchSetupDetailId,
      this.coachBatchSetupDaySlotMapId,
      this.startTime,
      this.endTime,
      this.totalSeat = 0,
      this.bookedSeat = 0,
      this.availableSeat = 0,
      this.bookingDate = '',
      this.isSlotCancelled = false,
      this.isMeetupConflict = false});
}
