import 'dart:ui';

import 'package:nate_thegrate/the_good_stuff.dart';

class Recipes extends SizedBox {
  const Recipes({super.key}) : super.expand(child: recipes);

  static const drop = AssetImage('assets/images/spring_drop.png');

  static const recipes = ColoredBox(
    color: RecipeCard.background,
    child: DefaultTextStyle(
      style: RecipeStyle(size: 36),
      child: SizedBox.expand(
        child: FittedBox(
          child: SizedBox(
            width: 400,
            height: 500,
            child: _Recipes(),
          ),
        ),
      ),
    ),
  );
}

class _Recipes extends StatefulWidget {
  const _Recipes();

  @override
  State<_Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<_Recipes> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      key: Key('s'),
      alignment: Alignment.bottomCenter,
      children: [
        Align(
          alignment: Alignment(0, -0.6),
          child: DefaultTextStyle(
            style: TextStyle(
              inherit: false,
              color: Color(0xffb0b0b0),
              fontWeight: FontWeight.bold,
              fontSize: 72,
            ),
            child: _ComingSoon(),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 8),
            AnimatedText(0, 'delicious'),
            AnimatedText(1, 'affordable'),
            AnimatedText(2, 'whole grain'),
            AnimatedText(3, 'sugar-free'),
            AnimatedText(4, 'plant-based'),
            Expanded(
              child: _FadeInButtons(),
            ),
            DefaultTextStyle(
              style: RecipeStyle(size: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  AnimatedText(8.6, 'r'),
                  AnimatedText(8.8, 'e'),
                  AnimatedText(9.0, 'c'),
                  AnimatedText(9.2, 'i'),
                  AnimatedText(9.4, 'p'),
                  AnimatedText(9.6, 'e'),
                  AnimatedText(9.8, 's'),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
        SpringDrop(),
      ],
    );
  }
}

class RecipeStyle extends TextStyle {
  const RecipeStyle({double? size, Color super.color = Colors.black})
      : super(
          inherit: false,
          fontFamily: 'annie use your telescope',
          fontSize: size,
        );
}

class _FadeInButtons extends StatefulWidget {
  const _FadeInButtons();

  @override
  State<_FadeInButtons> createState() => _FadeInButtonsState();
}

class _FadeInButtonsState extends State<_FadeInButtons> {
  static void view() => launchUrlString('https://recipes.nate-thegrate.com/');
  static void back() => Route.go(Route.projects);

  bool ignoring = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Seconds(6), () {
      if (mounted) setState(() => ignoring = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    const row = Row(
      children: [
        Expanded(
          child: Center(
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.only(left: 8)),
                foregroundColor: WidgetStatePropertyAll(Colors.black),
                overlayColor: WidgetStatePropertyAll(Colors.white54),
                side: WidgetStateProperty.fromMap({
                  WidgetState.hovered: BorderSide(width: 2),
                  WidgetState.any: BorderSide.none,
                }),
              ),
              onPressed: back,
            ),
          ),
        ),
        OutlinedButton(
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(RecipeStyle(size: 36)),
            foregroundColor: WidgetStatePropertyAll(Colors.black),
            padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(28, 12, 28, 16)),
            shape: WidgetStatePropertyAll(
              ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.elliptical(40, 32)),
              ),
            ),
            side: WidgetStatePropertyAll(BorderSide(width: 2)),
            overlayColor: WidgetStateProperty.fromMap({
              WidgetState.pressed: Color(0xff80ffc0),
              WidgetState.any: Color(0x80a0ffd0),
            }),
          ),
          onPressed: view,
          child: Text('preview'),
        ),
        Spacer(),
      ],
    );

    return IgnorePointer(
      ignoring: ignoring,
      child: AnimatedOpacity(
        opacity: ignoring ? 0 : 1,
        duration: Durations.long4,
        curve: Curves.easeInOutSine,
        child: row,
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  const AnimatedText(this.delay, this.text, {super.key});

  final String text;
  final double delay;

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  bool activated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Seconds(widget.delay / 3), () {
      if (mounted) setState(() => activated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const duration = Seconds(0.8);
    return AnimatedSlide(
      offset: activated ? Offset.zero : const Offset(0, -0.25),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: activated ? 1 : 0,
        duration: duration,
        curve: Curves.easeInOutSine,
        child: Text(widget.text),
      ),
    );
  }
}

class _ComingSoon extends StatefulWidget {
  const _ComingSoon();

  @override
  State<_ComingSoon> createState() => _ComingSoonState();
}

class _ComingSoonState extends State<_ComingSoon> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Seconds(5), () {
      if (mounted) setState(() => visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.5,
      child: AnimatedOpacity(
        opacity: visible ? 0.5 : 0.0,
        duration: const Seconds(1),
        curve: Curves.easeInOutSine,
        child: const Text(
          'Coming soon!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class SpringDrop extends LeafRenderObjectWidget {
  const SpringDrop({super.key});

  static const duration = Seconds(4);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSpringDrop();
}

class _RenderSpringDrop extends RenderBox {
  _RenderSpringDrop() {
    animation
      ..addListener(markNeedsPaint)
      ..value = 431;
  }

  final ValueAnimation<double> animation = ValueAnimation(
    vsync: App.vsync,
    initialValue: 0,
    duration: SpringDrop.duration,
    curve: Curves.easeOutCubic,
    lerp: lerpDouble,
  );

  @override
  void performLayout() => size = constraints.biggest;

  static final drop = Path()
    ..moveTo(5, 0)
    ..cubicTo(6, 12.5, 10, 16, 10, 25)
    ..arcToPoint(
      const Offset(0, 25),
      radius: const Radius.circular(5),
    )
    ..cubicTo(0, 16, 4, 18, 5, 0)
    ..close();

  static final crescent = Path()
    ..moveTo(3, 22)
    ..arcToPoint(const Offset(5.5, 28), radius: const Radius.circular(3.5), clockwise: false)
    ..arcToPoint(const Offset(3, 22), radius: const Radius.circular(7));

  static final fillSpring = Paint()..color = const Color(0xffa0ffd0);
  static final fillBlack = Paint()..color = Colors.black;
  static final outline = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas
      ..save()
      ..translate(offset.dx + size.width / 2 - 5, offset.dy - 30 + animation.value)
      ..drawPath(drop, fillSpring)
      ..drawPath(drop, outline)
      ..drawPath(crescent, fillBlack)
      ..restore();
  }
}
