import 'package:flutter/material.dart';
import 'package:sdui_builder/helpers/widgets_data_helper.dart';

class DraggableWidget extends StatelessWidget {
  final String widgetName;

  DraggableWidget({Key? key, required this.widgetName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgetData = WidgetDataHelper().getData(widgetName);

    if (widgetData == null) {
      return const SizedBox.shrink();
    }

    Color getBgColor(String section) {
      switch (section) {
        case 'screen_header':
          return Colors.lightBlue[50]!;
        case 'screen_body':
          return Colors.lightGreen[50]!;
        case 'screen_footer':
          return Colors.amber[50]!;
        case 'section_container':
          return Color.fromARGB(255, 153, 212, 222);
        case 'sections':
          return Color.fromARGB(255, 154, 147, 223);
        default:
          return Colors.grey[400]!;
      }
    }

    return Draggable<Map<String, dynamic>>(
      data: widgetData,
      feedback: Material(
        child: Container(
          color: getBgColor(widgetName),
          padding: EdgeInsets.all(4),
          height: 50,
          width: 100,
          child: Center(child: Text(widgetName)),
        ),
      ),
      child: Container(
        color: getBgColor(widgetName),
        padding: EdgeInsets.all(4),
        height: 50,
        width: 100,
        child: Center(child: Text(widgetName)),
      ),
    );
  }
}
