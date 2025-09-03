/// FileStorageId : 4
/// FileName : "sdg.png"
/// FilePath : "https://okudo-api-uat.azurewebsites.net//Files/sdg637944916051624512.png"
/// FileExtension : "png"
/// CreatedBy : 1
/// CreatedAt : "2022-07-27T04:06:45.1780072+00:00"
/// CreatedUser : null

class UploadFileResponse {
  int? FileStorageId;
  String? FileName;
  String? FilePath;
  String? FileExtension;
  int? CreatedBy;
  String? CreatedAt;
  dynamic? CreatedUser;

  static UploadFileResponse? fromMap(Map<String, dynamic> map) {
    UploadFileResponse uploadFileResponseBean = UploadFileResponse();
    uploadFileResponseBean.FileStorageId = map['FileStorageId'];
    uploadFileResponseBean.FileName = map['FileName'];
    uploadFileResponseBean.FilePath = map['FilePath'];
    uploadFileResponseBean.FileExtension = map['FileExtension'];
    uploadFileResponseBean.CreatedBy = map['CreatedBy'];
    uploadFileResponseBean.CreatedAt = map['CreatedAt'];
    uploadFileResponseBean.CreatedUser = map['CreatedUser'];
    return uploadFileResponseBean;
  }

  Map toJson() => {
        "FileStorageId": FileStorageId,
        "FileName": FileName,
        "FilePath": FilePath,
        "FileExtension": FileExtension,
        "CreatedBy": CreatedBy,
        "CreatedAt": CreatedAt,
        "CreatedUser": CreatedUser,
      };
}
