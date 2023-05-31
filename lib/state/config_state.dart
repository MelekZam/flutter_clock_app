import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

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
  }

  void updateHourFormat(String hourFormat) {
    state = state.copyWith(hourFormat: hourFormat);
  }

  void setRingtones(List ringtones) {
    state = state.copyWith(ringtones: ringtones);
  }

  void setClockColor(int? clockColor) {
    state = state.copyWith(clockColor: clockColor);
  }

  void setActiveRingtone(String? ringtone) {
    state = state.copyWith(activeRingtone: ringtone);
  }

  String? get ringtone {
    return state.activeRingtone;
  }
}
