import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';

class TimeLine extends StatefulWidget {
  const TimeLine({super.key});

  @override
  State<TimeLine> createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(automaticallyImplyLeading: true),
      body: Center(child: Text("Timeline")),
    );
  }
}
