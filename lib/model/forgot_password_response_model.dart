class ForgotPasswordResponseModel {
  bool? success;
  String? message;

  ForgotPasswordResponseModel({
    this.success,
    this.message,
  });

  ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json['success'] = success;
    json['message'] = message;
    return json;
  }
}
