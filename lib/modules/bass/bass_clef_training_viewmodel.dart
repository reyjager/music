import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';
import '../../models/musical_note.dart';
import '../../models/session_stats.dart';
import '../../services/audio_service.dart';
import '../../services/note_generator_service.dart';
import '../../utils/pitch_converter.dart';

enum BassInputMode { microphone, buttons }

class BassClefTrainingViewmodel extends BaseViewModel {
  final AudioService _audioService;
  final NoteGeneratorService _noteGenerator;

  BassClefTrainingViewmodel({
    required AudioService audioService,
    required NoteGeneratorService noteGenerator,
  })  : _audioService = audioService,
        _noteGenerator = noteGenerator;

  BassInputMode _inputMode = BassInputMode.buttons;
  BassInputMode get inputMode => _inputMode;

  void toggleInputMode(BassInputMode mode) {
    _inputMode = mode;
    if (mode == BassInputMode.microphone) {
      _startListening();
    } else {
      _pitchSubscription?.cancel();
      _audioService.stopListening();
    }
    notifyListeners();
  }

  MusicalNote? _currentNote;
  MusicalNote? get currentNote => _currentNote;

  final SessionStats _statsBar = SessionStats();
  SessionStats get statsBar => _statsBar;

  bool showFeedback = false;
  bool isCorrect = false;
  String? correctAnswer;
  String? lastPressed;

  bool showFeedbackEnabled = true;
  void toggleShowFeedback() {
    showFeedbackEnabled = !showFeedbackEnabled;
    notifyListeners();
  }

  List<Map<String, dynamic>> attempts = [];

  Color get noteColor {
    if (!showFeedback) return Colors.black;
    return isCorrect ? Colors.green : Colors.red;
  }

  int? _lastDetectedMidi;
  int? get lastDetectedMidi => _lastDetectedMidi;

  String? get lastDetectedNoteName => _lastDetectedMidi != null
      ? PitchConverter.midiToNoteName(_lastDetectedMidi!)
      : null;

  DateTime? _noteDisplayTime;
  StreamSubscription? _pitchSubscription;
  Timer? _soundStopTimer;

  bool get isListening => _audioService.isListening ?? false;

  void initialize() {
    _generateNewNote();
    if (_inputMode == BassInputMode.microphone) {
      _startListening();
    }
    SoundGenerator.init(44100);
    SoundGenerator.setWaveType(waveTypes.SINUSOIDAL);
  }

  void _generateNewNote() {
    _currentNote = _noteGenerator.generateRandomNote();
    _noteDisplayTime = DateTime.now();
    notifyListeners();
  }

  Future<void> _startListening() async {
    await _audioService.startListening();

    _pitchSubscription = _audioService.pitchStream.listen((detectedMidi) {
      _lastDetectedMidi = detectedMidi;
      notifyListeners();
      _validateNote(detectedMidi);
    });

    notifyListeners();
  }

  void _validateNote(int detectedMidi) {
    if (_currentNote == null || showFeedback) return;

    final expected = _currentNote!.midiNumber;
    final reactionTime =
        DateTime.now().difference(_noteDisplayTime!).inMilliseconds;

    if (PitchConverter.notesMatch(detectedMidi, expected)) {
      _handleCorrect(reactionTime);
    } else {
      _handleIncorrect(expected, reactionTime);
    }
  }

  void manualNotePress(String noteLetter) {
    _playNoteSound(noteLetter);

    if (_currentNote == null || showFeedback) return;

    lastPressed = noteLetter;
    final expectedBase =
        _currentNote!.noteName.replaceAll(RegExp(r'[0-9]'), '');

    final reactionTime =
        DateTime.now().difference(_noteDisplayTime!).inMilliseconds;

    if (notesMatchByName(noteLetter, expectedBase)) {
      _handleCorrect(reactionTime);
    } else {
      _handleIncorrect(_currentNote!.midiNumber, reactionTime);
    }
  }

  bool notesMatchByName(String pressed, String expected) {
    if (pressed == expected) return true;
    const noteToSemitone = {
      'C': 0, 'B#': 0,
      'C#': 1, 'Db': 1,
      'D': 2,
      'D#': 3, 'Eb': 3,
      'E': 4, 'Fb': 4,
      'F': 5, 'E#': 5,
      'F#': 6, 'Gb': 6,
      'G': 7,
      'G#': 8, 'Ab': 8,
      'A': 9,
      'A#': 10, 'Bb': 10,
      'B': 11, 'Cb': 11,
    };
    return noteToSemitone[pressed] == noteToSemitone[expected];
  }

  String _enharmonicLabel(String? noteName) {
    if (noteName == null) return '';
    final base = noteName.replaceAll(RegExp(r'[0-9]'), '');
    const enharmonics = {
      'C#': 'C#/Db', 'Db': 'C#/Db',
      'D#': 'D#/Eb', 'Eb': 'D#/Eb',
      'F#': 'F#/Gb', 'Gb': 'F#/Gb',
      'G#': 'G#/Ab', 'Ab': 'G#/Ab',
      'A#': 'A#/Bb', 'Bb': 'A#/Bb',
    };
    return enharmonics[base] ?? base;
  }

  static const Map<String, int> _noteToMidiMap = {
    'C': 48, 'C#': 49, 'D': 50, 'D#': 51, 'E': 52,
    'F': 53, 'F#': 54, 'G': 55, 'G#': 56, 'A': 57, 'A#': 58, 'B': 59,
  };

  void _playNoteSound(String noteLetter) {
    _soundStopTimer?.cancel();
    SoundGenerator.stop();

    final midi = _noteToMidiMap[noteLetter];
    if (midi == null) return;

    final frequency = 440 * pow(2, (midi - 69) / 12).toDouble();
    SoundGenerator.setFrequency(frequency);
    SoundGenerator.play();

    _soundStopTimer = Timer(const Duration(milliseconds: 300), () {
      SoundGenerator.stop();
    });
  }

  void _handleCorrect(int reactionTime) {
    _statsBar.recordCorrect(reactionTime);
    isCorrect = true;
    correctAnswer = _enharmonicLabel(_currentNote?.noteName);
    attempts.add({
      'pressed': lastPressed,
      'expected': _enharmonicLabel(_currentNote?.noteName),
      'correct': true
    });
    _showFeedbackAnimation();
  }

  void _handleIncorrect(int expectedMidi, int reactionTime) {
    _statsBar.recordIncorrect(expectedMidi, reactionTime);
    isCorrect = false;
    correctAnswer = _enharmonicLabel(_currentNote?.noteName);
    attempts.add({
      'pressed': lastPressed,
      'expected': _enharmonicLabel(_currentNote?.noteName),
      'correct': false
    });
    notifyListeners();
    _showFeedbackAnimation();
  }

  void _showFeedbackAnimation() {
    showFeedback = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      showFeedback = false;
      _generateNewNote();
    });
  }

  void resetSession() {
    _statsBar.reset();
    attempts.clear();
    _generateNewNote();
    notifyListeners();
  }

  @override
  void dispose() {
    _pitchSubscription?.cancel();
    _audioService.stopListening();
    _soundStopTimer?.cancel();
    SoundGenerator.release();
    super.dispose();
  }
}
