import 'widgets/bold_text.dart';
import 'widgets/rating.dart';
import 'package:flutter/material.dart';

import 'widgets/editable_image.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BoldText('Full stars rating', fontSize: 30, color: Colors.pink),
              Rating(5),
              BoldText('Rating with half stars', fontSize: 30),
              Rating.percent(90),

              BoldText('Rating with half stars', fontSize: 30),
              Rating(3.7, color: Colors.amber),
              EditableImage(
                image: NetworkImage(
                  'https://randomuser.me/api/portraits/women/0.jpg',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
