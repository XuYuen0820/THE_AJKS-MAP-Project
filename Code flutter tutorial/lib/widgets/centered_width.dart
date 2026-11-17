import 'package:flutter/material.dart';

class CenteredWidth extends StatelessWidget {
  final Widget child;
  const CenteredWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: child);
  }
}
