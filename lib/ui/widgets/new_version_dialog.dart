export 'update_dialogs.dart';

import 'package:flutter/material.dart';
import '../../models/app_update_info.dart';
import '../../services/update_service.dart';
import 'update_dialogs.dart';

/// Legacy compatibility wrapper for NewVersionDialog
class NewVersionDialog extends StatelessWidget {
  final AppUpdateInfo? updateInfo;
  final String? currentVersion;

  const NewVersionDialog({
    super.key,
    this.updateInfo,
    this.currentVersion,
  });

  @override
  Widget build(BuildContext context) {
    if (updateInfo != null) {
      return UpdateAvailableDialog(
        updateInfo: updateInfo!,
        currentVersion: currentVersion ?? "1.12.2",
      );
    }

    // Fallback if instantiated without updateInfo
    return FutureBuilder<UpdateCheckResult>(
      future: UpdateService.checkForUpdates(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.updateInfo != null) {
          return UpdateAvailableDialog(
            updateInfo: snapshot.data!.updateInfo!,
            currentVersion: snapshot.data!.currentVersion,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
