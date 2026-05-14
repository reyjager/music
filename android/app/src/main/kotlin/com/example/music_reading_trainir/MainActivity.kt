package com.example.music_reading_trainir

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.music_reading/audio"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    // TODO: Implement TarsosDSP integration
                    result.success(null)
                }
                "stopListening" -> {
                    // TODO: Implement stop logic
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
