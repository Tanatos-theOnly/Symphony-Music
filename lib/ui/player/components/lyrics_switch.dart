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
          const Color(0xFF4FA5FF);
      final selectedMode = playerController.lyricsMode.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xF00D0F14),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
    if (isSelected) {
      return FlowyButton(
        onTap: onTap,
        child: LiquidGlassPebble(
          borderRadius: BorderRadius.circular(20),
          chromaticColor: activeColor,
          highlightIntensity: 1.0,
          hasDropShadow: false,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
    }

    return FlowyButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        color: Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.50),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
