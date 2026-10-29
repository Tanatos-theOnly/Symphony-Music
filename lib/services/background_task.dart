import 'dart:core';
import 'package:flutter/services.dart';
import 'package:symphonymusic/services/stream_service.dart';

Future<Map<String, dynamic>> getStreamInfo(String songId, dynamic token,
    [String? visitorData]) async {
  if (songId.substring(0, 4) == "MPED") {
    songId = songId.substring(4);
  }
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final playerResponse =
      await StreamProvider.fetch(songId, visitorData: visitorData);
  return playerResponse.hmStreamingData;
}
