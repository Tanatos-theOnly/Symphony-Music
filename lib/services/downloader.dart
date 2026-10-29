import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_expl;

import '../ui/widgets/download_failed_dialog.dart';
import '../ui/screens/Album/album_screen_controller.dart';
import '../ui/screens/Playlist/playlist_screen_controller.dart';
import '/services/stream_service.dart';
import '../ui/widgets/snackbar.dart';
import '/services/permission_service.dart';
import '../ui/screens/Settings/settings_screen_controller.dart';
import '/utils/helper.dart';
import '/models/media_Item_builder.dart';
import '../ui/screens/Library/library_controller.dart';
import 'music_service.dart';
//import '../models/thumbnail.dart' as th;

class Downloader extends GetxService {
  final _dio = Dio();
  MediaItem? currentSong;
  RxMap<String, List<MediaItem>> playlistQueue =
      <String, List<MediaItem>>{}.obs;
  final currentPlaylistId = "".obs;
  final songDownloadingProgress = 0.obs;
  final playlistDownloadingProgress = 0.obs;
  final isJobRunning = false.obs;

  RxList<MediaItem> songQueue = <MediaItem>[].obs;

  Future<bool> checkPermissionNDir() async {
    final settingsScreenController = Get.find<SettingsScreenController>();

    if (!settingsScreenController.isCurrentPathsupportDownDir &&
        !await PermissionService.getExtStoragePermission()) {
      return false;
    }

    final dirPath =
        Get.find<SettingsScreenController>().downloadLocationPath.string;
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return true;
  }

  Future<void> downloadPlaylist(
      String playlistId, List<MediaItem> songList) async {
    if (!(await checkPermissionNDir())) return;

    // for toggle between downloading request & cancelling
    if (playlistQueue.containsKey(playlistId)) {
      songQueue.removeWhere((element) => songList.contains(element));
      playlistQueue.remove(playlistId);
      return;
    }

    playlistQueue[playlistId] = songList;
    songQueue.addAll(songList);

    if (isJobRunning.isFalse) {
      await triggerDownloadingJob();
    }
  }

  Future<void> download(MediaItem? song, {List<MediaItem>? songList}) async {
    if (!(await checkPermissionNDir())) return;
    if (songList != null) {
      songQueue.addAll(songList);
    } else {
      songQueue.add(song!);
    }
    if (isJobRunning.isFalse) {
      await triggerDownloadingJob();
    }
  }

  Future<void> triggerDownloadingJob() async {
    //check if playlist download in queue => download playlistsongs else download from general songs queue
    if (playlistQueue.isNotEmpty) {
      isJobRunning.value = true;
      for (String playlistId in playlistQueue.keys.toList()) {
        //checked in case download cancel request
        if (playlistQueue.containsKey(playlistId)) {
          currentPlaylistId.value = playlistId;
          await downloadSongList((playlistQueue[playlistId]!).toList(),
              isPlaylist: true);
          if (Get.isRegistered<PlaylistScreenController>(
                  tag: Key(playlistId).hashCode.toString()) &&
              playlistQueue.containsKey(playlistId)) {
            Get.find<PlaylistScreenController>(
                    tag: Key(playlistId).hashCode.toString())
                .isDownloaded
                .value = true;
          } 
          // in case of album
          else if (Get.isRegistered<AlbumScreenController>(
                  tag: Key(playlistId).hashCode.toString()) &&
              playlistQueue.containsKey(playlistId)) {
            Get.find<AlbumScreenController>(
                    tag: Key(playlistId).hashCode.toString())
                .isDownloaded
                .value = true;
          }
          playlistQueue.remove(playlistId);
        }
        currentPlaylistId.value = "";
        playlistDownloadingProgress.value = 0;
      }
    } else {
      isJobRunning.value = true;
      await downloadSongList(songQueue.toList());
    }

    if (songQueue.isNotEmpty) {
      triggerDownloadingJob();
    } else {
      isJobRunning.value = false;
      currentSong = null;
    }
  }

  Future<void> downloadSongList(List<MediaItem> jobSongList,
      {bool isPlaylist = false}) async {
    for (MediaItem song in jobSongList) {
      // intrrupt downloading task in case of playlist download cancel request
      if (isPlaylist && !playlistQueue.containsKey(currentPlaylistId.value)) {
        currentPlaylistId.value = "";
        playlistDownloadingProgress.value = 0;
        return;
      }

      if (!Hive.box("SongDownloads").containsKey(song.id)) {
        currentSong = song;
        songDownloadingProgress.value = 0;
        await writeFileStream(song);
      }
      songQueue.remove(song);
      //for playlist downloading counter update
      if (isPlaylist) {
        playlistDownloadingProgress.value = jobSongList.indexOf(song) + 1;
      }
    }
  }

  Future<void> writeFileStream(MediaItem song) async {
    Completer<void> complete = Completer();

    final settingsScreenController = Get.find<SettingsScreenController>();
    final downloadingFormat = settingsScreenController.downloadingFormat.string;

    yt_expl.YoutubeExplode? yt;
    try {
      final streamProvider = await StreamProvider.fetch(song.id);
      if (!streamProvider.playable ||
          streamProvider.audioFormats == null ||
          streamProvider.audioFormats!.isEmpty) {
        throw Exception(streamProvider.statusMSG.isNotEmpty
            ? streamProvider.statusMSG
            : "No audio streams found");
      }

      final audioStreams = streamProvider.audioFormats!;
      final requiredAudio = downloadingFormat == "opus"
          ? (streamProvider.highestBitrateOpusAudio ?? audioStreams.first)
          : (streamProvider.highestBitrateMp4aAudio ?? audioStreams.first);

      final dirPath = settingsScreenController.downloadLocationPath.string;
      final actualDownformat =
          requiredAudio.audioCodec == Codec.mp4a ? "m4a" : "opus";
      final RegExp invalidChar =
          RegExp(r'Container.|\/|\\|\"|\<|\>|\*|\?|\:|\!|\[|\]|\¡|\||\%');
      final songTitle = "${song.title.trim()} (${song.artist?.trim()})"
          .replaceAll(invalidChar, "");
      String filePath = "$dirPath/$songTitle.$actualDownformat";
      printINFO("Downloading filePath: $filePath");

      final file = File(filePath);
      final output = file.openWrite(mode: FileMode.writeOnly);

      int count = 0;
      final total = requiredAudio.size;

      final client = HttpClient();
      try {
        final uri = Uri.parse(requiredAudio.url);
        final request = await client.getUrl(uri);
        request.headers.set('User-Agent',
            'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip');
        final response = await request.close();
        if (response.statusCode == 200 || response.statusCode == 206) {
          await for (final data in response) {
            count += data.length;
            output.add(data);
            if (total > 0) {
              songDownloadingProgress.value =
                  ((count / total) * 100).toInt();
            }
          }
        } else {
          // Fallback to youtube_explode stream if available
          yt = yt_expl.YoutubeExplode();
          final manifest = await yt.videos.streamsClient.getManifest(song.id);
          final ytStreams = manifest.audioOnly;
          final ytRequired = downloadingFormat == "opus"
              ? ytStreams.lastWhere(
                  (item) => item.tag == 251 || item.tag == 250,
                  orElse: () => ytStreams.first)
              : ytStreams.lastWhere(
                  (item) => item.tag == 140 || item.tag == 139,
                  orElse: () => ytStreams.first);
          final stream = yt.videos.streamsClient.get(ytRequired);
          final ytTotal = ytRequired.size.totalBytes;
          await for (final data in stream) {
            count += data.length;
            output.add(data);
            if (ytTotal > 0) {
              songDownloadingProgress.value =
                  ((count / ytTotal) * 100).toInt();
            }
          }
        }
      } finally {
        await output.flush();
        await output.close();
        client.close();
      }

      String? year;
      try {
        if (song.extras?['year'] != null) {
          year = song.extras?['year'];
        } else {
          if (song.album != null) {
            final musicServ = Get.find<MusicServices>();
            year = await musicServ.getSongYear(song.id);
          }
        }
      } catch (_) {}

      // Save Thumbnail
      try {
        final thumbnailPath =
            "${settingsScreenController.supportDirPath}/thumbnails/${song.id}.png";
        await _dio.downloadUri(song.artUri!, thumbnailPath);
        // ignore: empty_catches
      } catch (e) {}

      song.extras?['url'] = filePath;
      final songJson = MediaItemBuilder.toJson(song);
      
      final streamInfoJson = {
        "itag": requiredAudio.itag,
        "audioCodec": requiredAudio.audioCodec == Codec.mp4a ? "Codec.mp4a" : "Codec.opus",
        "bitrate": requiredAudio.bitrate,
        "loudnessDb": requiredAudio.loudnessDb,
        "url": filePath,
        "approxDurationMs": song.duration?.inMilliseconds ?? requiredAudio.duration,
        "size": count > 0 ? count : requiredAudio.size
      };
      
      songJson["streamInfo"] = [true, streamInfoJson];

      Hive.box("SongDownloads").put(song.id, songJson);
      Get.find<LibrarySongsController>().librarySongsList.add(song);
      printINFO("Downloaded successfully");

      final trackDetails = (song.extras?['trackDetails'])?.split("/");
      final int? trackNumber = int.tryParse(trackDetails?[0] ?? "");
      final int? totalTracks = int.tryParse(trackDetails?[1] ?? "");

      try {
        /// Reverted -- Removed AudioTags as using this package, app is flagged as TROJ_GEN.R002V01K623 by TrendMicro-HouseCall
        final imageUrl = song.artUri!.toString();
        Tag tag = Tag(
            title: song.title,
            trackArtist: song.artist,
            album: song.album,
            year: int.tryParse(year ?? ""),
            trackNumber: trackNumber,
            trackTotal: totalTracks,
            albumArtist: song.artist,
            genre: song.genre,
            pictures: [
              Picture(
                  bytes: (await NetworkAssetBundle(Uri.parse((imageUrl)))
                          .load(imageUrl))
                      .buffer
                      .asUint8List(),
                  mimeType: MimeType.png,
                  pictureType: PictureType.coverFront)
            ]);

        await AudioTags.write(filePath, tag);
      } catch (e) {
        printERROR("$e");
      }
      complete.complete();
    } catch (error, stackTrace) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
          Get.context!, "downloadError3".tr,
          size: SanckBarSize.BIG,
          duration: const Duration(seconds: 2),
          top: !GetPlatform.isDesktop));
      showDialog(
        context: Get.context!,
        builder: (context) => DownloadFailedDialog(songTitle: song.title),
      );
      printINFO("Downloading failed due to error: $error\n$stackTrace");
      complete.complete();
    } finally {
      yt?.close();
    }

    return complete.future;
  }
}
