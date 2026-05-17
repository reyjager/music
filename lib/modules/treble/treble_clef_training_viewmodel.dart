import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../models/musical_note.dart';
import '../../models/session_stats.dart';
import '../../services/audio_service.dart';
import '../../services/midi_sound_service.dart';
import '../../services/note_generator_service.dart';
import '../../utils/pitch_converter.dart';

enum InputMode { microphone, buttons }

class ScrollingNote {
  final MusicalNote note;
  double xFraction; // 1.0 = right edge, 0.0 = left edge
  bool answered;
  bool? correct;

  ScrollingNote({required this.note, this.xFraction = 1.0})
      : answered = false,
        correct = null;
}

class TrebleClefTrainingViewModel extends BaseViewModel {
  final AudioService audioService;
  final NoteGeneratorService noteGenerator;

  TrebleClefTrainingViewModel({
    required this.audioService,
    required this.noteGenerator,
  });

  final MidiSoundService _midiSound = MidiSoundService();

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

  List<ScrollingNote> scrollingNotes = [];
  MusicalNote? get currentNote => _activeNote?.note;

  ScrollingNote? get _activeNote {
    for (final sn in scrollingNotes) {
      if (!sn.answered) return sn;
    }
    return null;
  }

  final SessionStats _stats = SessionStats();
  SessionStats get stats => _stats;

  bool showFeedback = false;
  bool isCorrect = false;
  String? correctAnswer;
  String? lastPressed;
  String? lastAnswerFeedback;
  Timer? _feedbackTimer;

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

  int? lastDetectedMidi;
  String? get lastDetectedNoteName => lastDetectedMidi != null
      ? PitchConverter.midiToNoteName(lastDetectedMidi!)
      : null;

  DateTime? noteDisplayTime;
  StreamSubscription? pitchSubscription;

  bool get isListening => audioService.isListening;

  static const double hitZone = 0.2;
  static const double _noteSpacing = 0.25;

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

  void initialize() async {
    await _midiSound.initialize();
    spawnInitialNotes();
    _isRunning = true;
    if (_inputMode == InputMode.microphone) {
      startListening();
    }
    notifyListeners();
  }

  void spawnInitialNotes() {
    scrollingNotes.clear();
    for (int i = 0; i < 5; i++) {
      scrollingNotes.add(ScrollingNote(
        note: noteGenerator.generateRandomNote(),
        xFraction: 0.8 + (i * _noteSpacing),
      ));
    }
    noteDisplayTime = DateTime.now();
  }

  /// Called every frame by the view's Ticker
  void tick() {
    if (!_isRunning) return;

    // Pause scrolling if active note reached hit zone and hasn't been answered
    final active = _activeNote;
    if (active != null && active.xFraction <= hitZone) {
      return;
    }

    for (final sn in scrollingNotes) {
      sn.xFraction -= _scrollSpeed;
    }

    // Remove notes that scrolled off screen
    scrollingNotes.removeWhere((sn) => sn.xFraction < -0.1);

    // Spawn new notes on the right
    if (scrollingNotes.isEmpty ||
        scrollingNotes.last.xFraction < 1.0 - _noteSpacing) {
      scrollingNotes.add(ScrollingNote(
        note: noteGenerator.generateRandomNote(),
        xFraction: 1.0,
      ));
    }

    notifyListeners();
  }

  Future<void> startListening() async {
    await audioService.startListening();

    pitchSubscription = audioService.pitchStream.listen((detectedMidi) {
      lastDetectedMidi = detectedMidi;
      notifyListeners();
      validateMidi(detectedMidi);
    });

    notifyListeners();
  }

  void validateMidi(int detectedMidi) {
    final active = _activeNote;
    if (active == null) return;

    final expected = active.note.midiNumber;
    final reactionTime =
        DateTime.now().difference(noteDisplayTime!).inMilliseconds;

    if (PitchConverter.notesMatch(detectedMidi, expected)) {
      _markCorrect(active, reactionTime);
    } else {
      markIncorrect(active, reactionTime);
    }
  }

  void manualNotePress(String noteLetter) {
    playNoteSound(noteLetter);

    final active = _activeNote;
    if (active == null) return;

    lastPressed = noteLetter;
    final expectedBase = active.note.noteName.replaceAll(RegExp(r'[0-9]'), '');
    final reactionTime =
        DateTime.now().difference(noteDisplayTime!).inMilliseconds;

    if (notesMatchByName(noteLetter, expectedBase)) {
      _markCorrect(active, reactionTime);
    } else {
      markIncorrect(active, reactionTime);
    }
  }

  void _markCorrect(ScrollingNote sn, int reactionTime) {
    sn.answered = true;
    sn.correct = true;
    _stats.recordCorrect(reactionTime);
    isCorrect = true;
    correctAnswer = enharmonicLabel(sn.note.noteName);
    lastAnswerFeedback = '✓ $lastPressed';
    _clearFeedbackAfterDelay();
    attempts.add({
      'pressed': lastPressed,
      'expected': enharmonicLabel(sn.note.noteName),
      'correct': true,
    });
    noteDisplayTime = DateTime.now();
    notifyListeners();
  }

  void markIncorrect(ScrollingNote sn, int reactionTime) {
    sn.answered = true;
    sn.correct = false;
    _stats.recordIncorrect(sn.note.midiNumber, reactionTime);
    isCorrect = false;
    correctAnswer = enharmonicLabel(sn.note.noteName);
    lastAnswerFeedback = '✗ $lastPressed → ${enharmonicLabel(sn.note.noteName)}';
    _clearFeedbackAfterDelay();
    attempts.add({
      'pressed': lastPressed,
      'expected': enharmonicLabel(sn.note.noteName),
      'correct': false,
    });
    noteDisplayTime = DateTime.now();
    notifyListeners();
  }

  void _clearFeedbackAfterDelay() {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
      lastAnswerFeedback = null;
      notifyListeners();
    });
  }

  bool notesMatchByName(String pressed, String expected) {
    if (pressed == expected) return true;
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

  String enharmonicLabel(String? noteName) {
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

  static const Map<String, int> _noteToMidiMap = {
    'C': 60, 'C#': 61, 'D': 62, 'D#': 63, 'E': 64,
    'F': 65, 'F#': 66, 'G': 67, 'G#': 68, 'A': 69, 'A#': 70, 'B': 71,
  };

  void playNoteSound(String noteLetter) {
    final midi = _noteToMidiMap[noteLetter];
    if (midi == null) return;
    _midiSound.playNote(midi);
  }

  void resetSession() {
    _stats.reset();
    attempts.clear();
    spawnInitialNotes();
    _isRunning = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _isRunning = false;
    _feedbackTimer?.cancel();
    pitchSubscription?.cancel();
    audioService.stopListening();
    super.dispose();
  }
}
