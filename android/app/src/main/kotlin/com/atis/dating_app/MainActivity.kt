package com.atis.dating_app

import android.content.Context
import android.media.AudioManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.atis.dating_app/audio_mute"
    private var originalVolume: Int = -1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

            when (call.method) {
                "muteMediaStream" -> {
                    try {
                        // Original volume save karo taaki baad me exact restore ho sake
                        originalVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                        Log.d("AudioMute", "Original volume: $originalVolume")

                        // Direct volume 0 set karo — ye deprecated setStreamMute se zyada reliable hai
                        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)

                        Log.d("AudioMute", "Muted successfully. New volume: ${audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)}")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("AudioMute", "Mute failed: ${e.message}")
                        result.error("MUTE_FAILED", e.message, null)
                    }
                }
                "unmuteMediaStream" -> {
                    try {
                        if (originalVolume >= 0) {
                            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, originalVolume, 0)
                            Log.d("AudioMute", "Restored volume: $originalVolume")
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("AudioMute", "Unmute failed: ${e.message}")
                        result.error("UNMUTE_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}