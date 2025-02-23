import 'package:flutter/material.dart';
import 'package:sdui_builder/pages/create_screen.dart';
import 'package:sdui_builder/pages/home_page.dart';
import 'package:sdui_builder/pages/view_screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drag & Drop SDUI Builder',
      onGenerateRoute: (settings) {
        if (settings.name == '/create') {
          final Map<String, dynamic>? initialJson =
              settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => CreateScreen(initialJson: initialJson),
          );
        } else if (settings.name == '/view') {
          return MaterialPageRoute(builder: (context) => ViewScreens());
        } else {
          return MaterialPageRoute(builder: (context) => HomePage());
        }
      },
    );
  }
}
