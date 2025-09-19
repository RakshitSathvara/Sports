import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';

class DurationInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onDurationChanged;
  final Function()? onDurationChangeStarted;
  final String hintText;
  final bool showError;
  final String labelText;
  final bool readOnly;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const DurationInputField({
    super.key,
    required this.controller,
    this.onDurationChanged,
    this.onDurationChangeStarted,
    this.hintText = '--:--',
    this.showError = true,
    this.labelText = 'Duration',
    this.readOnly = false,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<DurationInputField> createState() => DurationInputFieldState();
}

class DurationInputFieldState extends State<DurationInputField> {
  Duration? _selectedDuration;
  String? _errorText;
  bool _hasNotifiedChangeStarted = false;

  bool get hasError => _errorText != null;
  String? get errorMessage => _errorText;

  @override
  void initState() {
    super.initState();
    // Parse initial duration if exists
    if (widget.controller.text.isNotEmpty) {
      _parseDurationString(widget.controller.text);
    }
  }

  // Parse duration string to Duration object
  Duration? _parseDurationString(String durationString) {
    try {
      final parts = durationString.trim().split(':');
      if (parts.length == 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);

        if (hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59) {
          return Duration(hours: hours, minutes: minutes);
        }
      }
    } catch (e) {
      // Invalid format
    }
    return null;
  }

  // Validate duration range (1-12 hours)
  bool _isValidDurationRange(Duration duration) {
    final totalMinutes = duration.inMinutes;
    const minMinutes = 60; // 1 hour
    const maxMinutes = 720; // 12 hours
    
    return totalMinutes >= minMinutes && totalMinutes <= maxMinutes;
  }

  // Get validation error message
  String _getDurationErrorMessage() {
    if (_selectedDuration != null) {
      if (!_isValidDurationRange(_selectedDuration!)) {
        return 'Rental Duration must be between 1 hour and 12 hours';
      }
    }
    return 'Invalid duration format';
  }

  // Public method to set duration programmatically
  void setDuration(String durationString) {
    if (mounted) {
      setState(() {
        _errorText = null;
        widget.controller.text = durationString;
      });
      _validateAndSetDuration(durationString);
      if (widget.onDurationChanged != null) {
        widget.onDurationChanged!(durationString);
      }
    }
  }

  // Public method to set duration programmatically and trigger change callback
  void setDurationWithCallback(String durationString) {
    if (mounted) {
      // Store previous value if callback is provided
      if (widget.onDurationChangeStarted != null) {
        widget.onDurationChangeStarted!();
      }
      
      setState(() {
        _errorText = null;
        widget.controller.text = durationString;
      });
      _validateAndSetDuration(durationString);
      
      if (widget.onDurationChanged != null) {
        widget.onDurationChanged!(durationString);
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

  // Reset the change notification flag
  void _resetChangeNotificationFlag() {
    _hasNotifiedChangeStarted = false;
  }

  void _validateAndSetDuration(String durationString) {
    setState(() {
      _errorText = null;
    });

    try {
      final duration = _parseDurationString(durationString);
      if (duration != null) {
        if (_isValidDurationRange(duration)) {
          _selectedDuration = duration;
        } else {
          _selectedDuration = duration; // Keep for error message
          if (widget.showError) {
            setState(() {
              _errorText = _getDurationErrorMessage();
            });
          }
          _selectedDuration = null; // Reset as invalid
        }
      } else {
        _selectedDuration = null;
        if (widget.showError) {
          setState(() {
            _errorText = 'Invalid duration format.';
          });
        }
      }
    } catch (e) {
      _selectedDuration = null;
      if (widget.showError) {
        setState(() {
          _errorText = 'Invalid duration format.';
        });
      }
    }
  }


  String _formatDurationInput(String input) {
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
      if (firstDigit > 1) {
        // If first digit is > 1, treat first digit as hour and remaining as minutes
        return '0${digitsOnly[0]}:${digitsOnly.substring(1)}';
      } else {
        // If first digit is <= 1, treat first two digits as hour
        return '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2)}';
      }
    } else {
      // 4 digits: HH:MM format
      return '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2)}';
    }
  }

  bool _isValidDurationFormat(String durationStr) {
    if (!durationStr.contains(':') || durationStr.length != 5) {
      return false;
    }

    final parts = durationStr.split(':');
    if (parts.length != 2) {
      return false;
    }

    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      // Validate ranges
      return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59;
    } catch (e) {
      return false;
    }
  }

  void _onTextChanged(String value) {
    if (widget.readOnly) return;

    // Notify that duration change has started (only once per editing session)
    if (!_hasNotifiedChangeStarted && widget.onDurationChangeStarted != null) {
      widget.onDurationChangeStarted!();
      _hasNotifiedChangeStarted = true;
    }

    // Get current cursor position
    int cursorPosition = widget.controller.selection.start;
    String originalText = widget.controller.text;

    // Format the input
    String formatted = _formatDurationInput(value);

    // Calculate new cursor position
    int newCursorPosition;
    if (originalText.length < formatted.length) {
      newCursorPosition = cursorPosition + (formatted.length - value.length);
    } else if (originalText.length > formatted.length) {
      newCursorPosition = cursorPosition - (originalText.length - formatted.length);
    } else {
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

    // Validate the duration
    setState(() {
      _errorText = null;
    });

    if (formatted.isNotEmpty) {
      if (formatted.length == 5 && formatted.contains(':')) {
        // Complete duration format - validate
        if (_isValidDurationFormat(formatted)) {
          final duration = _parseDurationString(formatted);
          if (duration != null) {
            if (_isValidDurationRange(duration)) {
              _selectedDuration = duration;
            } else {
              _selectedDuration = duration; // Keep for error message
              setState(() {
                if (widget.showError) {
                  _errorText = _getDurationErrorMessage();
                }
              });
              _selectedDuration = null; // Reset as invalid
            }
          }
        } else {
          setState(() {
            if (widget.showError) {
              _errorText = 'Invalid duration format.';
            }
          });
        }
      } else {
        // Incomplete duration format
        setState(() {
          if (widget.showError) {
            _errorText = 'Incomplete duration format. Please enter HH:MM';
          }
        });
      }
    }

    if (widget.onDurationChanged != null) {
      widget.onDurationChanged!(formatted);
    }
  }

  // Default validator that uses the existing validation logic
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter duration';
    }

    // Check if it's a complete duration format
    if (value.length != 5 || !value.contains(':')) {
      return 'Please enter duration in HH:MM format';
    }

    // Parse the duration
    final duration = _parseDurationString(value);
    if (duration == null) {
      return 'Invalid duration format';
    }

    // Check if duration is within valid range
    if (!_isValidDurationRange(duration)) {
      return 'Rental Duration must be between 1 hour and 12 hours';
    }

    return null; // No error
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator ?? _defaultValidator,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      initialValue: widget.controller.text,
      builder: (FormFieldState<String> field) {
        // Update field value when controller changes
        if (field.value != widget.controller.text) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            field.didChange(widget.controller.text);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.labelText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorsUtils.chipText,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: field.hasError ? ColorsUtils.redColor : ColorsUtils.borderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(6),
                color: widget.readOnly ? ColorsUtils.buttonColorGrey : ColorsUtils.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          // Reset the change notification flag when focus is lost
                          _resetChangeNotificationFlag();
                          // Trigger form field validation
                          field.didChange(widget.controller.text);
                        }
                      },
                      child: TextField(
                        enableInteractiveSelection: !widget.readOnly,
                        readOnly: widget.readOnly,
                        controller: widget.controller,
                        onChanged: (value) {
                          _onTextChanged(value);
                          field.didChange(value);
                        },
                        inputFormatters: widget.readOnly 
                            ? [] 
                            : [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                                LengthLimitingTextInputFormatter(5), // Limit to "HH:MM" format
                              ],
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.readOnly ? ColorsUtils.textGray : ColorsUtils.black,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: ColorsUtils.hintTextColor,
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
                        keyboardType: widget.readOnly ? TextInputType.none : TextInputType.number,
                      ),
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: widget.readOnly ? null : _selectDuration,
                  //   child: Container(
                  //     width: 48,
                  //     height: 48,
                  //     decoration: BoxDecoration(
                  //       color: widget.readOnly 
                  //           ? ColorsUtils.buttonColorGrey 
                  //           : ColorsUtils.buttonBg,
                  //       borderRadius: const BorderRadius.only(
                  //         topRight: Radius.circular(6),
                  //         bottomRight: Radius.circular(6),
                  //       ),
                  //     ),
                  //     padding: const EdgeInsets.all(8),
                  //     child: Center(
                  //       child: Icon(
                  //         Icons.access_time,
                  //         size: 20,
                  //         color: widget.readOnly 
                  //             ? ColorsUtils.textGray 
                  //             : ColorsUtils.black,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 4),
              Text(
                field.errorText!,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorsUtils.redColor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
