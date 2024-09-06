import 'package:nate_thegrate/projects/recipes/stache.dart';
import 'package:nate_thegrate/the_good_stuff.dart';

class RecipeCard extends StatefulWidget {
  const RecipeCard({super.key});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    final states = WidgetStates.of(context);
    const background = Color(0xffddffbb);
    return ToggleBuilder(
      states.contains(WidgetState.hovered),
      duration: Durations.medium1,
      curve: Curves.ease,
      builder: (context, t, child) {
        final card = ProjectCardTemplate(
          elevation: 5 * (1 - t),
          color: background,
          child: const Center(child: StacheStash()),
        );
        if (t == 0) return card;
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: background.withValues(alpha: t),
                blurRadius: 20 * t,
                spreadRadius: 20 * t,
              ),
            ],
          ),
          child: card,
        );
      },
    );
  }
}
