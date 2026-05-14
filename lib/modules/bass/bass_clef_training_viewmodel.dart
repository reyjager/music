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

class ScrollingNote {
  final MusicalNote note;
  double xFraction; // 1.0 = right edge, 0.0 = left edge
  bool answered;
  bool? correct;

  ScrollingNote({required this.note, this.xFraction = 1.0})
      : answered = false,
        correct = null;
}

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

  List<ScrollingNote> scrollingNotes = [];
  MusicalNote? get currentNote => _activeNote?.note;

  ScrollingNote? get _activeNote {
    for (final sn in scrollingNotes) {
      if (!sn.answered) return sn;
    }
    return null;
  }

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

  Color noteColorFor(ScrollingNote sn) {
    if (sn.correct == true) return Colors.green;
    if (sn.correct == false) return Colors.red;
    if (sn == _activeNote) return Colors.black;
    return Colors.black54;
  }

  int? _lastDetectedMidi;
  int? get lastDetectedMidi => _lastDetectedMidi;

  String? get lastDetectedNoteName => _lastDetectedMidi != null
      ? PitchConverter.midiToNoteName(_lastDetectedMidi!)
      : null;

  DateTime? _noteDisplayTime;
  StreamSubscription? _pitchSubscription;
  Timer? _soundStopTimer;

  bool get isListening => _audioService.isListening;

  // X fraction where note becomes "active" / hit zone
  static const double hitZone = 0.2;
  // X fraction where note is considered missed
  static const double _missZone = 0.05;
  // Spacing between notes (fraction)
  static const double _noteSpacing = 0.25;

  // Scroll speed: controllable via slider (0.001 = slow, 0.006 = fast)
  double _scrollSpeed = 0.003;
  double get scrollSpeed => _scrollSpeed;
  void setScrollSpeed(double value) {
    _scrollSpeed = value;
    notifyListeners();
  }

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  void togglePause() {
    _isRunning = !_isRunning;
    notifyListeners();
  }

  void initialize() {
    SoundGenerator.init(44100);
    SoundGenerator.setWaveType(waveTypes.SINUSOIDAL);
    _spawnInitialNotes();
    _isRunning = true;
    if (_inputMode == BassInputMode.microphone) {
      _startListening();
    }
    notifyListeners();
  }

  void _spawnInitialNotes() {
    scrollingNotes.clear();
    for (int i = 0; i < 5; i++) {
      scrollingNotes.add(ScrollingNote(
        note: _noteGenerator.generateRandomNote(),
        xFraction: 0.8 + (i * _noteSpacing),
      ));
    }
    _noteDisplayTime = DateTime.now();
  }

  /// Called every frame by the view's Ticker
  void tick() {
    if (!_isRunning) return;

    // Move all notes left
    for (final sn in scrollingNotes) {
      sn.xFraction -= _scrollSpeed;
    }

    // Check for missed notes
    for (final sn in scrollingNotes) {
      if (!sn.answered && sn.xFraction < _missZone) {
        sn.answered = true;
        sn.correct = false;
        _statsBar.recordIncorrect(sn.note.midiNumber, 0);
        attempts.add({
          'pressed': '—',
          'expected': _enharmonicLabel(sn.note.noteName),
          'correct': false,
        });
      }
    }

    // Remove notes that scrolled off screen
    scrollingNotes.removeWhere((sn) => sn.xFraction < -0.1);

    // Spawn new notes on the right
    if (scrollingNotes.isEmpty ||
        scrollingNotes.last.xFraction < 1.0 - _noteSpacing) {
      scrollingNotes.add(ScrollingNote(
        note: _noteGenerator.generateRandomNote(),
        xFraction: 1.0,
      ));
    }

    notifyListeners();
  }

  Future<void> _startListening() async {
    await _audioService.startListening();

    _pitchSubscription = _audioService.pitchStream.listen((detectedMidi) {
      _lastDetectedMidi = detectedMidi;
      notifyListeners();
      _validateMidi(detectedMidi);
    });

    notifyListeners();
  }

  void _validateMidi(int detectedMidi) {
    final active = _activeNote;
    if (active == null) return;

    final expected = active.note.midiNumber;
    final reactionTime =
        DateTime.now().difference(_noteDisplayTime!).inMilliseconds;

    if (PitchConverter.notesMatch(detectedMidi, expected)) {
      _markCorrect(active, reactionTime);
    } else {
      _markIncorrect(active, reactionTime);
    }
  }

  void manualNotePress(String noteLetter) {
    _playNoteSound(noteLetter);

    final active = _activeNote;
    if (active == null) return;

    lastPressed = noteLetter;
    final expectedBase = active.note.noteName.replaceAll(RegExp(r'[0-9]'), '');
    final reactionTime =
        DateTime.now().difference(_noteDisplayTime!).inMilliseconds;

    if (notesMatchByName(noteLetter, expectedBase)) {
      _markCorrect(active, reactionTime);
    } else {
      _markIncorrect(active, reactionTime);
    }
  }

  void _markCorrect(ScrollingNote sn, int reactionTime) {
    sn.answered = true;
    sn.correct = true;
    _statsBar.recordCorrect(reactionTime);
    isCorrect = true;
    correctAnswer = _enharmonicLabel(sn.note.noteName);
    attempts.add({
      'pressed': lastPressed,
      'expected': _enharmonicLabel(sn.note.noteName),
      'correct': true,
    });
    _noteDisplayTime = DateTime.now();
    notifyListeners();
  }

  void _markIncorrect(ScrollingNote sn, int reactionTime) {
    sn.answered = true;
    sn.correct = false;
    _statsBar.recordIncorrect(sn.note.midiNumber, reactionTime);
    isCorrect = false;
    correctAnswer = _enharmonicLabel(sn.note.noteName);
    attempts.add({
      'pressed': lastPressed,
      'expected': _enharmonicLabel(sn.note.noteName),
      'correct': false,
    });
    _noteDisplayTime = DateTime.now();
    notifyListeners();
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

  void resetSession() {
    _statsBar.reset();
    attempts.clear();
    _spawnInitialNotes();
    _isRunning = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _isRunning = false;
    _pitchSubscription?.cancel();
    _audioService.stopListening();
    _soundStopTimer?.cancel();
    SoundGenerator.release();
    super.dispose();
  }
}
