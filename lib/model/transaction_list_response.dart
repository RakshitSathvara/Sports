class TransactionListResponse {
  List<Transaction>? data;
  int? totalCount;
  int? pageStart;
  int? resultPerPage;

  TransactionListResponse({this.data, this.totalCount, this.pageStart, this.resultPerPage});

  TransactionListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = <Transaction>[];
      json['Data'].forEach((v) {
        data!.add(Transaction.fromJson(v));
      });
    }
    totalCount = json['TotalCount'];
    pageStart = json['PageStart'];
    resultPerPage = json['ResultPerPage'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['TotalCount'] = totalCount;
    data['PageStart'] = pageStart;
    data['ResultPerPage'] = resultPerPage;
    return data;
  }
}

class Transaction {
  int? id;
  bool? isCoachBooking;
  int? bookingId;
  String? bookingNo;
  int? bookingSrNo;
  int? endUserId;
  int? setupDetailId;
  int? subActivityId;
  double? totalAmt;
  String? transactionDate;
  String? firstName;
  String? lastName;
  String? setupName;
  String? paymentStatus;
  String? createdAt;

  Transaction({
    this.id,
    this.isCoachBooking,
    this.bookingId,
    this.bookingNo,
    this.bookingSrNo,
    this.endUserId,
    this.setupDetailId,
    this.subActivityId,
    this.totalAmt,
    this.transactionDate,
    this.firstName,
    this.lastName,
    this.setupName,
    this.paymentStatus,
    this.createdAt,
  });

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    isCoachBooking = json['IsCoachBooking'];
    bookingId = json['BookingId'];
    bookingNo = json['BookingNo'];
    bookingSrNo = json['BookingSrNo'];
    endUserId = json['EndUserId'];
    setupDetailId = json['SetupDetailId'];
    subActivityId = json['SubActivityId'];
    totalAmt = json['TotalAmt'];
    transactionDate = json['TransactionDate'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    setupName = json['SetupName'];
    paymentStatus = json['PaymentStatus'];
    createdAt = json['CreatedAt'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['IsCoachBooking'] = isCoachBooking;
    data['BookingId'] = bookingId;
    data['BookingNo'] = bookingNo;
    data['BookingSrNo'] = bookingSrNo;
    data['EndUserId'] = endUserId;
    data['SetupDetailId'] = setupDetailId;
    data['SubActivityId'] = subActivityId;
    data['TotalAmt'] = totalAmt;
    data['TransactionDate'] = transactionDate;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['SetupName'] = setupName;
    data['PaymentStatus'] = paymentStatus;
    data['CreatedAt'] = createdAt;
    return data;
  }
}
