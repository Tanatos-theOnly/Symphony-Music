import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:symphonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:symphonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:symphonymusic/ui/utils/theme_controller.dart';
import 'liquid_glass.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    final settingsController = Get.find<SettingsScreenController>();
    final themeCtrl = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : null;

    final menuItems = [
      {'icon': Ionicons.home_outline, 'activeIcon': Ionicons.home, 'label': 'home'.tr},
      {'icon': Ionicons.musical_notes_outline, 'activeIcon': Ionicons.musical_notes, 'label': 'songs'.tr},
      {'icon': Ionicons.list_outline, 'activeIcon': Ionicons.list, 'label': 'playlists'.tr},
      {'icon': Ionicons.disc_outline, 'activeIcon': Ionicons.disc, 'label': 'albums'.tr},
      {'icon': Ionicons.people_outline, 'activeIcon': Ionicons.people, 'label': 'artists'.tr},
      {'icon': Ionicons.settings_outline, 'activeIcon': Ionicons.settings, 'label': 'settings'.tr},
    ];

    // Increased spacing for relaxed, deliberate thumb scrubbing
    const itemHeight = 70.0;
    const verticalPadding = 10.0;
    final trackHeight = (menuItems.length * itemHeight) + (verticalPadding * 2);
    const trackWidth = 68.0;
    const pebbleWidth = 76.0;
    const pebbleHeight = 58.0;
    const containerWidth = 84.0;

    return Obx(() {
      final activeColor = themeCtrl?.primaryColor.value ??
          const Color(0xFF4FA5FF);
      final rawIndex = homeScreenController.tabIndex.value;
      final selectedIndex = rawIndex.clamp(0, menuItems.length - 1);

      return Container(
        width: containerWidth,
        alignment: Alignment.center,
        child: SafeArea(
          right: false,
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: containerWidth,
                      height: trackHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // 1. The Vertical Translucent Obsidian Pill Dock Track
                          Container(
                            width: trackWidth,
                            height: trackHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xC00B0D12),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 22,
                                  offset: const Offset(4, 6),
                                ),
                              ],
                            ),
                          ),

                          // 2. The 3D Liquid Glass Pebble Indicator (Fluid Vertical Sliding Dome)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            top: verticalPadding +
                                (selectedIndex * itemHeight) +
                                (itemHeight - pebbleHeight) / 2,
                            left: (containerWidth - pebbleWidth) / 2,
                            width: pebbleWidth,
                            height: pebbleHeight,
                            child: IgnorePointer(
                              child: LiquidGlassPebble(
                                borderRadius: BorderRadius.circular(22),
                                chromaticColor: activeColor,
                                highlightIntensity: 1.0,
                                hasDropShadow: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 3),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      menuItems[selectedIndex]['activeIcon'] as IconData,
                                      size: 21,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.white.withValues(alpha: 0.60),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      modifyNgetlabel(
                                          menuItems[selectedIndex]['label'] as String),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.0,
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

                          // 3. Menu Item Touch Zones & Inactive Icons with Spaced Vertical Scrubbing Gesture
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onVerticalDragDown: (details) {
                              _onVerticalScrub(
                                details.localPosition.dy,
                                itemHeight,
                                verticalPadding,
                                menuItems.length,
                                homeScreenController,
                              );
                            },
                            onVerticalDragUpdate: (details) {
                              _onVerticalScrub(
                                details.localPosition.dy,
                                itemHeight,
                                verticalPadding,
                                menuItems.length,
                                homeScreenController,
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: verticalPadding),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(menuItems.length, (index) {
                                  final isSelected = selectedIndex == index;
                                  final item = menuItems[index];

                                  return FlowyButton(
                                    onTap: () => homeScreenController
                                        .onSideBarTabSelected(index),
                                    child: SizedBox(
                                      width: trackWidth,
                                      height: itemHeight,
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 200),
                                        opacity: isSelected ? 0.0 : 1.0,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              item['icon'] as IconData,
                                              size: 21,
                                              color: Colors.white
                                                  .withValues(alpha: 0.50),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              modifyNgetlabel(
                                                  item['label'] as String),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10.0,
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
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quick Toggle to switch from Left Side Dock to Bottom Dock with 1 tap
                    FlowyButton(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        settingsController.enableBottomNavBar(true);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xC00B0D12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Tooltip(
                          message: "Switch to Bottom Dock",
                          child: Center(
                            child: Icon(
                              Icons.dock_rounded,
                              size: 20,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _onVerticalScrub(
    double localY,
    double itemHeight,
    double verticalPadding,
    int count,
    HomeScreenController homeScreenController,
  ) {
    if (count <= 0) return;
    final effectiveY = localY - verticalPadding;
    final targetIndex = (effectiveY / itemHeight).floor().clamp(0, count - 1);
    if (targetIndex != homeScreenController.tabIndex.value) {
      HapticFeedback.selectionClick();
      homeScreenController.onSideBarTabSelected(targetIndex);
    }
  }

  String modifyNgetlabel(String label) {
    if (label.length > 8) {
      return "${label.substring(0, 7)}..";
    }
    return label;
  }
}
