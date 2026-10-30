import 'package:flutter/material.dart';
import '/ui/widgets/liquid_glass.dart';

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const CustomExpansionTile(
      {super.key,
      required this.children,
      required this.icon,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassContainer(
        borderRadius: BorderRadius.circular(20),
        blurSigma: 16,
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            textColor: Theme.of(context).textTheme.titleMedium!.color,
            iconColor: Theme.of(context).textTheme.titleMedium!.color,
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            leading: Icon(icon),
            children: children,
          ),
        ),
      ),
    );
  }
}
