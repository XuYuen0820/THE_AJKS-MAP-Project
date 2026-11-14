import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';

/// Card displayed after successful staff authentication matching Figma node 1:1070.
class SuccessCard extends StatelessWidget {
  final VoidCallback onContinue;

  const SuccessCard({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Authentication Success Screen',
      child: Column(
        key: const Key('success_card'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Checkmark Icon Container
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/success_check.svg',
                  width: 94,
                  height: 96,
                ),
                const Icon(
                  Icons.check_rounded,
                  size: 46,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Success Title
          const Text(
            'Success!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF323232),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),

          // Descriptive Subtitle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Congratulations! You have been successfully authenticated',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6C7278),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              key: const Key('continue_button'),
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0x33FF8D4D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
