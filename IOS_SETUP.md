# iOS Native Integration (AudioKit)

## Setup

### 1. Add AudioKit to `ios/Podfile`:

```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  pod 'AudioKit', '~> 5.6'
end
```

### 2. Add microphone permission to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to detect piano notes</string>
```

### 3. Create `ios/Runner/AudioHandler.swift`:

```swift
import Foundation
import AudioKit
import AVFoundation

class AudioHandler: NSObject {
    private var mic: AKMicrophone?
    private var tracker: AKFrequencyTracker?
    private var silence: AKBooster?
    private var channel: FlutterMethodChannel?
    
    func setMethodChannel(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    func startListening() {
        do {
            AKSettings.audioInputEnabled = true
            mic = AKMicrophone()
            
            tracker = AKFrequencyTracker(mic!)
            silence = AKBooster(tracker!, gain: 0)
            
            AudioKit.output = silence
            try AudioKit.start()
            
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self = self, let tracker = self.tracker else { return }
                
                let frequency = tracker.frequency
                let amplitude = tracker.amplitude
                
                if frequency > 0 && amplitude > 0.1 {
                    self.channel?.invokeMethod("onPitchDetected", arguments: [
                        "frequency": frequency,
                        "amplitude": amplitude
                    ])
                }
            }
        } catch {
            print("AudioKit failed to start: \(error)")
        }
    }
    
    func stopListening() {
        do {
            try AudioKit.stop()
            mic = nil
            tracker = nil
            silence = nil
        } catch {
            print("AudioKit failed to stop: \(error)")
        }
    }
}
```

### 4. Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let audioHandler = AudioHandler()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.example.music_reading/audio",
            binaryMessenger: controller.binaryMessenger
        )
        
        audioHandler.setMethodChannel(channel)
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "startListening":
                self.audioHandler.startListening()
                result(nil)
            case "stopListening":
                self.audioHandler.stopListening()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### 5. Run pod install:

```bash
cd ios
pod install
```
