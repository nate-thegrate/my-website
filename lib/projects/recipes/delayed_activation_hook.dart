import 'package:flutter/material.dart';

class Seconds extends Duration {
  const Seconds(double seconds)
    : super(microseconds: (seconds * Duration.microsecondsPerSecond) ~/ 1);
}

const microPerSec = Duration.microsecondsPerSecond;

class DelayedActivation extends StatefulWidget {
  const DelayedActivation(this.builder, {required this.delay, super.key});

  final double delay;
  final Widget Function(BuildContext context, bool active) builder;

  @override
  State<DelayedActivation> createState() => _DelayedActivationState();
}

class _DelayedActivationState extends State<DelayedActivation> {
  bool active = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Seconds(widget.delay), () => setState(() => active = true));
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, active);
}
