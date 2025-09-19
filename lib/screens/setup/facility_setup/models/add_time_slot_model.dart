import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/models/grid_view_item_model.dart';
import 'package:oqdo_mobile_app/screens/setup/facility_setup/view/widgets/time_input_field.dart';

class AddTimeSlotModel {
  List<GridViewItemModel> selectedDays;
  TextEditingController startTime;
  TextEditingController numberOfSlots;
  int perSlotDuration;
  GlobalKey<TimeInputFieldState> startTimeControllerKey;
  GlobalKey<FormState> formKey;
  double? ratePerHour;
  String? startTimeFormatted;
  String? endTimeFormatted;

  int get tempNumberOfSlots => int.tryParse(numberOfSlots.text) ?? 0;

  int get totalDuration => (tempNumberOfSlots * perSlotDuration);

  String get startEndTimeText => calculateTimeRange(startTime.text, totalDuration);

  String get endTimeText => calculateEndTime(startTime.text, totalDuration);

  /// Calculate accurate end time using duration in minutes
  String getAccurateEndTime(int durationInMinutes) {
    try {
      // Parse the start time (expecting format like "14:00" or "14:30")
      List<String> timeParts = startTime.text.split(':');
      if (timeParts.length != 2) {
        return startTime.text;
      }

      int startHours = int.parse(timeParts[0]);
      int startMinutes = int.parse(timeParts[1]);

      // Validate time values
      if (startHours < 0 || startHours > 23 || startMinutes < 0 || startMinutes > 59) {
        return startTime.text;
      }

      // Calculate total duration in minutes for this slot
      final totalDurationMinutes = tempNumberOfSlots * durationInMinutes;

      // Convert start time to minutes
      int startTimeInMinutes = (startHours * 60) + startMinutes;

      // Add total duration
      int endTimeInMinutes = startTimeInMinutes + totalDurationMinutes;

      // Convert back to hours and minutes
      int endHours = (endTimeInMinutes ~/ 60) % 24;
      int endMinutes = endTimeInMinutes % 60;

      // Format the end time
      return '${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}';
    } catch (e) {
      // Return start time if any error occurs
      return startTime.text;
    }
  }

  /// Calculate accurate time range display using duration in minutes
  String getAccurateTimeRangeDisplay(int durationInMinutes) {
    final endTime = getAccurateEndTime(durationInMinutes);
    return '${startTime.text.trim()} → $endTime';
  }

  List<GridViewItemModel> get sortedSelectedDays => sortDaysMonFirst(selectedDays);

  /// Get formatted duration for display (e.g., "4h 30m" or "2h")
  String get formattedPerSlotDuration {
    // If perSlotDuration is in whole hours, format accordingly
    if (perSlotDuration <= 0) return '0h';
    
    // For now, we'll show just hours since perSlotDuration is stored as integer hours
    // In the future, this could be enhanced to show minutes if needed
    return perSlotDuration == 1 ? '1 hour' : '$perSlotDuration hours';
  }

  /// Calculate accurate time range using exact duration in minutes
  String getAccurateTimeRange(int rentalDurationInMinutes) {
    try {
      // Parse the start time (expecting format like "14:00" or "14:30")
      List<String> timeParts = startTime.text.split(':');
      if (timeParts.length != 2) {
        return startTime.text;
      }

      int startHours = int.parse(timeParts[0]);
      int startMinutes = int.parse(timeParts[1]);

      // Validate time values
      if (startHours < 0 || startHours > 23 || startMinutes < 0 || startMinutes > 59) {
        return startTime.text;
      }

      // Calculate total duration in minutes
      final totalDurationMinutes = tempNumberOfSlots * rentalDurationInMinutes;

      // Convert start time to minutes
      int startTimeInMinutes = (startHours * 60) + startMinutes;

      // Add total duration
      int endTimeInMinutes = startTimeInMinutes + totalDurationMinutes;

      // Convert back to hours and minutes
      int endHours = (endTimeInMinutes ~/ 60) % 24;
      int endMinutes = endTimeInMinutes % 60;

      // Format the end time
      String endTime = '${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}';

      return '${startTime.text} → $endTime';
    } catch (e) {
      // Return start time if any error occurs
      return startTime.text;
    }
  }

  int? get startTimeInMinutes => getTimeInMinutes(startTime.text);

  int? get endTimeInMinutes => getTimeInMinutes(endTimeText);

  AddTimeSlotModel({
    required this.selectedDays,
    required this.startTime,
    required this.formKey,
    required this.numberOfSlots,
    required this.perSlotDuration,
    required this.startTimeControllerKey,
    this.ratePerHour,
    this.startTimeFormatted,
    this.endTimeFormatted,
  });

  // Sort days in Monday-to-Sunday order
  List<GridViewItemModel> sortDaysMonFirst(List<GridViewItemModel> days) {
    const weekOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<GridViewItemModel> sortedDays = List.from(days);
    sortedDays.sort((a, b) {
      int indexA = weekOrder.indexOf(a.title);
      int indexB = weekOrder.indexOf(b.title);

      // Handle unknown days (put them at the end)
      if (indexA == -1) indexA = weekOrder.length;
      if (indexB == -1) indexB = weekOrder.length;

      return indexA.compareTo(indexB);
    });

    return sortedDays;
  }

  String calculateTimeRange(String startTime, int duration) {
    try {
      // Parse the start time (expecting format like "14:00" or "14:30")
      List<String> timeParts = startTime.split(':');
      if (timeParts.length != 2) {
        return startTime;
      }

      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);

      // Validate time values
      if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
        return startTime;
      }

      // Add duration to the start time
      int endHours = hours + duration;
      int endMinutes = minutes;

      // Handle day overflow (if end time goes past 23:59)
      if (endHours > 23) {
        endHours = endHours % 24;
      }

      // Format the end time
      String endTime = '${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}';

      return '$startTime - $endTime';
    } catch (e) {
      // Return start time if any error occurs
      return startTime;
    }
  }

  String calculateEndTime(String startTime, int duration) {
    try {
      // Parse the start time (expecting format like "14:00" or "14:30")
      List<String> timeParts = startTime.split(':');
      if (timeParts.length != 2) {
        return startTime;
      }

      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);

      // Validate time values
      if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
        return startTime;
      }

      // Add duration to the start time
      int endHours = hours + duration;
      int endMinutes = minutes;

      // Handle day overflow (if end time goes past 23:59)
      if (endHours > 23) {
        endHours = endHours % 24;
      }

      // Format the end time
      String endTime = '${endHours.toString().padLeft(2, '0')}:${endMinutes.toString().padLeft(2, '0')}';

      return endTime;
    } catch (e) {
      // Return start time if any error occurs
      return startTime;
    }
  }

  int? getTimeInMinutes(String time) {
    try {
      final mDateFormat = DateFormat('HH:mm');
      final mTime = mDateFormat.parse(time);
      return ((mTime.hour * 60) + mTime.minute);
    } catch (e) {
      debugPrint('Error in getTimeInMinutes ===============================================> $e');
      return null;
    }
  }
}
