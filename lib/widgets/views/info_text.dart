import 'package:flutter/material.dart';

class InfoText extends StatelessWidget {
     final Map<String, dynamic> widgetData;
  InfoText({Key? key,  required this.widgetData, }) : super(key: key);

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.lightbulb,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            'info Text',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
