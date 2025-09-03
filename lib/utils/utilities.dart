import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Utils {
  static Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return const Color(0xFFD9D9D9);
    }
    return const Color(0xFFD9D9D9);
  }
}

Color parseColor(String color) {
  String hex = color.replaceAll("#", "");
  if (hex.isEmpty) hex = "ffffff";
  if (hex.length == 3) {
    hex = '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
  }
  Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
  return col;
}

Color getColor(Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return const Color(0xFFD9D9D9);
  }
  return const Color(0xFFD9D9D9);
}

String formatDuration(Duration duration) {
  String hours = duration.inHours.toString().padLeft(0, '2');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  return "$hours:$minutes";
}

String getEndTimeInVisibleFormat(int endTimeMinutes) {
  int hour = endTimeMinutes ~/ 60;
  int minutes = endTimeMinutes % 60;
  return '${hour.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}';
}

final kToday = DateTime.now();
final kPreviousDay = DateTime(kToday.year, kToday.month, kToday.day - 89);
final kFirstDay = DateTime(kToday.year, kToday.month, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month, kToday.day + 89);
final kLastOfCalendarDay = DateTime(kToday.year, 12, 31);
const urlTag = 'URL -> ';
const responseTag = 'RESPONSE -> ';
const requestTag = 'REQUEST -> ';

String convertDateTimeToString(DateTime selectedDate) {
  String convertedDate = '';
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  convertedDate = dateFormat.format(selectedDate);
  debugPrint('converted date -> $convertedDate');
  return convertedDate;
}

String convertToStringFromDate(String date) {
  return date.split('T')[0];
}

Future<File> downloadFile(String url, String fileName) async {
  // Get the application documents directory
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';

  // Make the HTTP request
  final response = await http.get(Uri.parse(url));

  // Check if the request was successful
  if (response.statusCode == 200) {
    // Write the file to disk
    final file = File(filePath);
    return file.writeAsBytes(response.bodyBytes);
  } else {
    throw Exception('Failed to download file');
  }
}

enum HomeScreenSelection { Sports, Hobbies, Wellness }

class FileHandler {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> _dateWiseDirectory(DateTime date) async {
    final basePath = await _localPath;
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final dirPath = '$basePath/$dateString';
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _localFile(String fileName, DateTime date) async {
    final dir = await _dateWiseDirectory(date);
    return File('${dir.path}/$fileName');
  }

  Future<File> writeToFile(String fileName, String content, {DateTime? date}) async {
    date ??= DateTime.now();
    final file = await _localFile(fileName, date);
    return file.writeAsString(content); // This overwrites the file
  }

  Future<String> readFromFile(String fileName, DateTime date) async {
    try {
      final file = await _localFile(fileName, date);
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  Future<List<String>> listFiles(DateTime date) async {
    final dir = await _dateWiseDirectory(date);
    List<FileSystemEntity> files = await dir.list().toList();
    return files.whereType<File>().map((file) => file.path.split('/').last).toList();
  }

  Future<void> deleteFile(String fileName, DateTime date) async {
    final file = await _localFile(fileName, date);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
