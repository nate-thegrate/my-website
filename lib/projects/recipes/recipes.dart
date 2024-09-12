import 'package:nate_thegrate/the_good_stuff.dart';

class Recipes extends SizedBox {
  const Recipes({super.key}) : super.expand(child: recipes);

  static const recipes = ColoredBox(
    color: RecipeCard.background,
    child: DefaultTextStyle(
      style: TextStyle(
        inherit: false,
        color: Colors.black,
        fontFamily: 'annie use your telescope',
        fontSize: 36,
      ),
      child: Center(
        child: _Recipes(),
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
    return const SizedBox(
      width: 400,
      height: 500,
      child: ColoredBox(
        color: Colors.white38,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                Text('Delicious'),
                Text('Affordable'),
                Text('100% whole grain'),
                Text('Sugar-free'),
                Text('Plant-based'),
                Spacer(),
                Text(
                  'recipes',
                  style: TextStyle(fontSize: 50),
                ),
                SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
