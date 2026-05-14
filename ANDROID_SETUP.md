# Android Native Integration (TarsosDSP)

## Setup

### 1. Add TarsosDSP dependency to `android/app/build.gradle`:

```gradle
dependencies {
    implementation 'be.tarsos.dsp:core:2.5'
    implementation 'be.tarsos.dsp:jvm:2.5'
}
```

### 2. Add microphone permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### 3. Create `android/app/src/main/kotlin/com/example/music_reading_trainir/AudioHandler.kt`:

```kotlin
package com.example.music_reading_trainir

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import be.tarsos.dsp.AudioDispatcher
import be.tarsos.dsp.AudioEvent
import be.tarsos.dsp.AudioProcessor
import be.tarsos.dsp.io.android.AudioDispatcherFactory
import be.tarsos.dsp.pitch.PitchDetectionHandler
import be.tarsos.dsp.pitch.PitchDetectionResult
import be.tarsos.dsp.pitch.PitchProcessor
import io.flutter.plugin.common.MethodChannel

class AudioHandler(private val activity: MainActivity) {
    private var dispatcher: AudioDispatcher? = null
    private var channel: MethodChannel? = null

    fun setMethodChannel(channel: MethodChannel) {
        this.channel = channel
    }

    fun startListening() {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.RECORD_AUDIO), 1)
            return
        }

        dispatcher = AudioDispatcherFactory.fromDefaultMicrophone(22050, 1024, 0)
        
        val pitchDetectionHandler = PitchDetectionHandler { result, _ ->
            val frequency = result.pitch.toDouble()
            val amplitude = result.probability.toDouble()
            
            if (frequency > 0) {
                activity.runOnUiThread {
                    channel?.invokeMethod("onPitchDetected", mapOf(
                        "frequency" to frequency,
                        "amplitude" to amplitude
                    ))
                }
            }
        }

        val pitchProcessor = PitchProcessor(
            PitchProcessor.PitchEstimationAlgorithm.YIN,
            22050f,
            1024,
            pitchDetectionHandler
        )

        dispatcher?.addAudioProcessor(pitchProcessor)
        Thread { dispatcher?.run() }.start()
    }

    fun stopListening() {
        dispatcher?.stop()
        dispatcher = null
    }
}
```

### 4. Update `android/app/src/main/kotlin/com/example/music_reading_trainir/MainActivity.kt`:

```kotlin
package com.example.music_reading_trainir

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.music_reading/audio"
    private lateinit var audioHandler: AudioHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioHandler = AudioHandler(this)
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        audioHandler.setMethodChannel(channel)
        
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    audioHandler.startListening()
                    result.success(null)
                }
                "stopListening" -> {
                    audioHandler.stopListening()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
```
