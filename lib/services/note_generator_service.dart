import 'dart:math';
import '../models/musical_note.dart';

class NoteGeneratorService {
  final Random _random = Random();

  // All chromatic notes from C4 to B5 (includes sharps/flats)
  static const List<int> chromaticNotes = [
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, // C4-B4
    72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, // C5-B5
  ];

  MusicalNote generateRandomNote() {
    final midi = chromaticNotes[_random.nextInt(chromaticNotes.length)];
    return _createNote(midi);
  }

  MusicalNote _createNote(int midi) {
    final noteName = _noteNameWithRandomSpelling(midi);
    final linePosition = _calculateLinePosition(midi, noteName);

    return MusicalNote(
      midiNumber: midi,
      noteName: noteName,
      linePosition: linePosition,
    );
  }

  /// Randomly spells sharps as flats (e.g. C# or Db)
  String _noteNameWithRandomSpelling(int midi) {
    const sharpNames = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B'
    ];
    const flatNames = [
      'C',
      'Db',
      'D',
      'Eb',
      'E',
      'F',
      'Gb',
      'G',
      'Ab',
      'A',
      'Bb',
      'B'
    ];
    final octave = (midi ~/ 12) - 1;
    final noteIndex = midi % 12;
    // Natural notes have same name in both, only pick for accidentals
    if (sharpNames[noteIndex] == flatNames[noteIndex]) {
      return '${sharpNames[noteIndex]}$octave';
    }
    final useFlat = _random.nextBool();
    final name = useFlat ? flatNames[noteIndex] : sharpNames[noteIndex];
    return '$name$octave';
  }

  int _calculateLinePosition(int midi, String noteName) {
    // Position is based on the letter name, not the MIDI number.
    // Treble clef: middle line (position 0) = B4
    // Each step up = +1 position
    // C4=-6, D4=-5, E4=-4, F4=-3, G4=-2, A4=-1, B4=0
    // C5=1, D5=2, E5=3, F5=4, G5=5, A5=6, B5=7
    const letterPositions = {
      'C': 0,
      'D': 1,
      'E': 2,
      'F': 3,
      'G': 4,
      'A': 5,
      'B': 6,
    };

    final letter = noteName[0];
    final octave = int.parse(noteName[noteName.length - 1]);
    final basePosition = letterPositions[letter]!;
    // C4 is at position -6, each octave adds 7
    return basePosition + (octave - 4) * 7 - 6;
  }
}
