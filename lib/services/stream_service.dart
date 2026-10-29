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
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      final request = await client.postUrl(Uri.parse(url)).timeout(const Duration(seconds: 5));
      headers.forEach((k, v) => request.headers.set(k, v));
      request.write(jsonEncode(body));
      final response = await request.close().timeout(const Duration(seconds: 5));
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

  static Future<StreamProvider?> _fetchInvidious(String videoId) async {
    final instances = [
      'https://inv.nadeko.net',
      'https://invidious.nerdvpn.de',
      'https://invidious.flokinet.to',
      'https://iv.ggtyler.dev',
      'https://invidious.no-valis.be',
    ];

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      for (final inst in instances) {
        try {
          final req = await client
              .getUrl(Uri.parse('$inst/api/v1/videos/$videoId'))
              .timeout(const Duration(seconds: 4));
          final resp = await req.close().timeout(const Duration(seconds: 4));
          if (resp.statusCode == 200) {
            final body = await resp.transform(utf8.decoder).join();
            final data = jsonDecode(body);
            final adaptiveFormats = data['adaptiveFormats'] as List? ?? [];
            final audioList = <Audio>[];
            for (final f in adaptiveFormats) {
              final type = f['type']?.toString() ?? '';
              final url = f['url']?.toString();
              if (type.contains('audio') && url != null && url.isNotEmpty) {
                audioList.add(Audio(
                  itag: int.tryParse(f['itag']?.toString() ?? '0') ?? 0,
                  audioCodec: type.contains('mp4') ? Codec.mp4a : Codec.opus,
                  bitrate: int.tryParse(f['bitrate']?.toString() ?? '0') ?? 0,
                  duration: int.tryParse(f['approxDurationMs']?.toString() ?? '0') ?? 0,
                  loudnessDb: 0.0,
                  url: url,
                  size: int.tryParse(f['clen']?.toString() ?? f['contentLength']?.toString() ?? '0') ?? 0,
                ));
              }
            }
            if (audioList.isNotEmpty) {
              return StreamProvider(
                playable: true,
                statusMSG: "OK",
                audioFormats: audioList,
              );
            }
          }
        } catch (_) {
          continue;
        }
      }
    } finally {
      client.close();
    }
    return null;
  }

  static Future<StreamProvider> fetch(String videoId) async {
    String lastReason = "Song is unplayable";

    // Tier 1: VISIONOS client (Echo-Music / Musify primary engine - whole-file capable without 403 throttling)
    try {
      final visionOsData = await _postInnertube(
        'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
        {
          'context': {
            'client': {
              'clientName': 'VISIONOS',
              'clientVersion': '0.1',
              'deviceMake': 'Apple',
              'deviceModel': 'RealityDevice14,1',
              'osName': 'visionOS',
              'osVersion': '1.3.21O771',
              'hl': 'en',
              'gl': 'US',
            },
          },
          'videoId': videoId,
        },
        {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15',
          'X-Youtube-Client-Name': '101',
          'X-Youtube-Client-Version': '0.1',
          'Content-Type': 'application/json',
        },
      );

      if (visionOsData != null) {
        final status = visionOsData['playabilityStatus']?['status']?.toString();
        final reason = visionOsData['playabilityStatus']?['reason']?.toString();
        if (reason != null && reason.isNotEmpty) lastReason = reason;

        if (status == 'OK') {
          final audios = _parseAudioFromStreamingData(visionOsData);
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

    // Tier 2: ANDROID_VR client (Echo-Music secondary engine)
    try {
      final vrData = await _postInnertube(
        'https://www.youtube.com/youtubei/v1/player?prettyPrint=false',
        {
          'context': {
            'client': {
              'clientName': 'ANDROID_VR',
              'clientVersion': '1.65.10',
              'deviceMake': 'Oculus',
              'deviceModel': 'Quest 3',
              'osName': 'Android',
              'osVersion': '12L',
              'androidSdkVersion': '32',
              'hl': 'en',
              'gl': 'US',
            },
          },
          'videoId': videoId,
        },
        {
          'User-Agent':
              'com.google.android.apps.youtube.vr.oculus/1.65.10 (Linux; U; Android 12L; eureka-user Build/SQ3A.220605.009.A1) gzip',
          'X-Youtube-Client-Name': '28',
          'X-Youtube-Client-Version': '1.65.10',
          'Content-Type': 'application/json',
        },
      );

      if (vrData != null) {
        final status = vrData['playabilityStatus']?['status']?.toString();
        final reason = vrData['playabilityStatus']?['reason']?.toString();
        if (reason != null && reason.isNotEmpty) lastReason = reason;

        if (status == 'OK') {
          final audios = _parseAudioFromStreamingData(vrData);
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

    // Tier 3: Invidious Instances (fallback with Proof-of-Origin token)
    try {
      final invidiousResult = await _fetchInvidious(videoId);
      if (invidiousResult != null && invidiousResult.playable) {
        return invidiousResult;
      }
    } catch (e) {
      if (e is SocketException) {
        return StreamProvider(playable: false, statusMSG: "networkError");
      }
    }

    // Tier 4: ANDROID SDK-less client (InnerTube fallback)
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

    // Tier 3: IOS mobile client (InnerTube fallback)
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

    // Tier 4: YoutubeExplode fallback
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
                    duration: 0,
                    loudnessDb: 0.0,
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
        lastReason = e.message;
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
