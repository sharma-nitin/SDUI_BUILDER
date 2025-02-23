import 'package:flutter/material.dart';
import 'package:sdui_builder/widgets/views/info_text.dart';
import 'package:sdui_builder/widgets/views/plain_text.dart';
import 'package:sdui_builder/widgets/views/space_view.dart';

class ViewTypeFactory {
  static Widget? getWidget(Map<String, dynamic> data) {
    final Map<String, Widget Function(Map<String, dynamic>)> widgetMap = {
      'info_text': (data) => InfoText(widgetData: data),
      'plain_text': (data) => PlainText(widgetData: data),
      'space_view': (data) => SpaceView(widgetData: data),
    };

    return widgetMap[data['type']]?.call(data);
  }
}
