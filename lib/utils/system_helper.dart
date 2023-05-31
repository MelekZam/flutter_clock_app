import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;

const channel = MethodChannel("com.example.app_test/mychannel");

void clearStatusBar() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

void removeStatusBar() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
}

void restoreStatusBar() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

void actionOnStatusBar(bool isPortrait) {
  if (isPortrait) {
    restoreStatusBar();
  } else {
    removeStatusBar();
  }
}

void setPreferredOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

Future<List<String>> getRingstones() async {
  final List<String> filteredRingtones = [];
  const channel = MethodChannel("com.example.app_test/mychannel");
  List ringtones = await channel.invokeMethod('getAllRingtones');
  for (final ringtone in ringtones) {
    if (await io.File('/system/media/audio/ringtones/$ringtone.ogg').exists()) {
      filteredRingtones.add(ringtone);
    }
  }
  return filteredRingtones;
}

void keepScreenAwake() {
  try {
    channel.invokeMethod("keepAwake");
  } catch (e) {}
}

void removeScreenAwake() {
  try {
    channel.invokeMethod("removeAwake");
  } catch (e) {}
}

Future<double?> getBrightness() async {
  double? brightness;
  try {
    brightness = await channel.invokeMethod("getBrightness");
  } catch (e) {}
  return brightness;
}

Future<void> setBrightness(double brightness) async {
  try {
    await channel.invokeMethod("setBrightness", {'brightness': brightness});
  } catch (e) {}
}
