import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/shared/widgets/ytu_logo.dart';

/// Shared layout for auth screens: a light gradient backdrop with a faint YTU
/// watermark, a glowing star-seal hero, and the form inside a restrained glass
/// card.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.leading,
    this.trailing,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Optional top-left widget (e.g. a back button).
  final Widget? leading;

  /// Optional top-right widget (e.g. the language toggle on login).
  final Widget? trailing;

  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF0F4FA), Colors.white],
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Faint seal watermark bleeding off the top-right corner.
            const Positioned(
              top: -72,
              right: -72,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.04,
                  child: YtuLogo(size: 280, mode: YtuLogoMode.badge),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 44),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (leading != null || trailing != null)
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: leading,
                                    ),
                                    const Spacer(),
                                    if (trailing != null) trailing!,
                                  ],
                                ),
                              if (showLogo) ...<Widget>[
                                const SizedBox(height: 8),
                                const Center(
                                  child: YtuLogo(
                                    size: 88,
                                    mode: YtuLogoMode.badge,
                                    withGlow: true,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ] else
                                const SizedBox(height: 8),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (subtitle != null) ...<Widget>[
                                const SizedBox(height: 8),
                                Text(
                                  subtitle!,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                              const SizedBox(height: 28),
                              _GlassCard(child: child),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded, lightly-frosted card that hosts the auth form.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
