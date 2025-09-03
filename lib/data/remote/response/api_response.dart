import 'status.dart';

class ApiResponse<ResultType> {
  Status? state;
  ResultType? data;
  String? message;

  ApiResponse({this.state, this.data, this.message});

  static ApiResponse<ResultType> loading<ResultType>() {
    return ApiResponse(state: Status.LOADING);
  }

  static ApiResponse<ResultType> complete<ResultType>(ResultType data) {
    return ApiResponse(state: Status.COMPLETED, data: data);
  }

  static ApiResponse<ResultType> error<ResultType>(String exception) {
    return ApiResponse(state: Status.ERROR, message: exception);
  }
}
