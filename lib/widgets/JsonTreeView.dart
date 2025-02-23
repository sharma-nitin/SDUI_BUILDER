import 'package:flutter/material.dart';
import 'dart:convert';

class JsonTreeView extends StatelessWidget {
  final Map<String, dynamic> jsonData;

  const JsonTreeView({Key? key, required this.jsonData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
      ),
      height: 100, // Set fixed height for scrolling
      child: SingleChildScrollView(
        child: SelectableText(
          _prettyPrintJson(jsonData),
          style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
        ),
      ),
    );
  }

  /// Converts JSON to formatted string
  String _prettyPrintJson(Map<String, dynamic> json) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }
}
