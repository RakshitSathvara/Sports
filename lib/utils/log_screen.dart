import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';
import 'package:oqdo_mobile_app/utils/utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileName;
  final DateTime date;

  FileViewerScreen({required this.fileName, required this.date});

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  final FileHandler fileHandler = FileHandler();
  String fileContent = '';

  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  Future<void> _loadFileContent() async {
    String content = await fileHandler.readFromFile(widget.fileName, widget.date);
    setState(() {
      fileContent = content;
    });
  }

  Future<void> _downloadFile() async {
    // Request storage permission

    var status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      try {
        // Get the downloads directory
        Directory? downloadsDirectory;
        if (Platform.isAndroid) {
          downloadsDirectory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

        if (downloadsDirectory != null) {
          final File file = File('${downloadsDirectory.path}/${widget.fileName}');

          // Write the file content
          await file.writeAsString(fileContent);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File downloaded successfully to ${file.path}')),
          );
        } else {
          throw Exception('Could not access the downloads directory');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    } else if (status == PermissionStatus.denied) {
      if (status == PermissionStatus.granted) {
        try {
          // Get the downloads directory
          Directory? downloadsDirectory;
          if (Platform.isAndroid) {
            downloadsDirectory = Directory('/storage/emulated/0/Download');
          } else if (Platform.isIOS) {
            downloadsDirectory = await getApplicationDocumentsDirectory();
          }

          if (downloadsDirectory != null) {
            final File file = File('${downloadsDirectory.path}/${widget.fileName}');

            // Write the file content
            await file.writeAsString(fileContent);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File downloaded successfully to ${file.path}')),
            );
          } else {
            throw Exception('Could not access the downloads directory');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading file: $e')),
          );
        }
      } else {
        showSnackBar('Permission denied.Please Allow Permission.', context);
      }
    } else if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadFile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(fileContent),
        ),
      ),
    );
  }
}
