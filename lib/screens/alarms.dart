import 'package:app_test/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/animated_action_button.dart';
import 'package:flutter/material.dart';
import '../state/alarms_state.dart';
import 'package:audioplayers/audioplayers.dart';

final selectedIdxProvider = StateProvider<int>((ref) => -1);
final selectorIsOpen = StateProvider<bool>((ref) => false);
final GlobalKey<AnimatedActionButtonState> _floatingBtnState =
    GlobalKey<AnimatedActionButtonState>();

class Alarms extends ConsumerWidget {
  Alarms({Key? key}) : super(key: key);
  final player = AudioPlayer();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnimatedActionButton floatingActionButton = AnimatedActionButton(
        key: _floatingBtnState,
        action: () {
          final int index = ref.read(selectedIdxProvider.notifier).state;
          if (index == -1) {
            addAlarm(context, ref);
          } else {
            removeAlarm(index, ref);
          }
        });
    final selectedIndex = ref.watch(selectedIdxProvider);
    final alarms = ref.watch(alarmsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
              );
            },
          )
        ],
      ),
      body: alarms.isNotEmpty
          ? buildList(alarms, selectedIndex, ref)
          : const Center(child: Text('No Alarms just yet!')),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildList(List<Alarm> alarms, int selectedIndex, WidgetRef ref) {
    final String hourFormat = ref.watch(settingsProvider).hourFormat;
    return ListView.builder(
      itemCount: alarms.length,
      itemBuilder: (BuildContext context, int index) {
        final alarmValue =
            ref.read(alarmsProvider.notifier).readAlarm(index, hourFormat);
        final isActive = alarms[index].isActive;

        return GestureDetector(
            onLongPress: () => updateSelectidx(ref, selectedIndex, index),
            child: Container(
                height: 80,
                padding: const EdgeInsets.only(bottom: 5, top: 5),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: selectedIndex == index
                          ? Colors.red
                          : Colors.grey.withOpacity(0.1),
                      spreadRadius: 0.5,
                      blurRadius: 0.5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  title: Text(
                    alarmValue,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: alarmSubtitle(
                      isActive, selectedIndex, alarms[index], ref),
                  trailing: selectedIndex == -1
                      ? Switch(
                          value: isActive,
                          onChanged: (bool value) {
                            ref
                                .read(alarmsProvider.notifier)
                                .toggleAlarm(index);
                          },
                        )
                      : null,
                )));
      },
    );
  }

  void addAlarm(BuildContext context, WidgetRef ref) async {
    final String hourFormat =
        ref.read(settingsProvider.notifier).state.hourFormat;
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: hourFormat == '24-Hour',
              ),
              child: child!,
            ),
          ),
        );
      },
    );
    if (selectedTime != null) {
      ref
          .read(alarmsProvider.notifier)
          .addAlarm(Alarm(selectedTime.hour, selectedTime.minute, true));
    }
  }

  void removeAlarm(int index, WidgetRef ref) async {
    ref.read(alarmsProvider.notifier).removeAlarm(index);
    ref.read(selectedIdxProvider.notifier).state = -1;
    reverseAnimation();
  }

  void updateSelectidx(ref, currentIndex, index) {
    if (currentIndex == index) {
      ref.read(selectedIdxProvider.notifier).state = -1;
      reverseAnimation();
    } else {
      ref.read(selectedIdxProvider.notifier).state = index;
      forwardAnimation();
    }
  }

  void reverseAnimation() {
    _floatingBtnState.currentState!.animateReverse();
  }

  void forwardAnimation() {
    _floatingBtnState.currentState!.animateForward();
  }

  dynamic alarmSubtitle(
      bool isActive, int selectedIndex, Alarm alarm, WidgetRef ref) {
    if (!isActive || selectedIndex != -1) return null;
    int minutesLeft = ref
        .read(alarmsProvider.notifier)
        .calculateDistance(alarm, DateTime.now());
    String text = "";
    if (minutesLeft > 60) {
      text = "Sleep tight, plenty of time is left!";
    } else if (minutesLeft <= 5) {
      text = "I don't do this because I want to, I do this because I must.";
    } else {
      text = "I will be waking you up soon!";
    }
    return Text(text);
  }
}
