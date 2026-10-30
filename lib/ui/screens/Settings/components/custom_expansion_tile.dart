import 'package:flutter/material.dart';

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x1FFFFFFF),
              Color(0x0AFFFFFF),
              Color(0x180D1117),
              Color(0x12FFFFFF),
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
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
