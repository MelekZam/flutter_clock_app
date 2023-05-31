import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

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
}

class AlarmsStateNotifier extends StateNotifier<List<Alarm>> {
  AlarmsStateNotifier() : super([]);

  void addAlarm(Alarm alarm) {
    state = [...state, alarm];
  }

  void toggleAlarm(int index) {
    state = state.asMap().entries.map((entry) {
      int mapIdx = entry.key;
      Alarm alarm = entry.value;
      if (index == mapIdx) return alarm.copyWith(isActive: !alarm.isActive);
      return alarm;
    }).toList();
  }

  void removeAlarm(int index) {
    final List<Alarm> newState = [...state];
    newState.removeAt(index);
    state = newState;
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
}
