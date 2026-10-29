import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/ui/player/components/lyrics_widget.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/liquid_glass.dart';
import '/ui/utils/theme_controller.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/sleep_timer_bottom_sheet.dart';
import '../../widgets/songinfo_bottom_sheet.dart';

class AlbumArtNLyrics extends StatelessWidget {
  const AlbumArtNLyrics({super.key, required this.playerArtImageSize});
  final double playerArtImageSize;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();

    return Obx(() => playerController.currentSong.value != null
        ? Stack(
            children: [
              GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                    constraints: const BoxConstraints(maxWidth: 500),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.0)),
                    ),
                    isScrollControlled: true,
                    context:
                        playerController.homeScaffoldkey.currentState!.context,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    builder: (context) => SongInfoBottomSheet(
                      playerController.currentSong.value!,
                      calledFromPlayer: true,
                    ),
                  ).whenComplete(() => Get.delete<SongInfoController>());
                },
                onTap: () {
                  playerController.showLyrics();
                },
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (playerController.showLyricsflag.isTrue) return;
                  if (details.primaryVelocity! < 0) {
                    playerController.next();
                  } else if (details.primaryVelocity! > 0) {
                    playerController.prev();
                  }
                },
                child: ImageWidget(
                  size: playerArtImageSize,
                  song: playerController.currentSong.value!,
                  isPlayerArtImage: true,
                ),
              ),
              Obx(() => playerController.showLyricsflag.isTrue
                  ? InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        playerController.showLyrics();
                      },
                      child: LiquidGlassPebble(
                        borderRadius: BorderRadius.circular(24),
                        chromaticColor: Get.isRegistered<ThemeController>()
                            ? Get.find<ThemeController>().primaryColor.value
                            : null,
                        highlightIntensity: 1.0,
                        hasDropShadow: false,
                        width: playerArtImageSize,
                        height: playerArtImageSize,
                        padding: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            LyricsWidget(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: playerArtImageSize / 3.5,
                              ),
                            ),
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xE00C0F17),
                                      Colors.transparent,
                                      Colors.transparent,
                                      Color(0xE00C0F17),
                                    ],
                                    stops: [0.0, 0.22, 0.78, 1.0],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              if (playerController.isSleepTimerActive.isTrue)
                SizedBox(
                  width: playerArtImageSize,
                  height: playerArtImageSize,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlowyButton(
                        child: LiquidGlassContainer(
                          borderRadius: BorderRadius.circular(16),
                          blurSigma: 16.0,
                          borderWidth: 0.8,
                          padding: EdgeInsets.zero,
                          width: 52,
                          height: 44,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showModalBottomSheet(
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20.0)),
                                ),
                                isScrollControlled: true,
                                context: playerController
                                    .homeScaffoldkey.currentState!.context,
                                barrierColor:
                                    Colors.black.withValues(alpha: 0.5),
                                builder: (context) =>
                                    const SleepTimerBottomSheet(),
                              );
                            },
                            icon: const Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          )
        : Container());
  }
}
