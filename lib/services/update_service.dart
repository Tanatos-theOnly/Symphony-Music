import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_update_info.dart';
import '../utils/helper.dart';

class UpdateCheckResult {
  final bool isUpdateAvailable;
  final AppUpdateInfo? updateInfo;
  final String currentVersion;
  final String? errorMessage;
  final bool isError;

  UpdateCheckResult({
    required this.isUpdateAvailable,
    this.updateInfo,
    required this.currentVersion,
    this.errorMessage,
    this.isError = false,
  });
}

class UpdateService {
  static const String repoOwner = "Tanatos-theOnly";
  static const String repoName = "Symphony-Music";
  static const String githubApiUrl =
      "https://api.github.com/repos/$repoOwner/$repoName/releases/latest";
  static const String fallbackReleaseUrl =
      "https://github.com/$repoOwner/$repoName/releases";

  static const MethodChannel _installerChannel =
      MethodChannel("com.rohannet.symphonymusic/installer");

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'Symphony-Music-App',
      },
    ),
  );

  /// Get current app version from PackageInfo
  static Future<String> getCurrentAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version.isNotEmpty ? info.version : "1.12.5";
    } catch (_) {
      return "1.12.5";
    }
  }

  /// Check whether a new update is available on GitHub
  static Future<UpdateCheckResult> checkForUpdates({
    bool ignoreSuppressed = false,
  }) async {
    final currentVersion = await getCurrentAppVersion();

    try {
      final response = await _dio.get(githubApiUrl);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final updateInfo = AppUpdateInfo.fromGitHubJson(response.data);

        // Check if user chose to ignore this specific release
        if (!ignoreSuppressed) {
          final box = Hive.box("AppPrefs");
          final ignoredVersion = box.get("ignoredUpdateVersion");
          if (ignoredVersion == updateInfo.tagName ||
              ignoredVersion == updateInfo.version) {
            return UpdateCheckResult(
              isUpdateAvailable: false,
              updateInfo: updateInfo,
              currentVersion: currentVersion,
            );
          }
        }

        final isNewer = isVersionGreater(updateInfo.version, currentVersion);
        return UpdateCheckResult(
          isUpdateAvailable: isNewer,
          updateInfo: updateInfo,
          currentVersion: currentVersion,
        );
      } else {
        return UpdateCheckResult(
          isUpdateAvailable: false,
          currentVersion: currentVersion,
          isError: true,
          errorMessage: "Unexpected server response (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
      printWarning("Update check DioException: ${e.message}");
      String message = "Could not check for updates.";
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        message = "Network timeout. Please check your internet connection.";
      } else if (e.response?.statusCode == 404) {
        message = "No releases published yet on repository.";
      } else if (e.response?.statusCode == 403) {
        message = "GitHub API rate limit exceeded. Please try again later.";
      }
      return UpdateCheckResult(
        isUpdateAvailable: false,
        currentVersion: currentVersion,
        isError: true,
        errorMessage: message,
      );
    } catch (e) {
      printERROR("Update check error: $e");
      return UpdateCheckResult(
        isUpdateAvailable: false,
        currentVersion: currentVersion,
        isError: true,
        errorMessage: "Error checking for updates: $e",
      );
    }
  }

  /// Compares two semver strings (returns true if newVersion > currentVersion)
  static bool isVersionGreater(String newVersion, String currentVersion) {
    try {
      final v1 = newVersion.replaceAll(RegExp(r'^[vV]'), '').trim();
      final v2 = currentVersion.replaceAll(RegExp(r'^[vV]'), '').trim();

      final v1Clean = v1.split(RegExp(r'[\+\-]'))[0];
      final v2Clean = v2.split(RegExp(r'[\+\-]'))[0];

      final v1Parts =
          v1Clean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2Parts =
          v2Clean.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLength =
          v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
      for (int i = 0; i < maxLength; i++) {
        final p1 = i < v1Parts.length ? v1Parts[i] : 0;
        final p2 = i < v2Parts.length ? v2Parts[i] : 0;
        if (p1 > p2) return true;
        if (p1 < p2) return false;
      }
      return false;
    } catch (_) {
      return newVersion != currentVersion;
    }
  }

  /// Download the APK and initiate installation
  static Future<void> downloadAndInstall({
    required AppUpdateInfo info,
    required void Function(double progress, String progressText) onProgress,
    CancelToken? cancelToken,
  }) async {
    final downloadUrl = info.apkDownloadUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      throw Exception(
        "No APK asset was attached to this release. Please download from the browser.",
      );
    }

    final tempDir = await getTemporaryDirectory();
    final apkFile = File("${tempDir.path}/SymphonyMusic-update.apk");

    // Remove any previously cached incomplete APK
    if (await apkFile.exists()) {
      try {
        await apkFile.delete();
      } catch (_) {}
    }

    // Stream download with live progress
    final downloadDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );

    await downloadDio.download(
      downloadUrl,
      apkFile.path,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          final progress = received / total;
          final receivedMb = (received / (1024 * 1024)).toStringAsFixed(1);
          final totalMb = (total / (1024 * 1024)).toStringAsFixed(1);
          final percent = (progress * 100).toInt();
          onProgress(progress, "$percent% ($receivedMb MB / $totalMb MB)");
        } else {
          final receivedMb = (received / (1024 * 1024)).toStringAsFixed(1);
          onProgress(0.0, "$receivedMb MB downloaded");
        }
      },
    );

    if (!await apkFile.exists()) {
      throw Exception("Downloaded APK file not found on disk.");
    }

    // Trigger installation
    if (Platform.isAndroid) {
      try {
        await _installerChannel.invokeMethod("installApk", {
          "filePath": apkFile.path,
        });
      } catch (e) {
        printERROR("Failed to launch package installer: $e");
        throw Exception("Could not start installer: $e");
      }
    } else {
      // Desktop fallback: Open downloaded file or launch URL
      await launchUrl(
        Uri.parse(info.htmlUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  /// Open release page in web browser
  static Future<void> openReleasePage([String? url]) async {
    final target = Uri.parse(url ?? fallbackReleaseUrl);
    try {
      final launched = await launchUrl(
        target,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(target, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(target, mode: LaunchMode.platformDefault);
      } catch (e) {
        printERROR("Could not open browser URL: $e");
      }
    }
  }

  /// Mark a version as ignored by the user
  static void ignoreVersion(String versionTag) {
    Hive.box("AppPrefs").put("ignoredUpdateVersion", versionTag);
  }
}
