import 'package:nate_thegrate/the_good_stuff.dart';

class Seconds extends Duration {
  const Seconds(double seconds)
      : super(microseconds: (seconds * Duration.microsecondsPerSecond) ~/ 1);
}

const microPerSec = Duration.microsecondsPerSecond;

bool useDelayedActivation(double seconds) => use(_DelayedActivationHook(seconds));

class _DelayedActivationHook extends Hook<bool> {
  const _DelayedActivationHook(this.delay);

  final double delay;

  @override
  _DelayedActivationHookState createState() => _DelayedActivationHookState();
}

class _DelayedActivationHookState extends HookState<bool, _DelayedActivationHook> {
  bool activated = false;

  @override
  void initHook() async {
    await Future.delayed(Seconds(hook.delay));
    if (!context.mounted) return;

    setState(() => activated = true);
  }

  @override
  bool build(BuildContext context) => activated;
}
