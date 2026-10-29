import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/utils/theme_controller.dart';
import '/ui/widgets/liquid_glass.dart';
import '../player_controller.dart';

class LyricsSwitch extends StatelessWidget {
  const LyricsSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final themeCtrl = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : null;

    return Obx(() {
      if (playerController.showLyricsflag.isFalse) {
        return const SizedBox.shrink();
      }

      final activeColor = themeCtrl?.primaryColor.value ??
          Theme.of(context).colorScheme.primary;
      final selectedMode = playerController.lyricsMode.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: LiquidGlassContainer(
          borderRadius: BorderRadius.circular(24),
          blurSigma: 16.0,
          borderWidth: 0.8,
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSegment(
                label: 'synced'.tr,
                isSelected: selectedMode == 0,
                activeColor: activeColor,
                onTap: () => playerController.changeLyricsMode(0),
              ),
              _buildSegment(
                label: 'plain'.tr,
                isSelected: selectedMode == 1,
                activeColor: activeColor,
                onTap: () => playerController.changeLyricsMode(1),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSegment({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return FlowyButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    activeColor.withValues(alpha: 0.75),
                    activeColor.withValues(alpha: 0.50),
                  ],
                )
              : null,
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 0.8,
                )
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.65),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
