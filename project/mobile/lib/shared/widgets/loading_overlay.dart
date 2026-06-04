import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';

/// Full-screen translucent overlay with a centered spinner.
///
/// Wrap any screen body with [LoadingOverlay] and toggle [isLoading] to block
/// interaction while an async action runs.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        if (isLoading)
          const Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
