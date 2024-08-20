import 'package:flutter/material.dart';
import 'package:nate_thegrate/projects/projects.dart';

class Recipes extends StatefulWidget implements Project {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();

  @override
  void launch() {
    // TODO: implement launch
  }
}

class _RecipesState extends State<Recipes> {
  @override
  Widget build(BuildContext context) {
    return const ProjectCardTemplate();
  }
}
