package com.chimbo.chimbo

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingReceiptBytes: ByteArray? = null
    private var pendingReceiptFileName: String? = null
    private var pendingSaveResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOADS_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "savePdf") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val fileName = call.argument<String>("fileName")
                val bytes = call.argument<ByteArray>("bytes")
                if (fileName == null || bytes == null) {
                    result.error("INVALID_RECEIPT", "Receipt data is missing.", null)
                    return@setMethodCallHandler
                }

                if (pendingSaveResult != null) {
                    result.error("SAVE_IN_PROGRESS", "A receipt save is already open.", null)
                    return@setMethodCallHandler
                }

                pendingReceiptBytes = bytes
                pendingReceiptFileName = fileName
                pendingSaveResult = result
                requestNotificationPermissionOrChooseLocation()
            }
    }

    private fun requestNotificationPermissionOrChooseLocation() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                NOTIFICATION_PERMISSION_REQUEST,
            )
            return
        }

        openReceiptSavePicker()
    }

    private fun openReceiptSavePicker() {
        val fileName = pendingReceiptFileName ?: return
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = PDF_TYPE
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        startActivityForResult(intent, SAVE_RECEIPT_REQUEST)
    }

    @Deprecated("Deprecated in Android, but required for the notification permission result.")
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST) {
            openReceiptSavePicker()
        }
    }

    @Deprecated("Deprecated in Android, but required for the document picker result.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != SAVE_RECEIPT_REQUEST) return

        val result = pendingSaveResult ?: return
        val bytes = pendingReceiptBytes
        val fileName = pendingReceiptFileName
        pendingSaveResult = null
        pendingReceiptBytes = null
        pendingReceiptFileName = null

        val destination = data?.data
        if (resultCode != RESULT_OK || destination == null) {
            result.success(false)
            return
        }

        try {
            contentResolver.openOutputStream(destination)?.use { output ->
                output.write(bytes ?: error("Receipt data is missing."))
            } ?: error("Could not write receipt file.")
            if (fileName != null) showReceiptSavedNotification(destination, fileName)
            result.success(true)
        } catch (exception: Exception) {
            result.error("SAVE_FAILED", "Could not save the receipt.", null)
        }
    }

    private fun showReceiptSavedNotification(uri: Uri, fileName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.createNotificationChannel(
                NotificationChannel(
                    RECEIPT_CHANNEL_ID,
                    RECEIPT_CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_DEFAULT,
                ).apply {
                    description = RECEIPT_CHANNEL_DESCRIPTION
                },
            )
        }

        val openReceiptIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, PDF_TYPE)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val pendingIntentFlags = PendingIntent.FLAG_UPDATE_CURRENT or
            (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE
            } else {
                0
            })
        val openReceipt = PendingIntent.getActivity(
            this,
            fileName.hashCode(),
            openReceiptIntent,
            pendingIntentFlags,
        )
        @Suppress("DEPRECATION")
        val notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, RECEIPT_CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }
        val notification = notificationBuilder
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentTitle(RECEIPT_NOTIFICATION_TITLE)
            .setContentText(RECEIPT_NOTIFICATION_TEXT)
            .setContentIntent(openReceipt)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(fileName.hashCode(), notification)
    }

    private companion object {
        const val DOWNLOADS_CHANNEL = "com.chimbo.chimbo/downloads"
        const val SAVE_RECEIPT_REQUEST = 4107
        const val NOTIFICATION_PERMISSION_REQUEST = 4108
        const val PDF_TYPE = "application/pdf"
        const val RECEIPT_CHANNEL_ID = "receipt_downloads"
        const val RECEIPT_CHANNEL_NAME = "Risiti zilizopakuliwa"
        const val RECEIPT_CHANNEL_DESCRIPTION = "Arifa za risiti zilizohifadhiwa."
        const val RECEIPT_NOTIFICATION_TITLE = "Risiti imehifadhiwa"
        const val RECEIPT_NOTIFICATION_TEXT = "Gusa ili kufungua risiti."
    }
}
