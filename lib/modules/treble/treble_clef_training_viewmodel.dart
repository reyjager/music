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

enum InputMode { microphone, buttons }

class TrebleClefTrainingViewModel extends BaseViewModel {
  final AudioService audioService;
  final NoteGeneratorService noteGenerator;

  TrebleClefTrainingViewModel({
    required this.audioService,
    required this.noteGenerator,
  });

  InputMode _inputMode = InputMode.buttons;
  InputMode get inputMode => _inputMode;

  void toggleInputMode(InputMode mode) {
    _inputMode = mode;
    if (mode == InputMode.microphone) {
      startListening();
    } else {
      pitchSubscription?.cancel();
      audioService.stopListening();
    }
    notifyListeners();
  }

  MusicalNote? currentNote;

  final SessionStats _stats = SessionStats();
  SessionStats get stats => _stats;

  bool showFeedback = false;
  bool isCorrect = false;
  String? correctAnswer;
  String? lastPressed;

  bool showFeedbackEnabled = true;
  void toggleShowFeedback() {
    showFeedbackEnabled = !showFeedbackEnabled;
    notifyListeners();
  }

  /// Stores all attempts: {pressed, expected, correct}
  List<Map<String, dynamic>> attempts = [];

  Color get noteColor {
    if (!showFeedback) return Colors.black;
    return isCorrect ? Colors.green : Colors.red;
  }

  int? lastDetectedMidi;

  String? get lastDetectedNoteName => lastDetectedMidi != null
      ? PitchConverter.midiToNoteName(lastDetectedMidi!)
      : null;

  DateTime? noteDisplayTime;
  StreamSubscription? pitchSubscription;
  Timer? soundStopTimer;

  bool get isListening => audioService.isListening;

  void initialize() {
    generateNewNote();
    if (_inputMode == InputMode.microphone) {
      startListening();
    }
    SoundGenerator.init(44100);
    SoundGenerator.setWaveType(waveTypes.SINUSOIDAL);
  }

  void generateNewNote() {
    currentNote = noteGenerator.generateRandomNote();
    noteDisplayTime = DateTime.now();
    notifyListeners();
  }

  Future<void> startListening() async {
    await audioService.startListening();

    pitchSubscription = audioService.pitchStream.listen((detectedMidi) {
      lastDetectedMidi = detectedMidi;
      notifyListeners();
      validateNote(detectedMidi);
    });

    notifyListeners();
  }

  void validateNote(int detectedMidi) {
    if (currentNote == null || showFeedback) return;

    final expected = currentNote!.midiNumber;
    final reactionTime =
        DateTime.now().difference(noteDisplayTime!).inMilliseconds;

    if (PitchConverter.notesMatch(detectedMidi, expected)) {
      handleCorrect(reactionTime);
    } else {
      handleIncorrect(expected, reactionTime);
    }
  }

  void manualNotePress(String noteLetter) {
    playNoteSound(noteLetter);

    if (currentNote == null || showFeedback) return;

    lastPressed = noteLetter;
    final expectedName = currentNote!.noteName;
    // Compare note letter (strip octave number), handle enharmonic equivalents
    final pressedBase = noteLetter;
    final expectedBase = expectedName.replaceAll(RegExp(r'[0-9]'), '');

    print('Button pressed: $pressedBase | Expected: $expectedBase');

    final reactionTime =
        DateTime.now().difference(noteDisplayTime!).inMilliseconds;

    if (notesMatchByName(pressedBase, expectedBase)) {
      handleCorrect(reactionTime);
    } else {
      handleIncorrect(currentNote!.midiNumber, reactionTime);
    }
  }

  bool notesMatchByName(String pressed, String expected) {
    if (pressed == expected) return true;
    // Map every spelling to a pitch class (0-11)
    const noteToSemitone = {
      'C': 0,
      'B#': 0,
      'C#': 1,
      'Db': 1,
      'D': 2,
      'D#': 3,
      'Eb': 3,
      'E': 4,
      'Fb': 4,
      'F': 5,
      'E#': 5,
      'F#': 6,
      'Gb': 6,
      'G': 7,
      'G#': 8,
      'Ab': 8,
      'A': 9,
      'A#': 10,
      'Bb': 10,
      'B': 11,
      'Cb': 11,
    };
    return noteToSemitone[pressed] == noteToSemitone[expected];
  }

  static const Map<String, int> _noteToMidiMap = {
    'C': 60,
    'C#': 61,
    'D': 62,
    'D#': 63,
    'E': 64,
    'F': 65,
    'F#': 66,
    'G': 67,
    'G#': 68,
    'A': 69,
    'A#': 70,
    'B': 71,
  };

  void playNoteSound(String noteLetter) {
    soundStopTimer?.cancel();
    SoundGenerator.stop(); // Stop any currently playing sound

    final midi = _noteToMidiMap[noteLetter];
    if (midi == null) return;

    final frequency = 440 * pow(2, (midi - 69) / 12).toDouble();
    SoundGenerator.setFrequency(frequency);
    SoundGenerator.play();

    soundStopTimer = Timer(const Duration(milliseconds: 300), () {
      SoundGenerator.stop();
    });
  }

  void handleCorrect(int reactionTime) {
    _stats.recordCorrect(reactionTime);
    isCorrect = true;
    correctAnswer = _enharmonicLabel(currentNote?.noteName);
    attempts.add({
      'pressed': lastPressed,
      'expected': _enharmonicLabel(currentNote?.noteName),
      'correct': true
    });
    showFeedbackAnimation();
  }

  String _enharmonicLabel(String? noteName) {
    if (noteName == null) return '';
    final base = noteName.replaceAll(RegExp(r'[0-9]'), '');
    const enharmonics = {
      'C#': 'C#/Db',
      'Db': 'C#/Db',
      'D#': 'D#/Eb',
      'Eb': 'D#/Eb',
      'F#': 'F#/Gb',
      'Gb': 'F#/Gb',
      'G#': 'G#/Ab',
      'Ab': 'G#/Ab',
      'A#': 'A#/Bb',
      'Bb': 'A#/Bb',
    };
    return enharmonics[base] ?? base;
  }

  void handleIncorrect(int expectedMidi, int reactionTime) {
    _stats.recordIncorrect(expectedMidi, reactionTime);
    isCorrect = false;
    correctAnswer = _enharmonicLabel(currentNote?.noteName);
    attempts.add(
        {'pressed': lastPressed, 'expected': correctAnswer, 'correct': false});
    notifyListeners();
    showFeedbackAnimation();
  }

  void showFeedbackAnimation() {
    showFeedback = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      showFeedback = false;
      generateNewNote();
    });
  }

  void resetSession() {
    _stats.reset();
    attempts.clear();
    generateNewNote();
    notifyListeners();
  }

  @override
  void dispose() {
    pitchSubscription?.cancel();
    audioService.stopListening();
    soundStopTimer?.cancel();
    SoundGenerator.release();
    super.dispose();
  }
}
