import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      {'icon': Ionicons.musical_notes_outline, 'activeIcon': Ionicons.musical_notes, 'label': 'songs'.tr},
      {'icon': Ionicons.library_outline, 'activeIcon': Ionicons.library, 'label': 'library'.tr},
      {'icon': Ionicons.settings_outline, 'activeIcon': Ionicons.settings, 'label': 'settings'.tr},
    ];

    return Obx(() {
      final activeColor = themeCtrl?.primaryColor.value ??
          const Color(0xFF4FA5FF);
      final rawIndex = homeScreenController.tabIndex.value;
      final selectedIndex = rawIndex.clamp(0, tabs.length - 1);
      final bottomPadding = MediaQuery.of(context).padding.bottom;

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomPadding > 0 ? 0 : 8,
            top: 6,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final trackWidth = (totalWidth - 36.0).clamp(300.0, 420.0);
              final tabWidth = trackWidth / tabs.length;
              final pebbleWidth = (tabWidth - 4.0).clamp(60.0, 96.0);
              const pebbleHeight = 52.0;
              const trackHeight = 60.0;
              final targetLeft = (selectedIndex * tabWidth) + (tabWidth - pebbleWidth) / 2;

              return Center(
                child: SizedBox(
                  width: trackWidth,
                  height: trackHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // 1. The Elongated Matte Obsidian Pill Dock Track
                      Container(
                        width: trackWidth,
                        height: trackHeight,
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

                      // 2. The 3D Liquid Glass Pebble Indicator (DIRECT CHILD OF STACK!)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        left: targetLeft,
                        top: (trackHeight - pebbleHeight) / 2,
                        width: pebbleWidth,
                        height: pebbleHeight,
                        child: IgnorePointer(
                          child: LiquidGlassPebble(
                            borderRadius: BorderRadius.circular(20),
                            chromaticColor: activeColor,
                            highlightIntensity: 1.0,
                            hasDropShadow: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  tabs[selectedIndex]['activeIcon'] as IconData,
                                  size: 20,
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 3. Tab Touch Zones & Inactive Icons (DIRECT CHILD OF STACK!)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragDown: (details) {
                          _onHorizontalScrub(details.localPosition.dx, trackWidth,
                              tabs.length, homeScreenController);
                        },
                        onHorizontalDragUpdate: (details) {
                          _onHorizontalScrub(details.localPosition.dx, trackWidth,
                              tabs.length, homeScreenController);
                        },
                        child: Row(
                          children: List.generate(tabs.length, (index) {
                            final isSelected = selectedIndex == index;
                            final tab = tabs[index];

                            return SizedBox(
                              width: tabWidth,
                              height: trackHeight,
                              child: FlowyButton(
                                onTap: () => homeScreenController
                                    .onBottonBarTabSelected(index),
                                child: Container(
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
                                          size: 20,
                                          color: Colors.white
                                              .withValues(alpha: 0.50),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          modifyNgetlabel(tab['label'] as String),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white
                                                .withValues(alpha: 0.45),
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
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  void _onHorizontalScrub(double localX, double totalWidth, int count,
      HomeScreenController homeScreenController) {
    if (totalWidth <= 0 || count <= 0) return;
    final tabWidth = totalWidth / count;
    final targetIndex = (localX / tabWidth).floor().clamp(0, count - 1);
    if (targetIndex != homeScreenController.tabIndex.toInt()) {
      HapticFeedback.selectionClick();
      homeScreenController.onBottonBarTabSelected(targetIndex);
    }
  }

  String modifyNgetlabel(String label) {
    if (label.length > 9) {
      return '..';
    }
    return label;
  }
}
