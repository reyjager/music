import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class MidiSoundService {
  static final MidiSoundService _instance = MidiSoundService._();
  factory MidiSoundService() => _instance;
  MidiSoundService._();

  final Map<int, AudioPlayer> _players = {};
  final Map<int, String> _cachedFiles = {};
  String? _tempDir;
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) return;
    _tempDir = (await getTemporaryDirectory()).path;
    _ready = true;
  }

  void playNote(int midiNumber, {double velocity = 0.8}) {
    if (!_ready) return;
    _playGenerated(midiNumber, velocity);
  }

  Future<void> _playGenerated(int midi, double velocity) async {
    _players[midi]?.stop();

    // Cache WAV file per note
    if (!_cachedFiles.containsKey(midi)) {
      final wavBytes = _generatePianoWav(midi, velocity);
      final filePath = '$_tempDir/note_$midi.wav';
      await File(filePath).writeAsBytes(wavBytes);
      _cachedFiles[midi] = filePath;
    }

    var player = _players[midi];
    if (player == null) {
      player = AudioPlayer();
      _players[midi] = player;
    }

    await player.setFilePath(_cachedFiles[midi]!);
    player.play();
  }

  Uint8List _generatePianoWav(int midi, double velocity) {
    const sampleRate = 44100;
    const durationSec = 1.0;
    final numSamples = (sampleRate * durationSec).toInt();

    final frequency = 440.0 * pow(2, (midi - 69) / 12.0);
    final samples = Float64List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = exp(-3.0 * t);
      final sample = velocity *
          envelope *
          (0.6 * sin(2 * pi * frequency * t) +
              0.25 * sin(2 * pi * frequency * 2 * t) +
              0.1 * sin(2 * pi * frequency * 3 * t) +
              0.05 * sin(2 * pi * frequency * 4 * t));
      samples[i] = sample.clamp(-1.0, 1.0);
    }

    return _encodeWav(samples, sampleRate);
  }

  Uint8List _encodeWav(Float64List samples, int sampleRate) {
    final numSamples = samples.length;
    const bitsPerSample = 16;
    const numChannels = 1;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = numSamples * blockAlign;
    final fileSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);
    var offset = 0;

    // RIFF header
    buffer.setUint8(offset++, 0x52); // R
    buffer.setUint8(offset++, 0x49); // I
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint8(offset++, 0x46); // F
    buffer.setUint32(offset, fileSize, Endian.little);
    offset += 4;
    buffer.setUint8(offset++, 0x57); // W
    buffer.setUint8(offset++, 0x41); // A
    buffer.setUint8(offset++, 0x56); // V
    buffer.setUint8(offset++, 0x45); // E

    // fmt chunk
    buffer.setUint8(offset++, 0x66); // f
    buffer.setUint8(offset++, 0x6D); // m
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x20); // space
    buffer.setUint32(offset, 16, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // PCM
    offset += 2;
    buffer.setUint16(offset, numChannels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;

    // data chunk
    buffer.setUint8(offset++, 0x64); // d
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint8(offset++, 0x74); // t
    buffer.setUint8(offset++, 0x61); // a
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // samples
    for (int i = 0; i < numSamples; i++) {
      final intSample = (samples[i] * 32767).toInt().clamp(-32768, 32767);
      buffer.setInt16(offset, intSample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}
