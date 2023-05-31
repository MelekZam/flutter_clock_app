import 'package:app_test/main.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Ringtones extends ConsumerWidget {
  Ringtones({Key? key}) : super(key: key);

  final player = AudioPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ringtones = ref.watch(settingsProvider).ringtones;
    final activeRingtone = ref.watch(settingsProvider.notifier).ringtone;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a ringtone'),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: ringtones.length,
          itemBuilder: (BuildContext context, int index) {
            return settingsItem(
                ringtones[index],
                IconButton(
                    onPressed: () async {
                      await playRingtonePartly(ringtones[index], 4);
                    },
                    icon: const Icon(Icons.play_circle_outline)),
                Switch(
                    value: ringtones[index] == activeRingtone,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .setActiveRingtone(ringtones[index]);
                    }));
          }),
    );
  }

  Widget settingsItem(String title, Widget icon, Widget button) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(alignment: Alignment.centerRight, child: icon),
              Align(alignment: Alignment.centerRight, child: button)
            ],
          ),
        ));
  }

  Future<void> playRingtonePartly(String ringtone, int seconds) async {
    try {
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(
          DeviceFileSource('/system/media/audio/ringtones/$ringtone.ogg'));
      Future.delayed(Duration(seconds: seconds), () {
        player.stop();
      });
    } catch (ex) {}
  }
}
