import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Exora brand logo combining app icon and text emblem.
class ExoraLogo extends StatelessWidget {
  const ExoraLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Exora Logo',
      child: Row(
        key: const Key('exora_logo'),
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/app_icon.svg',
            key: const Key('app_icon'),
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/images/logo_text.svg',
            key: const Key('logo_text'),
            height: 18,
          ),
        ],
      ),
    );
  }
}
