import 'dart:math';

class PitchConverter {
  static const double a4Frequency = 440.0;
  static const int a4MidiNumber = 69;

  /// Convert frequency (Hz) to MIDI note number
  /// Formula: midi = 69 + 12 * log2(frequency / 440)
  static int frequencyToMidi(double frequency) {
    if (frequency <= 0) return -1;
    final midi = a4MidiNumber + 12 * (log(frequency / a4Frequency) / ln2);
    return midi.round();
  }

  /// Convert MIDI number to note name (e.g., 60 → "C4")
  static String midiToNoteName(int midi) {
    const noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = (midi ~/ 12) - 1;
    final noteName = noteNames[midi % 12];
    return '$noteName$octave';
  }

  /// Check if two MIDI notes match within tolerance
  static bool notesMatch(int detected, int expected, {int tolerance = 0}) {
    return (detected - expected).abs() <= tolerance;
  }
}
