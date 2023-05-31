import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

@immutable
class Alarm {
  final int hour;
  final int minute;
  final bool isActive;

  const Alarm(this.hour, this.minute, this.isActive);

  Alarm copyWith({
    int? hour,
    int? minute,
    bool? isActive,
  }) {
    return Alarm(
      hour ?? this.hour,
      minute ?? this.minute,
      isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'isActive': isActive,
    };
  }

  static Alarm alarmFromJson(Map<String, dynamic> json) {
    return Alarm(json['hour'], json['minute'], json['isActive']);
  }
}

class AlarmsStateNotifier extends StateNotifier<List<Alarm>> {
  AlarmsStateNotifier() : super([]);

  void addAlarm(Alarm alarm) {
    state = [...state, alarm];
    saveStateToLocalStorage();
  }

  void toggleAlarm(int index) {
    state = state.asMap().entries.map((entry) {
      int mapIdx = entry.key;
      Alarm alarm = entry.value;
      if (index == mapIdx) return alarm.copyWith(isActive: !alarm.isActive);
      return alarm;
    }).toList();
    saveStateToLocalStorage();
  }

  void removeAlarm(int index) {
    final List<Alarm> newState = [...state];
    newState.removeAt(index);
    state = newState;
    saveStateToLocalStorage();
  }

  String readAlarm(int index, String hourFormat) {
    Alarm alarm = state[index];
    int preformatHour = alarm.hour;
    String suffix = '';
    if (hourFormat == '12-Hour') {
      if (preformatHour > 12) {
        preformatHour -= 12;
        suffix = 'PM';
      } else {
        suffix = 'AM';
      }
    }
    var hour = '${preformatHour < 10 ? '0' : ''}$preformatHour';
    var minute = '${alarm.minute < 10 ? '0' : ''}${alarm.minute}';
    return '$hour:$minute $suffix';
  }

  void deactivateAlarm(Alarm alarm) {
    final List<Alarm> nextState = [];
    for (Alarm alarm2 in state) {
      if (alarm2.hashCode == alarm.hashCode) {
        nextState.add(alarm2.copyWith(isActive: false));
      } else {
        nextState.add(alarm2);
      }
    }
    state = nextState;
    saveStateToLocalStorage();
  }

  Alarm? get nextAlarm {
    final DateTime now = DateTime.now();
    Alarm? nextAlarm;
    int currentDistance = 1000000000;
    for (Alarm alarm in state) {
      if (!alarm.isActive) continue;
      final distance = calculateDistance(alarm, now);
      if (distance < currentDistance) {
        currentDistance = distance;
        nextAlarm = alarm;
      }
    }
    return nextAlarm;
  }

  int calculateDistance(Alarm alarm, DateTime now) {
    int alarmTotalMinutes = (alarm.hour * 60) + alarm.minute;
    int nowTotalMinutes = (now.hour * 60) + now.minute;
    if (alarmTotalMinutes >= nowTotalMinutes) {
      return alarmTotalMinutes - nowTotalMinutes;
    } else {
      return (24 * 60 - nowTotalMinutes) + alarmTotalMinutes;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'alarms': state.map((alarm) => alarm.toJson()).toList(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    final List<Alarm> newstate = [];
    for (final alarm in json['alarms']) {
      newstate.add(Alarm.alarmFromJson(alarm));
    }
    state = newstate;
  }

  Future<void> saveStateToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarmsState', jsonEncode(toJson()));
  }

  Future<void> loadStateFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('alarmsState');
    if (jsonString != null) {
      fromJson(jsonDecode(jsonString));
    }
  }
}
