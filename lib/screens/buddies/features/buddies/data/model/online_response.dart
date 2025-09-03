class OnlineResponse {
  int? endUserId;
  String? status;

  OnlineResponse({this.endUserId, this.status});

  OnlineResponse.fromJson(Map<String, dynamic> json) {
    endUserId = json['EndUserId'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['EndUserId'] = endUserId;
    data['Status'] = status;
    return data;
  }
}
