import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Exora brand logo combining app icon and text emblem.
class ExoraLogo extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final double iconSize;
  final double textHeight;

  const ExoraLogo({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.iconSize = 28,
    this.textHeight = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Exora Logo',
      child: Row(
        key: const Key('exora_logo'),
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/app_icon.svg',
            key: const Key('app_icon'),
            width: iconSize,
            height: iconSize,
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/images/logo_text.svg',
            key: const Key('logo_text'),
            height: textHeight,
          ),
        ],
      ),
    );
  }
}
