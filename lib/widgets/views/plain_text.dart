import 'package:flutter/material.dart';

class PlainText extends StatelessWidget {
     final Map<String, dynamic> widgetData;
  PlainText({Key? key,  required this.widgetData, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(
        minHeight: 10,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 136, 198, 227),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Plain Text',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
