package com.example.app_test

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.media.RingtoneManager
import android.database.Cursor
import android.view.WindowManager.LayoutParams
import android.os.PowerManager

class MainActivity: FlutterActivity() {
    private lateinit var powerManager: PowerManager
    private lateinit var wakeLock: PowerManager.WakeLock

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = "com.example.app_test/mychannel"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                if (call.method == "getAllRingtones") {
                    result.success(getAllRingtones(this))
                } else if (call.method == "keepAwake") {
                    keepAwake()
                    result.success(null)
                } else if (call.method == "removeAwake") {
                    removeAwake()
                    result.success(null)
                } else if (call.method == "setBrightness"){
                    val brightness = call.argument<Double>("brightness")
                    if (brightness != null) {
                        setBrightness(brightness.toFloat())
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Brightness value is null", null)
                    }
                } else if ( call.method == "getBrightness") {
                    result.success(getBrightness())
                } else {
                    result.notImplemented()
                }
        }
    }


    private fun getAllRingtones(context: Context): List<String> {

        val manager = RingtoneManager(context)
        manager.setType(RingtoneManager.TYPE_RINGTONE)

        val cursor: Cursor = manager.cursor

        val list: MutableList<String> = mutableListOf()
        while (cursor.moveToNext()) {
            val notificationTitle: String = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
            list.add(notificationTitle)
        }
        return list
    }

    private fun keepAwake() {
        window.addFlags(LayoutParams.FLAG_KEEP_SCREEN_ON)
        powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
            "YourApp::WakeLock"
        )
        wakeLock.acquire()
    }

    private fun removeAwake() {
        window.clearFlags(LayoutParams.FLAG_KEEP_SCREEN_ON)
        if (wakeLock.isHeld) {
            wakeLock.release()
        }
    }

    private fun setBrightness(brightness: Float) {
        val layoutParams = window.attributes
        layoutParams.screenBrightness = brightness
        window.attributes = layoutParams
    }

    private fun getBrightness(): Float {
        val layoutParams = window.attributes
        return layoutParams.screenBrightness
    }


}
