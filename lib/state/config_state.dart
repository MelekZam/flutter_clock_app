import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

@immutable
class ConfigState {
  final String mode;
  final String hourFormat;
  final int? clockColor;
  final List ringtones;
  final String? activeRingtone;

  const ConfigState(this.mode, this.hourFormat, this.ringtones, this.clockColor,
      this.activeRingtone);

  ConfigState copyWith(
      {String? mode,
      String? hourFormat,
      List? ringtones,
      int? clockColor,
      String? activeRingtone}) {
    return ConfigState(
      mode ?? this.mode,
      hourFormat ?? this.hourFormat,
      ringtones ?? this.ringtones,
      clockColor ?? this.clockColor,
      activeRingtone ?? this.activeRingtone,
    );
  }
}

class ConfigStateNotifier extends StateNotifier<ConfigState> {
  ConfigStateNotifier()
      : super(const ConfigState('dark', '12-Hour', [], null, ''));

  void updateMode(isDark) {
    String newMode = isDark ? 'dark' : 'light';
    state = state.copyWith(mode: newMode);
    saveStateToLocalStorage();
  }

  void updateHourFormat(String hourFormat) {
    state = state.copyWith(hourFormat: hourFormat);
    saveStateToLocalStorage();
  }

  void setRingtones(List ringtones) {
    state = state.copyWith(ringtones: ringtones);
    saveStateToLocalStorage();
  }

  void setClockColor(int? clockColor) {
    state = state.copyWith(clockColor: clockColor);
    saveStateToLocalStorage();
  }

  void setActiveRingtone(String? ringtone) {
    state = state.copyWith(activeRingtone: ringtone);
    saveStateToLocalStorage();
  }

  String? get ringtone {
    return state.activeRingtone;
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': state.mode,
      'hourFormat': state.hourFormat,
      'ringtones': state.ringtones,
      'clockColor': state.clockColor,
      'activeRingtone': state.activeRingtone,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    state = ConfigState(json['mode'], json['hourFormat'], json['ringtones'],
        json['clockColor'], json['activeRingtone']);
  }

  Future<void> saveStateToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('configState', jsonEncode(toJson()));
  }

  Future<void> loadStateFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('configState');
    if (jsonString != null) {
      fromJson(jsonDecode(jsonString));
    }
  }
}
