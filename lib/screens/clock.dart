import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_test/main.dart';
import 'package:app_test/state/alarms_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/time_formatter.dart' show TimeFormatter;
import '../utils/system_helper.dart' as sys_helper;

class Clock extends ConsumerStatefulWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  ConsumerState<Clock> createState() => _ClockState();
}

class _ClockState extends ConsumerState<Clock> {
  final ValueNotifier<DateTime> _now = ValueNotifier<DateTime>(DateTime.now());
  Timer? _timer;
  bool _audioActive = false;
  final player = AudioPlayer();
  double? _brightness;

  @override
  void initState() {
    initBirghtness();
    sys_helper.keepScreenAwake();
    _now.addListener(onDateChanged);
    final DateTime currentTime = DateTime.now();
    final int secondsDiff = 60 - currentTime.second;
    _now.value = currentTime;
    Future.delayed(Duration(seconds: secondsDiff), () {
      _now.value = DateTime.now();
      updateTime();
    });
    super.initState();
  }

  @override
  void dispose() async {
    _now.removeListener(onDateChanged);
    sys_helper.removeScreenAwake();
    _timer?.cancel();
    Future.delayed(Duration.zero, () async {
      await player.stop();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = ref.watch(settingsProvider).clockColor;
    final hourFormat = ref.watch(settingsProvider).hourFormat;
    final nextAlarm = ref.watch(alarmsProvider.notifier).nextAlarm;
    return GestureDetector(
        onHorizontalDragUpdate: (details) =>
            {setBrightness(details.primaryDelta!)},
        child: Scaffold(
          body: Stack(children: [
            ValueListenableBuilder<DateTime>(
              builder: (BuildContext context, _, __) {
                return Center(
                    child: Text(
                  TimeFormatter.getTime(_now.value, hourFormat),
                  style: GoogleFonts.bungeeShade(
                      textStyle: TextStyle(
                          fontSize: 105,
                          color: color != null ? Color(color) : null)),
                ));
              },
              valueListenable: _now,
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: IconButton(
                icon: Icon(
                    nextAlarm == null
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_active_outlined,
                    size: 40,
                    color: color != null ? Color(color) : null),
                onPressed: () {
                  if (nextAlarm == null) return;
                  int minutesLeft = ref
                      .read(alarmsProvider.notifier)
                      .calculateDistance(nextAlarm, DateTime.now());
                  var snackBar = SnackBar(
                      content:
                          Text('$minutesLeft minutes left until next alarm!'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            )
          ]),
        ));
  }

  void updateTime() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _now.value = DateTime.now();
    });
  }

  void playAlarm() async {
    final ringtone = ref.read(settingsProvider.notifier).ringtone;
    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(
          DeviceFileSource('/system/media/audio/ringtones/$ringtone.ogg'));
      setState(() {
        _audioActive = true;
      });
    } catch (ex) {}
  }

  void onDateChanged() {
    final Alarm? nextAlarm = ref.read(alarmsProvider.notifier).nextAlarm;
    if (nextAlarm?.hour == (_now.value).hour &&
        nextAlarm?.minute == (_now.value).minute &&
        !_audioActive) {
      playAlarm();
      Future.delayed(const Duration(seconds: 1), () {
        ref.read(alarmsProvider.notifier).deactivateAlarm(nextAlarm!);
      });
    }
  }

  Future<void> initBirghtness() async {
    try {
      final brightness = await sys_helper.getBrightness();
      setState(() {
        _brightness = brightness;
      });
    } catch (e) {}
  }

  Future<void> setBrightness(double value) async {
    try {
      if (value < 0) {
        if (_brightness! < 0.01) return;
        await sys_helper.setBrightness(_brightness! - 0.01);
        setState(() {
          _brightness = _brightness! - 0.01;
        });
      } else if (value > 0) {
        if (_brightness! > 9.99) return;
        await sys_helper.setBrightness(_brightness! + 0.01);
        setState(() {
          _brightness = _brightness! + 0.01;
        });
      }
    } catch (e) {}
  }
}
