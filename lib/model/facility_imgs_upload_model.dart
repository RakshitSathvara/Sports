class FacilityImagesUploadModel {
  int? FileStorageId;
  String? FileName;
  String? FilePath;
  String? FileExtension;
  String? FileBase64;

  FacilityImagesUploadModel(
      {this.FileStorageId,
      this.FileName,
      this.FilePath,
      this.FileExtension,
      this.FileBase64});
}
