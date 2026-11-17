import 'package:flutter/material.dart';

class BoldText extends StatelessWidget {
  final String data;
  final double? fontSize;
  final Color? color;
  const BoldText(this.data, {super.key, this.fontSize, this.color});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium!;
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: fontSize ?? defaultStyle.fontSize,
        color: color ?? defaultStyle.color,
      ),
      
    );
  }
}
