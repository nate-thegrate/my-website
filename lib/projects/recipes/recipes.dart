import 'package:flutter/material.dart';
import 'package:nate_thegrate/projects/projects.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  @override
  Widget build(BuildContext context) {
    return const ProjectCardTemplate();
  }
}
