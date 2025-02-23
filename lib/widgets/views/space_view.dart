import 'package:flutter/material.dart';

class SpaceView extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  SpaceView({
    Key? key,
    required this.widgetData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: double.infinity,
      child: Container(
        color: Colors.grey[350],
      ),
    );
  }
}
