import 'dart:math';
import '../models/key_signature.dart';
import '../models/musical_note.dart';

class NoteGeneratorService {
  final Random _random = Random();

  // All chromatic notes from C4 to B5 (includes sharps/flats)
  static const List<int> chromaticNotes = [
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, // C4-B4
    72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, // C5-B5
  ];

  MusicalNote generateRandomNote({KeySignature? keySignature}) {
    final midi = chromaticNotes[_random.nextInt(chromaticNotes.length)];
    return createNote(midi, keySignature: keySignature);
  }

  MusicalNote createNote(int midi, {KeySignature? keySignature}) {
    final noteName = keySignature != null
        ? _spellNoteInKey(midi, keySignature)
        : noteNameWithRandomSpelling(midi);
    final linePosition = calculateLinePosition(midi, noteName);

    return MusicalNote(
      midiNumber: midi,
      noteName: noteName,
      linePosition: linePosition,
    );
  }

  /// Generates only notes that belong to the key's diatonic scale.
  /// In A Major: A B C# D E F# G# (no G natural, no C natural, no F natural).
  MusicalNote generateNoteInKey(KeySignature keySignature) {
    final scaleNotes = _buildScaleMidiNotes(keySignature);
    final midi = scaleNotes[_random.nextInt(scaleNotes.length)];
    final noteName = _spellNoteInKey(midi, keySignature);
    final linePosition = calculateLinePosition(midi, noteName);
    return MusicalNote(midiNumber: midi, noteName: noteName, linePosition: linePosition);
  }

  /// Builds all MIDI notes in range that belong to the key's diatonic scale.
  List<int> _buildScaleMidiNotes(KeySignature keySignature) {
    // Diatonic semitone offsets from root for major scale: W W H W W W H
    const majorIntervals = [0, 2, 4, 5, 7, 9, 11];
    final root = _keyRoot(keySignature);
    final result = <int>[];
    for (final midi in chromaticNotes) {
      if (majorIntervals.contains((midi - root) % 12)) {
        result.add(midi);
      }
    }
    return result;
  }

  int _keyRoot(KeySignature keySignature) {
    const roots = {
      'C Major': 0, 'G Major': 7, 'D Major': 2, 'A Major': 9,
      'E Major': 4, 'B Major': 11, 'F# Major': 6, 'C# Major': 1,
      'F Major': 5, 'Bb Major': 10, 'Eb Major': 3, 'Ab Major': 8,
      'Db Major': 1, 'Gb Major': 6, 'Cb Major': 11,
    };
    return roots[keySignature.name] ?? 0;
  }

  /// Spells a MIDI note according to the key signature.
  String _spellNoteInKey(int midi, KeySignature keySignature) {
    final octave = (midi ~/ 12) - 1;
    final noteIndex = midi % 12;

    // Map semitone to letter + accidental based on key
    // Natural letters: C=0, D=2, E=4, F=5, G=7, A=9, B=11
    const naturalMap = {0: 'C', 2: 'D', 4: 'E', 5: 'F', 7: 'G', 9: 'A', 11: 'B'};

    if (naturalMap.containsKey(noteIndex)) {
      final letter = naturalMap[noteIndex]!;
      // If this letter is sharped in the key, this natural shouldn't appear
      // (handled by scale filtering), but just in case:
      if (keySignature.hasSharp(letter)) {
        // This is actually the flatted version of the sharp note
        // e.g., in A Major, natural G shouldn't be in scale
        return '$letter$octave';
      }
      if (keySignature.hasFlat(letter)) {
        return '$letter$octave';
      }
      return '$letter$octave';
    }

    // Accidental note - spell according to key
    if (keySignature.flats.isNotEmpty) {
      const flatSpelling = {1: 'Db', 3: 'Eb', 6: 'Gb', 8: 'Ab', 10: 'Bb'};
      return '${flatSpelling[noteIndex]}$octave';
    } else {
      const sharpSpelling = {1: 'C#', 3: 'D#', 6: 'F#', 8: 'G#', 10: 'A#'};
      return '${sharpSpelling[noteIndex]}$octave';
    }
  }

  /// Randomly spells sharps as flats (e.g. C# or Db)
  String noteNameWithRandomSpelling(int midi) {
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

  int calculateLinePosition(int midi, String noteName) {
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
