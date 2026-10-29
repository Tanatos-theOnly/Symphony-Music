import 'dart:convert';
import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class StreamProvider {
  final bool playable;
  final List<Audio>? audioFormats;
  final String statusMSG;
  StreamProvider(
      {required this.playable, this.audioFormats, this.statusMSG = ""});

  static Future<Map<String, dynamic>?> _postInnertube(
    String url,
    Map<String, dynamic> body,
    Map<String, String> headers,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse(url));
      headers.forEach((k, v) => request.headers.set(k, v));
      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  static List<Audio> _parseAudioFromStreamingData(Map<String, dynamic> data) {
    final formats = data['streamingData']?['adaptiveFormats'] as List? ?? [];
    final loudness = (data['playerConfig']?['audioConfig']?['loudnessDb'] as num?)?.toDouble() ?? 0.0;
    final audioList = <Audio>[];

    for (final f in formats) {
      final mime = f['mimeType']?.toString() ?? '';
      final url = f['url']?.toString();
      if (mime.contains('audio') && url != null && url.isNotEmpty) {
        audioList.add(Audio(
          itag: (f['itag'] as num?)?.toInt() ?? 0,
          audioCodec: mime.contains('mp4') ? Codec.mp4a : Codec.opus,
          bitrate: (f['bitrate'] as num?)?.toInt() ?? 0,
          duration: int.tryParse(f['approxDurationMs']?.toString() ?? '0') ?? 0,
          loudnessDb: loudness,
          url: url,
          size: int.tryParse(f['contentLength']?.toString() ?? '0') ?? 0,
        ));
      }
    }
    return audioList;
  }

  static Future<StreamProvider> fetch(String videoId) async {
    String lastReason = "Song is unplayable";

    // Tier 1: ANDROID SDK-less client (current InnerTube standard, no PO-Token required)
    try {
      final androidData = await _postInnertube(
        'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
        {
          'context': {
            'client': {
              'clientName': 'ANDROID',
              'clientVersion': '20.10.38',
              'userAgent': 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
              'hl': 'en',
              'timeZone': 'UTC',
              'utcOffsetMinutes': 0,
              'osName': 'Android',
              'osVersion': '11',
            },
          },
          'videoId': videoId,
        },
        {
          'User-Agent': 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
          'X-Youtube-Client-Name': 'ANDROID',
          'X-Youtube-Client-Version': '20.10.38',
          'Content-Type': 'application/json',
        },
      );

      if (androidData != null) {
        final status = androidData['playabilityStatus']?['status']?.toString();
        final reason = androidData['playabilityStatus']?['reason']?.toString();
        if (reason != null && reason.isNotEmpty) lastReason = reason;

        if (status == 'OK') {
          final audios = _parseAudioFromStreamingData(androidData);
          if (audios.isNotEmpty) {
            return StreamProvider(
              playable: true,
              statusMSG: "OK",
              audioFormats: audios,
            );
          }
        }
      }
    } catch (e) {
      if (e is SocketException) {
        return StreamProvider(playable: false, statusMSG: "networkError");
      }
    }

    // Tier 2: IOS mobile client
    try {
      final iosData = await _postInnertube(
        'https://www.youtube.com/youtubei/v1/player?key=AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc&prettyPrint=false',
        {
          'context': {
            'client': {
              'clientName': 'IOS',
              'clientVersion': '20.10.4',
              'deviceMake': 'Apple',
              'deviceModel': 'iPhone16,2',
              'userAgent': 'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
              'hl': 'en',
              'platform': 'MOBILE',
              'osName': 'IOS',
              'osVersion': '18.1.0.22B83',
              'timeZone': 'UTC',
              'gl': 'US',
              'utcOffsetMinutes': 0,
            },
          },
          'videoId': videoId,
        },
        {
          'User-Agent': 'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
          'X-Youtube-Client-Name': 'IOS',
          'X-Youtube-Client-Version': '20.10.4',
          'Content-Type': 'application/json',
        },
      );

      if (iosData != null) {
        final status = iosData['playabilityStatus']?['status']?.toString();
        final reason = iosData['playabilityStatus']?['reason']?.toString();
        if (reason != null && reason.isNotEmpty) lastReason = reason;

        if (status == 'OK') {
          final audios = _parseAudioFromStreamingData(iosData);
          if (audios.isNotEmpty) {
            return StreamProvider(
              playable: true,
              statusMSG: "OK",
              audioFormats: audios,
            );
          }
        }
      }
    } catch (e) {
      if (e is SocketException) {
        return StreamProvider(playable: false, statusMSG: "networkError");
      }
    }

    // Tier 3: YoutubeExplode fallback
    final yt = YoutubeExplode();
    try {
      final res = await yt.videos.streamsClient.getManifest(videoId);
      final audio = res.audioOnly;
      if (audio.isNotEmpty) {
        return StreamProvider(
            playable: true,
            statusMSG: "OK",
            audioFormats: audio
                .map((e) => Audio(
                    itag: e.tag,
                    audioCodec:
                        e.audioCodec.contains('mp') ? Codec.mp4a : Codec.opus,
                    bitrate: e.bitrate.bitsPerSecond,
                    duration: e.duration ?? 0,
                    loudnessDb: e.loudnessDb,
                    url: e.url.toString(),
                    size: e.size.totalBytes))
                .toList());
      }
    } catch (e) {
      if (e is SocketException) {
        return StreamProvider(
          playable: false,
          statusMSG: "networkError",
        );
      } else if (e is VideoUnplayableException) {
        lastReason = e.reason ?? lastReason;
      } else if (e is VideoRequiresPurchaseException) {
        lastReason = "Song requires purchase";
      } else if (e is VideoUnavailableException) {
        lastReason = "Song is unavailable";
      } else if (e is YoutubeExplodeException) {
        lastReason = e.message;
      }
    } finally {
      yt.close();
    }

    return StreamProvider(
      playable: false,
      statusMSG: lastReason,
    );
  }

  Audio? get highestQualityAudio =>
      audioFormats?.lastWhere((item) => item.itag == 251 || item.itag == 140,
          orElse: () => audioFormats!.first);

  Audio? get highestBitrateMp4aAudio =>
      audioFormats?.lastWhere((item) => item.itag == 140 || item.itag == 139,
          orElse: () => audioFormats!.first);

  Audio? get highestBitrateOpusAudio =>
      audioFormats?.lastWhere((item) => item.itag == 251 || item.itag == 250,
          orElse: () => audioFormats!.first);

  Audio? get lowQualityAudio =>
      audioFormats?.lastWhere((item) => item.itag == 249 || item.itag == 139,
          orElse: () => audioFormats!.first);

  Map<String, dynamic> get hmStreamingData {
    return {
      "playable": playable,
      "statusMSG": statusMSG,
      "lowQualityAudio": lowQualityAudio?.toJson(),
      "highQualityAudio": highestQualityAudio?.toJson()
    };
  }
}

class Audio {
  final int itag;
  final Codec audioCodec;
  final int bitrate;
  final int duration;
  final int size;
  final double loudnessDb;
  final String url;
  Audio(
      {required this.itag,
      required this.audioCodec,
      required this.bitrate,
      required this.duration,
      required this.loudnessDb,
      required this.url,
      required this.size});

  Map<String, dynamic> toJson() => {
        "itag": itag,
        "audioCodec": audioCodec.toString(),
        "bitrate": bitrate,
        "loudnessDb": loudnessDb,
        "url": url,
        "approxDurationMs": duration,
        "size": size
      };

  factory Audio.fromJson(json) => Audio(
      audioCodec: (json["audioCodec"] as String).contains("mp4a")
          ? Codec.mp4a
          : Codec.opus,
      itag: json['itag'],
      duration: json["approxDurationMs"] ?? 0,
      bitrate: json["bitrate"] ?? 0,
      loudnessDb: (json['loudnessDb'])?.toDouble() ?? 0.0,
      url: json['url'],
      size: json["size"] ?? 0);
}

enum Codec { mp4a, opus }
