
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '/ui/player/components/gesture_player.dart';
import '/ui/player/components/standard_player.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '/ui/utils/theme_controller.dart';
import '/ui/widgets/liquid_glass.dart';
import '../../utils/helper.dart';
import '../widgets/snackbar.dart';
import '../widgets/up_next_queue.dart';
import '/ui/player/player_controller.dart';
import '../widgets/sliding_up_panel.dart';

/// Player screen
/// Contains the player ui
///
/// Player ui can be standard player or gesture player
class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final settingsScreenController = Get.find<SettingsScreenController>();
    final themeCtrl = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : null;

    return Scaffold(
      /// SlidingUpPanel is used to create a panel that can slide up and down
      /// It is used to show the current queue panel in mobile
      body: Obx(
        () => SlidingUpPanel(
          boxShadow: const [],
          minHeight: settingsScreenController.playerUi.value == 0
              ? 65 + Get.mediaQuery.padding.bottom
              : 0,
          maxHeight: size.height,
          isDraggable: !GetPlatform.isDesktop,
          controller: GetPlatform.isDesktop
              ? null
              : playerController.queuePanelController,

          /// this is the header of the collapsed panel
          /// contains the Apple-style pill grabber to open the queue panel
          collapsed: InkWell(
            onTap: () {
              if (GetPlatform.isDesktop) {
                playerController.homeScaffoldkey.currentState!.openEndDrawer();
              } else {
                playerController.queuePanelController.open();
              }
            },
            child: LiquidGlassContainer(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              blurSigma: 24,
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 65,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Panel for queue
          panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
            playerController.scrollController = sc;
            return Stack(
              children: [
                /// Stack first child
                /// UpNextQueue widget contains list of songs in queue
                UpNextQueue(
                  onReorderEnd: onReorderEnd,
                  onReorderStart: onReorderStart,
                ),

                /// Stack second child
                /// This contains the bottom bar with queue loop, shuffle, clear queue buttons
                /// and number of songs in queue
                Align(
                  alignment: Alignment.bottomCenter,
                  child: LiquidGlassContainer(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    blurSigma: 24,
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 10, left: 14, right: 14),
                    child: SizedBox(
                      height: 60 + Get.mediaQuery.padding.bottom,
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// number of songs in queue
                              Obx(
                                () => Text(
                                  "${playerController.currentQueue.length} ${"songs".tr}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white
                                              .withValues(alpha: 0.85)),
                                ),
                              ),

                              Row(
                                children: [
                                  /// queue loop button
                                  FlowyButton(
                                    onTap: () {
                                      playerController.toggleQueueLoopMode();
                                    },
                                    child: Obx(
                                      () {
                                        final isLoop = playerController
                                            .isQueueLoopModeEnabled.isTrue;
                                        final activeColor = themeCtrl
                                                ?.primaryColor.value ??
                                            const Color(0xFF4FA5FF);

                                        return isLoop
                                            ? LiquidGlassPebble(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                chromaticColor: activeColor,
                                                highlightIntensity: 1.0,
                                                hasDropShadow: false,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 6),
                                                child: Text(
                                                  "queueLoop".tr,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 32,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.10),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.18),
                                                    width: 0.7,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "queueLoop".tr,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.75),
                                                    ),
                                                  ),
                                                ),
                                              );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  /// queue shuffle button
                                  FlowyButton(
                                    onTap: () {
                                      if (playerController
                                          .isShuffleModeEnabled.isTrue) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar(
                                                context,
                                                "queueShufflingDeniedMsg".tr,
                                                size: SanckBarSize.BIG));
                                        return;
                                      }
                                      playerController.shuffleQueue();
                                    },
                                    child: LiquidGlassPebble(
                                      width: 42,
                                      height: 32,
                                      borderRadius: BorderRadius.circular(18),
                                      chromaticColor: const Color(0xFF4FA5FF),
                                      highlightIntensity: 0.85,
                                      hasDropShadow: false,
                                      padding: EdgeInsets.zero,
                                      child: const Icon(
                                        Icons.shuffle,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  /// clear queue button
                                  FlowyButton(
                                    onTap: () {
                                      playerController.clearQueue();
                                    },
                                    child: LiquidGlassPebble(
                                      width: 42,
                                      height: 32,
                                      borderRadius: BorderRadius.circular(18),
                                      chromaticColor: const Color(0xFF4FA5FF),
                                      highlightIntensity: 0.85,
                                      hasDropShadow: false,
                                      padding: EdgeInsets.zero,
                                      child: const Icon(
                                        Icons.playlist_remove,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },

          /// show player ui based on selected player ui in settings
          /// Gesture player is only applicable for mobile
          body: settingsScreenController.playerUi.value == 0
              ? const StandardPlayer()
              : const GesturePlayer(),
        ),
      ),
    );
  }
}
