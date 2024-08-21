import 'package:flutter/material.dart';
import 'package:nate_thegrate/projects/projects.dart';

class HeartCenter extends StatefulWidget {
  const HeartCenter({super.key});

  @override
  State<HeartCenter> createState() => _HeartCenterState();
}

class _HeartCenterState extends State<HeartCenter> {
  @override
  Widget build(BuildContext context) {
    return const ProjectCardTemplate();
  }
}
