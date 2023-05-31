import 'package:app_test/screens/clock.dart';
import 'package:app_test/screens/ringtones.dart';
import 'package:app_test/screens/settings.dart';
import 'package:app_test/state/alarms_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'utils/system_helper.dart' as sys_helper;
import 'state/config_state.dart';
import 'screens/alarms.dart';
import 'utils/themes.dart';

final settingsProvider =
    StateNotifierProvider<ConfigStateNotifier, ConfigState>((ref) {
  return ConfigStateNotifier();
});

final alarmsProvider = StateNotifierProvider<AlarmsStateNotifier, List<Alarm>>(
  (ref) => AlarmsStateNotifier(),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sys_helper.clearStatusBar();
  sys_helper.setPreferredOrientations();
  runApp(const ProviderScope(
    child: App(),
  ));
}

class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends ConsumerState<App> {
  @override
  void initState() {
    _loadRingtones();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(settingsProvider).mode;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return MaterialApp(
      theme: Themes.currentTheme(mode),
      home: isPortrait ? Alarms() : const Clock(),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/settings') {
          return MaterialPageRoute(builder: (_) => Settings());
        } else if (settings.name == '/ringtones') {
          return MaterialPageRoute(builder: (_) => Ringtones());
        } else {
          return MaterialPageRoute(
              builder: (_) => isPortrait ? Alarms() : const Clock());
        }
      },
    );
  }

  void _loadRingtones() async {
    List ringtones = await sys_helper.getRingstones();
    ref.read(settingsProvider.notifier).setRingtones(ringtones);
    if (ringtones.isNotEmpty) {
      ref.read(settingsProvider.notifier).setActiveRingtone(ringtones[0]);
    }
  }
}
