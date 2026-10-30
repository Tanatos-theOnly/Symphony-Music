import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'liquid_glass.dart';

class ProceedButton extends StatelessWidget {
  const ProceedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FlowyButton(
      onTap: onPressed,
      child: LiquidGlassPebble(
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        chromaticColor: const Color(0xFF4FA5FF),
        highlightIntensity: 1.1,
        hasDropShadow: false,
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FlowyButton(
      onTap: () {
        Navigator.of(context).pop();
        if (onPressed != null) {
          onPressed!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
        child: Text(
          "cancel".tr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
