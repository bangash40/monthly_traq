package com.monthlytraq.app

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The app's own Haptic feedback switch decides whether to vibrate, so
        // this drives the vibration motor directly. Flutter's built-in
        // haptics go through the phone's system touch-feedback setting and
        // are silently skipped when that's off.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "monthlytraq/haptics")
            .setMethodCallHandler { call, result ->
                if (call.method == "vibrate") {
                    vibrate(call.argument<String>("kind") ?: "tap")
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun vibrate(kind: String) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        if (!vibrator.hasVibrator()) return

        // Short pulses, from a light tick to a firm thump. Long enough for
        // older vibration motors (they need ~20ms to spin up) to be felt.
        val (millis, amplitude) = when (kind) {
            "tick" -> 25L to 170
            "success" -> 55L to 255
            "delete" -> 80L to 255
            else -> 35L to 200 // "tap"
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val strength = if (vibrator.hasAmplitudeControl()) amplitude else VibrationEffect.DEFAULT_AMPLITUDE
            vibrator.vibrate(VibrationEffect.createOneShot(millis, strength))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(millis)
        }
    }
}
