import 'package:app_test/main.dart';
import 'package:app_test/widgets/colors_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final GlobalKey<ColorsModalState> _colorsModalState =
    GlobalKey<ColorsModalState>();

class Settings extends ConsumerWidget {
  Settings({Key? key}) : super(key: key);

  final List<int> colorHexCodes = [
    0xFF000080, // Navy Blue color
    0xFF0000CD, // Medium Blue color
    0xFF4169E1, // Royal Blue color
    0xFF00BFFF, // Deep Sky Blue color
    0xFF00FFFF, // Cyan color
    0xFF7FFFD4, // Aquamarine color
    0xFF7FFF00, // Chartreuse color
    0xFFFFFF00, // Yellow color
    0xFFFFD700, // Gold color
    0xFFFFA500, // Orange color
    0xFFFF4500, // Orange Red color
    0xFFDC143C, // Crimson color
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const List<String> values = <String>["24-Hour", "12-Hour"];
    final mode = ref.watch(settingsProvider).mode;
    final hourFormat = ref.watch(settingsProvider).hourFormat;
    final selectedColor = ref.watch(settingsProvider).clockColor;
    final ringtone = ref.watch(settingsProvider).activeRingtone;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Settings'),
        ),
        body: ListView(
          children: <Widget>[
            settingsItem(
                'Dark mode',
                Switch(
                    value: mode == 'dark',
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateMode(value);
                    })),
            settingsItem(
                'Hour format',
                DropdownButton(
                    items: values.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: hourFormat,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateHourFormat(value!);
                    })),
            settingsItem(
                'Clock color',
                IconButton(
                    icon: Icon(
                      Icons.color_lens_outlined,
                      color:
                          selectedColor != null ? Color(selectedColor) : null,
                    ),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Center(
                              child: ColorsModal(
                            key: _colorsModalState,
                            colors: colorHexCodes,
                            selectedColor: selectedColor,
                            action: () {
                              ref.read(settingsProvider.notifier).setClockColor(
                                  _colorsModalState
                                      .currentState?.selectedColor);
                            },
                          ));
                        },
                      );
                    })),
            settingsItem(
                'Default ringtone: $ringtone',
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    Navigator.pushNamed(context, '/ringtones');
                  },
                )),
          ],
        ));
  }

  Widget settingsItem(String title, Widget action) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      constraints: const BoxConstraints.expand(
        height: 80,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ))),
          Expanded(
              child: Align(alignment: Alignment.centerRight, child: action))
        ],
      ),
    );
  }
}
