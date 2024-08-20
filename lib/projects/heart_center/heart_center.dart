import 'package:flutter/material.dart';
import 'package:nate_thegrate/projects/projects.dart';

class HeartCenter extends StatefulWidget implements Project {
  const HeartCenter({super.key});

  @override
  State<HeartCenter> createState() => _HeartCenterState();

  @override
  void launch() {
    // TODO: implement launch
  }
}

class _HeartCenterState extends State<HeartCenter> {
  @override
  Widget build(BuildContext context) {
    return const ProjectCardTemplate();
  }
}
