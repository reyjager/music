import 'dart:async';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:record/record.dart';
import '../utils/pitch_converter.dart';

class AudioService {
  final _pitchController = StreamController<int>.broadcast();
  Stream<int> get pitchStream => _pitchController.stream;

  final _recorder = AudioRecorder();
  final _detector = PitchDetector();

  bool _isListening = false;
  bool get isListening => _isListening;

  static const int stabilityWindowMs = 800;
  static const int minStableDurationMs = 200;

  final List<_PitchSample> _pitchBuffer = [];
  Timer? _validationTimer;

  Future<void> startListening() async {
    if (_isListening) return;

    print('AudioService: Starting to listen...');

    final stream = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 44100,
      numChannels: 1,
    ));

    print('AudioService: Stream started');
    _isListening = true;
    _pitchBuffer.clear();
    startValidationTimer();

    stream.listen((data) async {
      print('AudioService: Received audio data, length: ${data.length}');
      final result = await _detector.getPitchFromIntBuffer(data);
      print(
          'AudioService: Pitch detection - pitched: ${result.pitched}, pitch: ${result.pitch}');
      if (result.pitched) {
        processPitchSample(result.pitch);
      }
    });
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _recorder.stop();
    _isListening = false;
    _validationTimer?.cancel();
    _pitchBuffer.clear();
  }

  void processPitchSample(double frequency) {
    print('AudioService: Processing frequency: $frequency Hz');
    final midi = PitchConverter.frequencyToMidi(frequency);
    print('AudioService: Converted to MIDI: $midi');
    if (midi < 0) return;

    _pitchBuffer.add(_PitchSample(midi: midi, timestamp: DateTime.now()));

    final cutoff = DateTime.now()
        .subtract(const Duration(milliseconds: stabilityWindowMs));
    _pitchBuffer.removeWhere((s) => s.timestamp.isBefore(cutoff));
  }

  void startValidationTimer() {
    _validationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final detectedNote = _getStableNote();
      if (detectedNote != null) {
        _pitchController.add(detectedNote);
      }
    });
  }

  int? _getStableNote() {
    if (_pitchBuffer.length < 5) return null;

    final noteCounts = <int, int>{};
    for (final sample in _pitchBuffer) {
      noteCounts[sample.midi] = (noteCounts[sample.midi] ?? 0) + 1;
    }

    final mostCommon =
        noteCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    final stableSamples =
        _pitchBuffer.where((s) => s.midi == mostCommon.key).toList();
    if (stableSamples.isEmpty) return null;

    final duration =
        stableSamples.last.timestamp.difference(stableSamples.first.timestamp);
    if (duration.inMilliseconds >= minStableDurationMs) {
      print('AudioService: Stable note detected - MIDI: ${mostCommon.key}');
      return mostCommon.key;
    }
    return null;
  }

  void dispose() {
    stopListening();
    _pitchController.close();
    _validationTimer?.cancel();
  }
}

class _PitchSample {
  final int midi;
  final DateTime timestamp;

  _PitchSample({required this.midi, required this.timestamp});
}
