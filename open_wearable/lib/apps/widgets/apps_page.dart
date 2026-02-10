import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_earable_flutter/open_earable_flutter.dart';
import 'package:open_wearable/apps/heart_tracker/widgets/heart_tracker_page.dart';
import 'package:open_wearable/apps/just_headbang/services/beat_detection_service.dart';
import 'package:open_wearable/apps/just_headbang/services/sensor_service.dart';
import 'package:open_wearable/apps/just_headbang/view/main_view.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/game_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/sensor_viewmodel.dart';
import 'package:open_wearable/apps/posture_tracker/model/earable_attitude_tracker.dart';
import 'package:open_wearable/apps/posture_tracker/view/posture_tracker_view.dart';
import 'package:open_wearable/apps/widgets/select_earable_view.dart';
import 'package:open_wearable/apps/widgets/app_tile.dart';
import 'package:open_wearable/view_models/sensor_configuration_provider.dart';
import '../../widgets/devices/connect_devices_page.dart';

class AppInfo {
  final String logoPath;
  final String title;
  final String description;
  final Widget widget;

  AppInfo({
    required this.logoPath,
    required this.title,
    required this.description,
    required this.widget,
  });
}

List<AppInfo> _apps = [
  AppInfo(
    logoPath: "lib/apps/posture_tracker/assets/logo.png",
    title: "Posture Tracker",
    description: "Get feedback on bad posture",
    widget: SelectEarableView(
      startApp: (wearable, sensorConfigProvider) {
        return PostureTrackerView(
          EarableAttitudeTracker(
            wearable as SensorManager,
            sensorConfigProvider,
            wearable.name.endsWith("L"),
          ),
        );
      },
    ),
  ),
  AppInfo(
    logoPath: "lib/apps/heart_tracker/assets/logo.png",
    title: "Heart Tracker",
    description: "Track your heart rate and other vitals",
    widget: SelectEarableView(
      startApp: (wearable, _) {
        if (wearable is SensorManager) {
          //TODO: show alert if no ppg sensor is found
          Sensor ppgSensor = (wearable as SensorManager).sensors.firstWhere(
                (s) =>
                    s.sensorName.toLowerCase() ==
                    "photoplethysmography".toLowerCase(),
              );

          return HeartTrackerPage(ppgSensor: ppgSensor);
        }
        return PlatformScaffold(
          appBar: PlatformAppBar(
            title: PlatformText("Heart Tracker"),
          ),
          body: Center(
            child: PlatformText("No PPG Sensor Found"),
          ),
        );
      },
    ),
  ),
  AppInfo(
    logoPath: "lib/apps/just_headbang/assets/images/logo.png",
    title: "Just Headbang",
    description: "Headbang to the beat",
    widget: MainView(
      viewModel: GameViewModel(
        _MockSensorViewModel(),
        _MockBeatDetectionService(),
      ),
    ),
  ),
];

// Stub implementations for development (UI-only testing)
class _MockSensorViewModel extends SensorViewModel {
  _MockSensorViewModel()
      : super(_MockSensorManager(), _MockSensorConfigurationProvider(),
            sensorService: _MockSensorService());
  // Empty stub - no sensor functionality needed for UI testing
}

class _MockSensorManager implements SensorManager {
  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockSensorConfigurationProvider implements SensorConfigurationProvider {
  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockSensorService implements SensorService {
  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockBeatDetectionService implements BeatDetectionService {
  // Empty stub - no beat detection needed for UI testing
  @override
  void noSuchMethod(Invocation invocation) {
    // Silently ignore all method calls
  }
}

class AppsPage extends StatelessWidget {
  const AppsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText("Apps"),
        trailingActions: [
          PlatformIconButton(
            icon: Icon(context.platformIcons.bluetooth),
            onPressed: () {
              if (Theme.of(context).platform == TargetPlatform.iOS) {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => ConnectDevicesPage(),
                );
              } else {
                Navigator.of(context).push(
                  platformPageRoute(
                    context: context,
                    builder: (context) => const Material(
                      child: ConnectDevicesPage(),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: _apps.length,
          itemBuilder: (context, index) {
            return AppTile(app: _apps[index]);
          },
        ),
      ),
    );
  }
}
