import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:symphonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:symphonymusic/ui/utils/theme_controller.dart';
import 'liquid_glass.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    final themeCtrl = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : null;

    final tabs = [
      {'icon': Ionicons.home_outline, 'activeIcon': Ionicons.home, 'label': 'home'.tr},
      {'icon': Ionicons.search_outline, 'activeIcon': Ionicons.search, 'label': 'search'.tr},
      {'icon': Ionicons.musical_notes_outline, 'activeIcon': Ionicons.musical_notes, 'label': 'library'.tr},
      {'icon': Ionicons.settings_outline, 'activeIcon': Ionicons.settings, 'label': 'settings'.tr},
    ];

    return Obx(() {
      final activeColor = themeCtrl?.primaryColor.value ??
          const Color(0xFF4FA5FF);
      final selectedIndex = homeScreenController.tabIndex.toInt();
      final bottomPadding = MediaQuery.of(context).padding.bottom;

      return Container(
        padding: EdgeInsets.only(
          bottom: bottomPadding > 0 ? bottomPadding : 10,
          left: 18,
          right: 18,
          top: 6,
        ),
        color: Colors.transparent,
        child: SizedBox(
          height: 68,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. The Elongated Matte Obsidian Pill Dock Track
              Container(
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xF20B0D12),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.50),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),

              // 2. The 3D Liquid Glass Pebble Indicator (Fluid Sliding Dome)
              LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / tabs.length;
                  final alignX = -1.0 +
                      (selectedIndex * (2.0 / (tabs.length - 1)));

                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment(alignX, 0.0),
                    child: SizedBox(
                      width: tabWidth + 8,
                      height: 66, // 3D Dome gracefully bulges over the 58px track!
                      child: LiquidGlassPebble(
                        borderRadius: BorderRadius.circular(22),
                        chromaticColor: activeColor,
                        highlightIntensity: 1.0,
                        hasDropShadow: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tabs[selectedIndex]['activeIcon'] as IconData,
                              size: 21,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.white.withValues(alpha: 0.60),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              modifyNgetlabel(
                                  tabs[selectedIndex]['label'] as String),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 3. Tab Touch Zones & Inactive Icons
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedIndex == index;
                  final tab = tabs[index];

                  return Expanded(
                    child: FlowyButton(
                      onTap: () =>
                          homeScreenController.onBottonBarTabSelected(index),
                      child: Container(
                        height: 58,
                        color: Colors.transparent,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 0.0 : 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tab['icon'] as IconData,
                                size: 21,
                                color: Colors.white.withValues(alpha: 0.50),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                modifyNgetlabel(tab['label'] as String),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.45),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  String modifyNgetlabel(String label) {
    if (label.length > 9) {
      return "${label.substring(0, 8)}..";
    }
    return label;
  }
}
