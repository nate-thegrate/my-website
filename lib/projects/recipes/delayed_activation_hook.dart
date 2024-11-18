import 'package:nate_thegrate/the_good_stuff.dart';

class Seconds extends Duration {
  const Seconds(double seconds)
    : super(microseconds: (seconds * Duration.microsecondsPerSecond) ~/ 1);
}

const microPerSec = Duration.microsecondsPerSecond;

bool useDelayedActivation(double seconds) {
  return use(
    _DelayedActivationHook.new,
    data: seconds,
    key: null,
    debugLabel: 'useDelayedActivation',
  );
}

class _DelayedActivationHook extends Hook<bool, double> {
  bool activated = false;

  @override
  void initHook() async {
    await Future<void>.delayed(Seconds(data));
    if (!context.mounted) return;

    setState(() => activated = true);
  }

  @override
  bool build() => activated;
}
