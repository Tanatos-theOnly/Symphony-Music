class AppUpdateInfo {
  final String tagName;
  final String version;
  final String title;
  final String body;
  final String htmlUrl;
  final String? apkDownloadUrl;
  final int? apkSize;
  final DateTime? publishedAt;

  AppUpdateInfo({
    required this.tagName,
    required this.version,
    required this.title,
    required this.body,
    required this.htmlUrl,
    this.apkDownloadUrl,
    this.apkSize,
    this.publishedAt,
  });

  String get formattedSize {
    if (apkSize == null || apkSize == 0) return "";
    final mb = apkSize! / (1024 * 1024);
    return "${mb.toStringAsFixed(1)} MB";
  }

  factory AppUpdateInfo.fromGitHubJson(Map<String, dynamic> json) {
    final rawTag = (json['tag_name'] as String? ?? '').trim();
    // Normalize version: remove leading 'v' or 'V'
    final cleanVersion = rawTag.startsWith(RegExp(r'^[vV]'))
        ? rawTag.substring(1).trim()
        : rawTag;

    final name = (json['name'] as String? ?? '').trim();
    final body = (json['body'] as String? ?? '').trim();
    final htmlUrl = (json['html_url'] as String? ?? '').trim();
    final publishedStr = json['published_at'] as String?;
    final publishedAt = publishedStr != null ? DateTime.tryParse(publishedStr) : null;

    String? apkUrl;
    int? apkBytes;

    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      if (asset is Map<String, dynamic>) {
        final assetName = (asset['name'] as String? ?? '').toLowerCase();
        if (assetName.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          apkBytes = asset['size'] as int?;
          break;
        }
      }
    }

    return AppUpdateInfo(
      tagName: rawTag,
      version: cleanVersion,
      title: name.isNotEmpty ? name : rawTag,
      body: body,
      htmlUrl: htmlUrl.isNotEmpty
          ? htmlUrl
          : "https://github.com/Tanatos-theOnly/Symphony-Music/releases/latest",
      apkDownloadUrl: apkUrl,
      apkSize: apkBytes,
      publishedAt: publishedAt,
    );
  }
}
