import 'package:flutter/material.dart';
import 'package:nate_thegrate/projects/projects.dart';

class FlutterApis extends StatefulWidget implements Project {
  const FlutterApis({super.key});

  @override
  State<FlutterApis> createState() => _FlutterApisState();

  @override
  void launch() {
    // TODO: implement launch
  }
}

class _FlutterApisState extends State<FlutterApis> {
  @override
  Widget build(BuildContext context) {
    return const ProjectCardTemplate();
  }
}
