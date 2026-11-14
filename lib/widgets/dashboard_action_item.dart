import 'package:flutter/material.dart';

/// Reusable action button in dashboard grids (e.g. QR Scanner, Attendance Analysis).
class DashboardActionItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final Key? itemKey;

  const DashboardActionItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.itemKey,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label.replaceAll('\n', ' '),
      child: InkWell(
        key: itemKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
