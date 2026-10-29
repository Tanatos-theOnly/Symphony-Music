import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../screens/Settings/settings_screen_controller.dart';
import '/models/artist.dart';
import '../../models/album.dart';
import '../../models/playlist.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    this.song,
    this.playlist,
    this.album,
    this.artist,
    required this.size,
    this.isPlayerArtImage = false,
  });
  final MediaItem? song;
  final Playlist? playlist;
  final Album? album;
  final bool isPlayerArtImage;
  final Artist? artist;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = song != null
        ? song!.artUri.toString()
        : playlist != null
            ? playlist!.thumbnailUrl
            : album != null
                ? album!.thumbnailUrl
                : artist != null
                    ? artist!.thumbnailUrl
                    : "";

    /// only valid for offline songs
    final bool offlineAvailable =
        song != null && (song?.extras?["url"] ?? "").contains("file");

    final BorderRadius? effectiveRadius = artist != null
        ? null
        : BorderRadius.circular(
            isPlayerArtImage ? 24 : (size > 60 ? 14 : 10),
          );

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: artist != null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: effectiveRadius,
        boxShadow: isPlayerArtImage
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius ?? BorderRadius.circular(size / 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            offlineAvailable
                ? Image.file(
                    File(
                        "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${song!.id}.png"),
                    height: size,
                    width: size,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    height: size,
                    width: size,
                    memCacheHeight:
                        (song != null && !isPlayerArtImage) ? 140 : null,
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: artist != null
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: effectiveRadius,
                          ),
                          child: Image.asset(
                              "assets/icons/${song != null ? "song" : artist != null ? "artist" : "album"}.png"));
                    },
                    progressIndicatorBuilder: ((_, __, ___) =>
                        Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[600]!,
                            enabled: true,
                            direction: ShimmerDirection.ltr,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: artist != null
                                    ? BoxShape.circle
                                    : BoxShape.rectangle,
                                borderRadius: effectiveRadius,
                                color: Colors.white24,
                              ),
                            ))),
                  ),
            // Specular wet edge highlight for player art
            if (isPlayerArtImage)
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: effectiveRadius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
