import 'package:nate_thegrate/the_good_stuff.dart';

class ApiButton extends StatefulWidget {
  const ApiButton(this.route, {super.key}) : inAppBar = false;
  const ApiButton.appBar(this.route, {super.key}) : inAppBar = true;

  final bool inAppBar;
  final Route route;

  @override
  State<ApiButton> createState() => _ApiButtonState();
}

class _ApiButtonState extends State<ApiButton> {
  static final active = WidgetState.hovered | WidgetState.pressed | WidgetState.selected;

  late final states = WidgetStates()..addListener(rebuild);
  late final small = widget.inAppBar;
  late final padding = EdgeInsets.all(small ? 8 : 32);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GetRekt.selected(context, widget.route)) {
      states.add(WidgetState.selected);
    }
  }

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
      final getRekt = context.read<GetRekt>()..giveRekt(rect, widget.route);
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
            padding: padding,
            child: Text(
              switch ((widget.route, small)) {
                (Route.mapping, false) => 'WidgetState\nMapping',
                (Route.animation, false) => 'Animated\nValues',
                (Route.mapping, true) => 'Mapping',
                (Route.animation, true) => 'Animation',
                _ => throw Error(),
              },
              style: small
                  ? const TextStyle(
                      inherit: false,
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )
                  : null,
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!small && states.contains(WidgetState.disabled)) {
      return const Spacer();
    }

    return Expanded(
      child: IgnorePointer(
        ignoring: !small && states.contains(WidgetState.selected),
        child: Center(
          child: Padding(
            padding: padding,
            child: SizedBox(
              width: double.infinity,
              child: MouseRegion(
                onEnter: (event) => states.add(WidgetState.hovered),
                onExit: (event) => states.remove(WidgetState.hovered),
                cursor: SystemMouseCursors.click,
                child: ToggleBuilder(
                  active.isSatisfiedBy(states),
                  duration: Durations.medium1,
                  curve: Curves.ease,
                  builder: (context, depth, child) => _ButtonBox(depth, child: text),
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
  const _ButtonBox(this.depth, {required this.child});

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
    return ToggleBuilder(
      !GetRekt.hasRekt(context),
      duration: GetRekt.duration,
      builder: (context, value, _) => DefaultTextStyle(
        style: TextStyle(
          color: HSLColor.fromAHSL(value, 0, 0, (1 - depth) / 5).toColor(),
          fontSize: 32,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: Colors.white.withValues(alpha: (1 - depth) * value / 4),
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
