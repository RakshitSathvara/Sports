import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:oqdo_mobile_app/utils/custom_text_view.dart';

class CountdownTimerWidget extends StatefulWidget {
  final Function onFinish;
  final Function(int remainingSeconds)? onTimerUpdate;

  const CountdownTimerWidget({Key? key, required this.onFinish, this.onTimerUpdate}) : super(key: key);

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  late StreamSubscription<FGBGType> subscription;

  Duration bookingTimeDuration = const Duration(minutes: 5);
  late DateTime bookingStartTime;

  @override
  void initState() {
    super.initState();

    bookingStartTime = DateTime.now();
    _startTimer();

    subscription = FGBGEvents.instance.stream.listen((event) {
      debugPrint("FGBGEvents :===> event : ${(event.name)}");
      if (event == FGBGType.foreground) {
        _timer?.cancel();
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    debugPrint('AUTO-CANCELLED TIMER AT ${getDisplayTime()}');
    subscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final timerDifference = DateTime.now().difference(bookingStartTime);
        if (timerDifference.inSeconds >= bookingTimeDuration.inSeconds) {
          _timer?.cancel();
          widget.onFinish(); // Call the callback when time is complete
        } else {
          if (widget.onTimerUpdate != null) {
            final remainingSeconds = bookingTimeDuration.inSeconds - timerDifference.inSeconds;
            widget.onTimerUpdate!(remainingSeconds);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextView(
      label: 'Time remaining ${getDisplayTime()} minutes',
      textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(color: OQDOThemeData.greyColor, fontSize: 16, fontWeight: FontWeight.w400),
    );
  }

  String getDisplayTime() {
    final timerDifference = DateTime.now().difference(bookingStartTime);
    final remainingSeconds = bookingTimeDuration.inSeconds - timerDifference.inSeconds;

    if (remainingSeconds <= 0) {
      return '0:00';
    }

    int minutes = (remainingSeconds / 60).floor();
    int seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
