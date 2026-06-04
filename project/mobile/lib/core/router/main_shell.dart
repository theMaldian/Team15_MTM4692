import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/domain/user_role.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// A bottom-nav destination.
class _Destination {
  const _Destination({
    required this.location,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String location;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Role-aware bottom navigation shell wrapping the authenticated top-level
/// screens.
///
/// - Students:  Opportunities (/jobs) · My Applications (/my-applications) · Profile
/// - Professors: Active Postings (/my-jobs) · Inactive Postings (/my-jobs/closed) · Profile
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final UserModel? user = ref.watch(authControllerProvider).valueOrNull;
    final bool isProfessor = user?.role == UserRole.professor;

    final List<_Destination> destinations = isProfessor
        ? <_Destination>[
            _Destination(
              location: '/my-jobs',
              icon: Icons.work_outline,
              selectedIcon: Icons.work,
              label: l10n.navActivePostings,
            ),
            _Destination(
              location: '/my-jobs/closed',
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2,
              label: l10n.navInactivePostings,
            ),
            _Destination(
              location: '/profile',
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: l10n.navProfile,
            ),
          ]
        : <_Destination>[
            _Destination(
              location: '/jobs',
              icon: Icons.work_outline,
              selectedIcon: Icons.work,
              label: l10n.navOpportunities,
            ),
            _Destination(
              location: '/my-applications',
              icon: Icons.description_outlined,
              selectedIcon: Icons.description,
              label: l10n.navApplications,
            ),
            _Destination(
              location: '/profile',
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: l10n.navProfile,
            ),
          ];

    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = destinations.indexWhere(
      (_Destination d) => location == d.location,
    );
    if (currentIndex < 0) {
      currentIndex = 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.30),
        onDestinationSelected: (int index) {
          final String target = destinations[index].location;
          if (target != location) {
            context.go(target);
          }
        },
        destinations: destinations
            .map(
              (_Destination d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon, color: AppColors.primary),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
