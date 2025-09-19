import 'package:image_picker/image_picker.dart';

class SelectedImageModel {
  int serverId;
  XFile? image;
  String? editTimeImageUrl;

  SelectedImageModel({required this.serverId, this.image,this.editTimeImageUrl});
}
