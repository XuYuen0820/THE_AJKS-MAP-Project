import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/exora_logo.dart'; // Using your existing ExoraLogo widget
import 'invigilator_list_page.dart';
import 'assign_invigilator_page.dart';
import 'discharge_invigilator_page.dart';

class InvigilatorManagementPage extends StatelessWidget {
  const InvigilatorManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient matching AdminPage exactly
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.75, 1.0],
                colors: [
                  AppColors.backgroundTop,
                  AppColors.backgroundBottom,
                  AppColors.backgroundBottom,
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                // 2. ConstrainedBox makes it look like a mobile screen on Web/Desktop
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // Top Brand Header (with back button for navigation)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          const ExoraLogo(
                            mainAxisAlignment: MainAxisAlignment.start,
                            iconSize: 24,
                            textHeight: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Page Title
                      const Text(
                        'Invigilator\nManagement',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 3-Action Grid (Fixed layout matching Dashboard)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.people_rounded,
                              label: 'Invigilator\nList',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const InvigilatorListPage()),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.person_add_alt_1_rounded,
                              label: 'Assign\nInvigilator',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AssignInvigilatorPage()),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _ActionCard(
                              icon: Icons.person_remove_alt_1_rounded,
                              label: 'Discharge\nInvigilator',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DischargeInvigilatorPage()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. The custom card widget styled exactly like DashboardActionItem
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          children: [
            Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}