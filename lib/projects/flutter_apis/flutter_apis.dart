import 'dart:ui';

import 'package:nate_thegrate/projects/flutter_apis/rekt.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

export 'widget_state_mapping/widget_state_mapping.dart';

class FlutterApis extends StatelessWidget {
  const FlutterApis({super.key, this.child = _child});

  static const _child = Row(
    children: [
      ApiButton(Route.mapping),
      ApiButton(Route.animation),
    ],
  );

  final Widget child;

  static const bgImage = AssetImage('assets/images/gradient.png');
  static const decoration = BoxDecoration(
    color: Color(0xff28ffff),
    image: DecorationImage(
      alignment: Alignment.topLeft,
      fit: BoxFit.fill,
      image: bgImage,
      filterQuality: FilterQuality.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: GetRekt.new,
      child: DecoratedBox(
        decoration: decoration,
        child: SizedBox.expand(child: child),
      ),
    );
  }
}

class ApiButton extends StatefulWidget {
  const ApiButton(this.route, {super.key});

  final Route route;

  @override
  State<ApiButton> createState() => _ApiButtonState();
}

class _ApiButtonState extends State<ApiButton> {
  static final active = WidgetState.hovered | WidgetState.pressed | WidgetState.selected;

  late final states = WidgetStates()..addListener(rebuild);

  @override
  void dispose() {
    states.dispose();
    super.dispose();
  }

  late final Widget text = InkWell(
    key: GlobalKey(),
    onTap: () async {
      states.add(WidgetState.selected);
      final key = text.key! as GlobalKey;
      final renderBox = key.currentContext!.findRenderObject()! as RenderBox;
      final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
      final getRekt = context.read<GetRekt>()..value = rect;
      await Future.delayed(GetRekt.duration);
      if (!mounted) return;

      states.add(WidgetState.disabled);
      getRekt.absolutelyRekt(widget.route, Overlay.of(context));
    },
    overlayColor: const WidgetStatePropertyAll(Colors.black12),
    child: Center(
      heightFactor: 1,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: SizedBox(
          width: 256,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(switch (widget.route) {
              Route.mapping => 'WidgetState\nMapping',
              Route.animation => 'Animated\nValues',
              _ => throw Error(),
            }),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (states.contains(WidgetState.disabled)) {
      return const Spacer();
    }

    return Expanded(
      child: IgnorePointer(
        ignoring: states.contains(WidgetState.selected),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: double.infinity,
              child: MouseRegion(
                onEnter: (event) => states.add(WidgetState.hovered),
                onExit: (event) => states.remove(WidgetState.hovered),
                cursor: SystemMouseCursors.click,
                child: AnimatedValue.builder(
                  active.isSatisfiedBy(states) ? 1.0 : 0.0,
                  duration: Durations.medium1,
                  curve: Curves.ease,
                  lerp: lerpDouble,
                  builder: (context, value, child) => _ButtonBox(depth: value, child: text),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonBox extends StatelessWidget {
  const _ButtonBox({required this.depth, required this.child});

  final double depth;
  final Widget child;

  static const shape = BeveledRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  );

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const ShapeBorderClipper(shape: shape),
      child: DecoratedBox(
        decoration: RektDecoration(depth: depth),
        child: Material(
          type: MaterialType.transparency,
          child: Transform.translate(
            offset: Offset(depth / 2, depth * 2),
            child: Builder(builder: _buildStyle),
          ),
        ),
      ),
    );
  }

  Widget _buildStyle(context) {
    return AnimatedValue.builder(
      GetRekt.opacityOf(context),
      duration: GetRekt.duration,
      lerp: lerpDouble,
      builder: (context, value, _) => DefaultTextStyle(
        style: TextStyle(
          color: HSLColor.fromAHSL(value, 0, 0, (1 - depth) / 5).toColor(),
          fontSize: 32,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: Colors.white.withOpacity((1 - depth) * value / 4),
              blurRadius: 4.0,
            ),
          ],
        ),
        textAlign: TextAlign.center,
        child: child,
      ),
    );
  }
}
