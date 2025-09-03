class CoachBookingResponse {
  int? coachBookingId;
  String? transactionDate;
  int? endUserId;
  int? coachBatchSetupDetailId;
  int? coachBookingFreezeId;
  int? tranineeAddressId;
  String? paymentSecret;
  int? paymentAmount;

  CoachBookingResponse(
      {this.coachBookingId,
      this.transactionDate,
      this.endUserId,
      this.coachBatchSetupDetailId,
      this.coachBookingFreezeId,
      this.tranineeAddressId,
      this.paymentSecret,
      this.paymentAmount});

  CoachBookingResponse.fromJson(Map<String, dynamic> json) {
    coachBookingId = json['CoachBookingId'];
    transactionDate = json['TransactionDate'];
    endUserId = json['EndUserId'];
    coachBatchSetupDetailId = json['CoachBatchSetupDetailId'];
    coachBookingFreezeId = json['CoachBookingFreezeId'];
    tranineeAddressId = json['TranineeAddressId'];
    paymentSecret = json['PaymentSecret'];
    paymentAmount = json['PaymentAmount'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['CoachBookingId'] = this.coachBookingId;
    data['TransactionDate'] = this.transactionDate;
    data['EndUserId'] = this.endUserId;
    data['CoachBatchSetupDetailId'] = this.coachBatchSetupDetailId;
    data['CoachBookingFreezeId'] = this.coachBookingFreezeId;
    data['TranineeAddressId'] = this.tranineeAddressId;
    data['PaymentSecret'] = this.paymentSecret;
    data['PaymentAmount'] = this.paymentAmount;
    return data;
  }
}
