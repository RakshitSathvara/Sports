class FacilityBookingResponse {
  int? facilityBookingId;
  int? facilityBookingFreezeId;
  String? transactionDate;
  int? endUserId;
  int? facilitySetupDetailId;
  String? paymentSecret;
  int? paymentAmount;

  FacilityBookingResponse(
      {this.facilityBookingId,
      this.facilityBookingFreezeId,
      this.transactionDate,
      this.endUserId,
      this.facilitySetupDetailId,
      this.paymentSecret,
      this.paymentAmount});

  FacilityBookingResponse.fromJson(Map<String, dynamic> json) {
    facilityBookingId = json['FacilityBookingId'];
    facilityBookingFreezeId = json['FacilityBookingFreezeId'];
    transactionDate = json['TransactionDate'];
    endUserId = json['EndUserId'];
    facilitySetupDetailId = json['FacilitySetupDetailId'];
    paymentSecret = json['PaymentSecret'];
    paymentAmount = json['PaymentAmount'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['FacilityBookingId'] = this.facilityBookingId;
    data['FacilityBookingFreezeId'] = this.facilityBookingFreezeId;
    data['TransactionDate'] = this.transactionDate;
    data['EndUserId'] = this.endUserId;
    data['FacilitySetupDetailId'] = this.facilitySetupDetailId;
    data['PaymentSecret'] = this.paymentSecret;
    data['PaymentAmount'] = this.paymentAmount;
    return data;
  }
}
