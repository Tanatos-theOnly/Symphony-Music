import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/app_update_info.dart';
import '../../services/update_service.dart';
import 'common_dialog_widget.dart';

/// Interactive dialog displayed when a new release is detected
class UpdateAvailableDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final String currentVersion;

  const UpdateAvailableDialog({
    super.key,
    required this.updateInfo,
    required this.currentVersion,
  });

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  bool _dontShowAgain = false;

  void _startInAppDownload(BuildContext context) {
    Navigator.of(context).pop(); // Close available dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpdateDownloadingDialog(updateInfo: widget.updateInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CommonDialog(
      maxWidth: 420,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "newVersionAvailable".tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Symphony Music",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Version info banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "v${widget.currentVersion}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.0),
                        child: Icon(Icons.arrow_forward_rounded, size: 14),
                      ),
                      Text(
                        "v${widget.updateInfo.version}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (widget.updateInfo.formattedSize.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.updateInfo.formattedSize,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Release notes (if present)
            if (widget.updateInfo.body.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                "Changelog",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    widget.updateInfo.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Don't show again checkbox
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _dontShowAgain,
                    onChanged: (val) {
                      setState(() {
                        _dontShowAgain = val ?? false;
                      });
                      if (_dontShowAgain) {
                        UpdateService.ignoreVersion(widget.updateInfo.tagName);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _dontShowAgain = !_dontShowAgain;
                      });
                      if (_dontShowAgain) {
                        UpdateService.ignoreVersion(widget.updateInfo.tagName);
                      }
                    },
                    child: Text(
                      "dontShowInfoAgain".tr,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Primary Download Button
            ElevatedButton.icon(
              onPressed: () => _startInAppDownload(context),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text(
                "Update Now",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
            ),

            const SizedBox(height: 8),

            // Secondary Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      UpdateService.openReleasePage(widget.updateInfo.htmlUrl);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      "Browser Link",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      "Later",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Downloading Progress Dialog
class UpdateDownloadingDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;

  const UpdateDownloadingDialog({
    super.key,
    required this.updateInfo,
  });

  @override
  State<UpdateDownloadingDialog> createState() => _UpdateDownloadingDialogState();
}

class _UpdateDownloadingDialogState extends State<UpdateDownloadingDialog> {
  final CancelToken _cancelToken = CancelToken();
  double _progress = 0.0;
  String _progressText = "Preparing download...";
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await UpdateService.downloadAndInstall(
        info: widget.updateInfo,
        cancelToken: _cancelToken,
        onProgress: (progress, progressText) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _progressText = progressText;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isComplete = true;
          _progressText = "Starting installer...";
        });
        // Auto-close dialog after 1.5 seconds if installer opens
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (_cancelToken.isCancelled) return;

      if (mounted) {
        Navigator.of(context).pop(); // Close downloading dialog

        // Show friendly failure recovery dialog
        showDialog(
          context: context,
          builder: (ctx) => UpdateFailedDialog(
            updateInfo: widget.updateInfo,
            errorMessage: e.toString().replaceAll("Exception: ", ""),
            onRetry: () {
              Navigator.of(ctx).pop();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => UpdateDownloadingDialog(updateInfo: widget.updateInfo),
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: CommonDialog(
        maxWidth: 360,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isComplete ? Icons.check_circle_rounded : Icons.downloading_rounded,
                  color: _isComplete ? Colors.green : theme.colorScheme.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isComplete ? "Download Complete" : "Downloading Update",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _progressText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isComplete)
                TextButton(
                  onPressed: () {
                    _cancelToken.cancel("User cancelled download");
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "cancel".tr,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Failure recovery dialog with Retry & Browser fallback
class UpdateFailedDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;
  final String errorMessage;
  final VoidCallback onRetry;

  const UpdateFailedDialog({
    super.key,
    required this.updateInfo,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CommonDialog(
      maxWidth: 380,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Update Failed",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : "An unexpected network error occurred while downloading the update.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 22),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Retry Download"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Browser Fallback Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  UpdateService.openReleasePage(updateInfo.htmlUrl);
                },
                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                label: const Text("Download via Browser"),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
            const SizedBox(height: 6),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "close".tr,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
