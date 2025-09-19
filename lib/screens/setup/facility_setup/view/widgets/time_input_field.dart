import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/theme/custom_colors.dart';
import 'package:oqdo_mobile_app/utils/constants.dart';

class TimeInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onTimeChanged;
  final String hintText;
  final bool showError;
  final String? startTime; // Dynamic start time in HH:MM format
  final String? endTime; // Dynamic end time in HH:MM format
  final int? slotDuration; // Slot duration in hours

  const TimeInputField({
    super.key,
    required this.controller,
    this.onTimeChanged,
    this.hintText = '--:--',
    this.showError = true,
    this.startTime = '06:00', // Default start time
    this.endTime = '22:00', // Default end time
    this.slotDuration, // Slot duration in hours
  });

  @override
  State<TimeInputField> createState() => TimeInputFieldState();
}

class TimeInputFieldState extends State<TimeInputField> {
  TimeOfDay? _selectedTime;
  String? _errorText;

  bool get hasError => _errorText != null;

  String? get errorMessage => _errorText;

  @override
  void initState() {
    super.initState();
    // Parse initial time if exists
    if (widget.controller.text.isNotEmpty) {
      _parseTimeString(widget.controller.text);
    }
  }

  // Convert time string to TimeOfDay for comparison
  TimeOfDay? _parseTimeToTimeOfDay(String timeString) {
    try {
      final timeParts = timeString.trim().split(':');
      if (timeParts.length == 2) {
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // Invalid format
    }
    return null;
  }

  // Compare two TimeOfDay objects
  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return minutes1.compareTo(minutes2);
  }

  // Add slot duration to a given time
  TimeOfDay _addSlotDuration(TimeOfDay time, int slotDurationHours) {
    int totalMinutes = (time.hour * 60 + time.minute) + (slotDurationHours * 60);
    int newHour = (totalMinutes ~/ 60) % 24;
    int newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  // Check if slot fits within the allowed time range
  bool _doesSlotFitInTimeRange(TimeOfDay startTime) {
    if (widget.slotDuration == null) {
      return _isTimeInRange(startTime); // Fall back to original validation
    }

    // Check if start time is within basic range
    if (!_isTimeInRange(startTime)) {
      return false;
    }

    // Calculate end time of the slot
    TimeOfDay slotEndTime = _addSlotDuration(startTime, widget.slotDuration!);

    // Get the end time constraint
    final endTimeOfDay = widget.endTime != null ? _parseTimeToTimeOfDay(widget.endTime!) : null;

    if (endTimeOfDay != null) {
      // Check if slot end time exceeds the allowed end time
      // Handle day overflow - if slot end time is earlier in the day than start time, it means it went to next day
      if (slotEndTime.hour < startTime.hour || (slotEndTime.hour == startTime.hour && slotEndTime.minute < startTime.minute)) {
        return false; // Slot goes to next day, which is not allowed
      }

      if (_compareTimeOfDay(slotEndTime, endTimeOfDay) > 0) {
        return false; // Slot end time is after allowed end time
      }
    }

    return true;
  }

  // Validate time against start and end time constraints
  bool _isTimeInRange(TimeOfDay time) {
    if (widget.startTime == null && widget.endTime == null) {
      return true; // No constraints
    }

    final startTimeOfDay = widget.startTime != null ? _parseTimeToTimeOfDay(widget.startTime!) : null;
    final endTimeOfDay = widget.endTime != null ? _parseTimeToTimeOfDay(widget.endTime!) : null;

    if (startTimeOfDay != null && _compareTimeOfDay(time, startTimeOfDay) < 0) {
      return false; // Time is before start time
    }

    if (endTimeOfDay != null && _compareTimeOfDay(time, endTimeOfDay) > 0) {
      return false; // Time is after end time
    }

    return true;
  }

  // Get validation error message for time range and slot duration
  String _getTimeRangeErrorMessage() {
    if (widget.slotDuration != null && _selectedTime != null) {
      TimeOfDay slotEndTime = _addSlotDuration(_selectedTime!, widget.slotDuration!);
      final endTimeOfDay = widget.endTime != null ? _parseTimeToTimeOfDay(widget.endTime!) : null;

      // Check if slot goes to next day
      if (slotEndTime.hour < _selectedTime!.hour || (slotEndTime.hour == _selectedTime!.hour && slotEndTime.minute < _selectedTime!.minute)) {
        return 'Slot mus be end on or before ${widget.endTime}';
      }

      if (endTimeOfDay != null && _compareTimeOfDay(slotEndTime, endTimeOfDay) > 0) {
        return 'Slot mus be end on or before ${widget.endTime}';
      }
    }

    // Fall back to original error messages
    if (widget.startTime != null) {
      return 'Every slot must be start on or after ${widget.startTime}';
    } else if (widget.endTime != null) {
      return 'Every slot must be end on or before ${widget.endTime}';
    }
    return 'Invalid time range';
  }

  // Public method to set time programmatically (for pre-defined time buttons)
  void setTime(String timeString) {
    if (mounted) {
      setState(() {
        _errorText = null; // Clear any existing errors
        widget.controller.text = timeString;
      });
      _parseTimeString(timeString);
      if (widget.onTimeChanged != null) {
        widget.onTimeChanged!(timeString);
      }
    }
  }

  // Public method to clear errors
  void clearError() {
    if (mounted) {
      setState(() {
        _errorText = null;
      });
    }
  }

  void _parseTimeString(String timeString) {
    setState(() {
      _errorText = null;
    });

    try {
      // Parse time string in 24-hour format "HH:mm"
      final timeParts = timeString.trim().split(':');
      if (timeParts.length == 2) {
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        // Validate hour and minute ranges
        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          final timeOfDay = TimeOfDay(hour: hour, minute: minute);

          // Validate against start and end time constraints and slot duration
          if (widget.slotDuration != null) {
            if (_doesSlotFitInTimeRange(timeOfDay)) {
              _selectedTime = timeOfDay;
            } else {
              _selectedTime = timeOfDay; // Set selected time for error message calculation
              if (widget.showError) {
                setState(() {
                  _errorText = _getTimeRangeErrorMessage();
                });
              }
              _selectedTime = null; // Reset selected time as it's invalid
            }
          } else {
            // Original validation without slot duration
            if (_isTimeInRange(timeOfDay)) {
              _selectedTime = timeOfDay;
            } else {
              _selectedTime = null;
              if (widget.showError) {
                setState(() {
                  _errorText = _getTimeRangeErrorMessage();
                });
              }
            }
          }
        } else {
          _selectedTime = null;
          if (widget.showError) {
            setState(() {
              _errorText = 'Invalid start time.';
            });
          }
        }
      }
    } catch (e) {
      // Invalid time format, keep _selectedTime as null
      _selectedTime = null;
      if (widget.showError) {
        setState(() {
          _errorText = 'Invalid time format.';
        });
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime() async {
    // Get initial time for time picker
    TimeOfDay initialTime = _selectedTime ?? TimeOfDay.now();

    // If current time is outside the allowed range, set initial time to start time
    bool isCurrentTimeValid = widget.slotDuration != null ? _doesSlotFitInTimeRange(initialTime) : _isTimeInRange(initialTime);

    if (!isCurrentTimeValid && widget.startTime != null) {
      final startTimeOfDay = _parseTimeToTimeOfDay(widget.startTime!);
      if (startTimeOfDay != null) {
        initialTime = startTimeOfDay;
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
                dayPeriodTextColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      hideKeyboard();

      // Validate picked time against constraints and slot duration
      bool isValidTime = widget.slotDuration != null ? _doesSlotFitInTimeRange(picked) : _isTimeInRange(picked);

      if (isValidTime) {
        setState(() {
          _selectedTime = picked;
          widget.controller.text = _formatTimeOfDay(picked);
          _errorText = null; // Clear error when valid time is selected from picker
        });
        if (widget.onTimeChanged != null) {
          widget.onTimeChanged!(widget.controller.text);
        }
      } else {
        // Set temporary selected time for error message calculation
        _selectedTime = picked;
        String errorMessage = _getTimeRangeErrorMessage();
        widget.controller.text = _formatTimeOfDay(picked);

        // Show error for invalid time selection from picker
        setState(() {
          _errorText = errorMessage;
        });

        // Show a snackbar or dialog to inform user about the constraint
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).extension<CustomColors>()!.redColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  String _formatTimeInput(String input) {
    // Remove all non-digit characters
    String digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 4 digits maximum
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    if (digitsOnly.isEmpty) {
      return '';
    }

    // Handle different input patterns
    if (digitsOnly.length == 1) {
      return digitsOnly;
    } else if (digitsOnly.length == 2) {
      return digitsOnly;
    } else if (digitsOnly.length == 3) {
      // Handle cases like "900" -> "09:00"
      int firstDigit = int.parse(digitsOnly[0]);
      if (firstDigit > 2) {
        // If first digit is > 2, treat first digit as hour and remaining as minutes
        return '0${digitsOnly[0]}:${digitsOnly.substring(1)}';
      } else {
        // If first digit is <= 2, treat first two digits as hour
        return '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2)}';
      }
    } else {
      // 4 digits: HH:MM format
      return '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2)}';
    }
  }

  bool _isValidTime(String timeStr) {
    if (!timeStr.contains(':') || timeStr.length != 5) {
      return false;
    }

    final parts = timeStr.split(':');
    if (parts.length != 2) {
      return false;
    }

    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Validate ranges
      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  void _onTextChanged(String value) {
    // Get current cursor position
    int cursorPosition = widget.controller.selection.start;
    String originalText = widget.controller.text;

    // Format the input
    String formatted = _formatTimeInput(value);

    // Calculate new cursor position based on the formatting transformation
    int newCursorPosition;

    // Special handling for different formatting scenarios
    if (originalText.length < formatted.length) {
      // Text expanded (colon was added or formatting occurred)
      String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

      if (digitsOnly.length == 3 && formatted.length == 5) {
        // Special case: 3 digits became "HH:MM" format (like "700" -> "07:00")
        // Position cursor at the end
        newCursorPosition = formatted.length;
      } else if (digitsOnly.length == 4 && formatted.length == 5) {
        // Special case: 4 digits became "HH:MM" format (like "1530" -> "15:30")
        // Position cursor at the end
        newCursorPosition = formatted.length;
      } else {
        // Normal case: colon was inserted
        newCursorPosition = cursorPosition + (formatted.length - value.length);
      }
    } else if (originalText.length > formatted.length) {
      // Text contracted (characters were removed)
      newCursorPosition = cursorPosition - (originalText.length - formatted.length);
    } else {
      // Same length, maintain position
      newCursorPosition = cursorPosition;
    }

    // Ensure cursor position is within bounds
    newCursorPosition = newCursorPosition.clamp(0, formatted.length);

    // Update controller if the formatted text is different
    if (widget.controller.text != formatted) {
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );
    }

    // Validate the time
    setState(() {
      _errorText = null;
    });

    if (formatted.isNotEmpty) {
      if (formatted.length == 5 && formatted.contains(':')) {
        // Complete time format - validate time ranges and constraints
        if (_isValidTime(formatted)) {
          final timeOfDay = _parseTimeToTimeOfDay(formatted);
          if (timeOfDay != null) {
            bool isValidTime = widget.slotDuration != null ? _doesSlotFitInTimeRange(timeOfDay) : _isTimeInRange(timeOfDay);

            if (isValidTime) {
              _parseTimeString(formatted);
            } else {
              // Set temporary selected time for error message calculation
              _selectedTime = timeOfDay;
              setState(() {
                if (widget.showError) {
                  _errorText = _getTimeRangeErrorMessage();
                }
              });
              _selectedTime = null; // Reset as it's invalid
            }
          }
        } else {
          setState(() {
            if (widget.showError) {
              _errorText = 'Invalid start time.';
            }
          });
        }
      } else {
        // Incomplete time format - show format error
        setState(() {
          if (widget.showError) {
            _errorText = 'Incomplete time format. Please enter HH:MM';
          }
        });
      }
    }

    if (widget.onTimeChanged != null) {
      widget.onTimeChanged!(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: _errorText != null
                  ? Theme.of(context).extension<CustomColors>()!.redColor
                  : Theme.of(context).extension<CustomColors>()!.borderColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).extension<CustomColors>()!.containerBG,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enableInteractiveSelection: false,
                  controller: widget.controller,
                  onChanged: _onTextChanged,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    LengthLimitingTextInputFormatter(5), // Limit to "HH:MM" format
                  ],
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: Theme.of(context).extension<CustomColors>()!.hintTextColor,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              // GestureDetector(
              //   onTap: _selectTime,
              //   child: Container(
              //     width: 48,
              //     height: 48,
              //     decoration: BoxDecoration(
              //       color: ColorsUtils.buttonBg,
              //       borderRadius: const BorderRadius.only(
              //         topRight: Radius.circular(6),
              //         bottomRight: Radius.circular(6),
              //       ),
              //     ),
              //     padding: const EdgeInsets.all(8),
              //     child: Center(
              //       child: Image.asset(
              //         "assets/images/ic_time.png",
              //         width: 20,
              //         height: 20,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        if (_errorText != null && widget.showError) ...[
          const SizedBox(height: 4),
          Text(
            _errorText!,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).extension<CustomColors>()!.redColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
