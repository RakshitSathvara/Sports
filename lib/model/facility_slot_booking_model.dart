class FacilitySlotBookingModel {
  String? date;
  List<SlotListModel>? listOfSlots;

  FacilitySlotBookingModel({this.date, this.listOfSlots});
}

class SlotListModel {
  int? facilitySetupDetailId;
  int? facilitySetupDaySlotMapId;
  String? startTime;
  String? endTime;
  int totalSeat;
  int bookedSeat;
  int availableSeat = 0;
  bool isSlotSelected = false;
  double totalAmount = 0.00;
  String facilityBookingFreezeId = '';
  bool isSlotTimePassed = false;
  String bookingDate = '';
  bool isSlotCancelled;
  bool isMeetupConflict = false;

  SlotListModel(
      {this.facilitySetupDetailId,
      this.facilitySetupDaySlotMapId,
      this.startTime,
      this.endTime,
      this.totalSeat = 0,
      this.bookedSeat = 0,
      this.availableSeat = 0,
      this.bookingDate = '',
      this.isSlotCancelled = false,
      this.isMeetupConflict = false});
}
