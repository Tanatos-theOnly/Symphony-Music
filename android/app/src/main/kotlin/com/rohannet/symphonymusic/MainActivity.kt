package com.rohannet.symphonymusic

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val INSTALLER_CHANNEL = "com.rohannet.symphonymusic/installer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INSTALLER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("filePath")
                if (filePath.isNullOrEmpty()) {
                    result.error("INVALID_PATH", "File path is empty", null)
                    return@setMethodCallHandler
                }

                val file = File(filePath)
                if (!file.exists()) {
                    result.error("FILE_NOT_FOUND", "APK file does not exist at $filePath", null)
                    return@setMethodCallHandler
                }

                try {
                    val contentUri = FileProvider.getUriForFile(
                        this,
                        "${applicationContext.packageName}.fileProvider",
                        file
                    )

                    // On Android 8.0+, check if unknown app installs are permitted
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        if (!packageManager.canRequestPackageInstalls()) {
                            val settingsIntent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(settingsIntent)
                        }
                    }

                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(contentUri, "application/vnd.android.package-archive")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("INSTALL_ERROR", e.localizedMessage, e.stackTraceToString())
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
