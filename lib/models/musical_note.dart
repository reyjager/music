class MusicalNote {
  final int midiNumber; // 60 = Middle C
  final String noteName; // "C4", "C#4", etc.
  final int linePosition; // Position on staff (0 = middle line)

  MusicalNote({
    required this.midiNumber,
    required this.noteName,
    required this.linePosition,
  });

  /// Returns '#' for sharp, 'b' for flat, or null for natural
  String? get accidental {
    if (noteName.contains('#')) return '#';
    if (RegExp(r'[A-G]b').hasMatch(noteName)) return 'b';
    return null;
  }

  bool get isSharp => noteName.contains('#');
  bool get isFlat => RegExp(r'[A-G]b').hasMatch(noteName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicalNote && midiNumber == other.midiNumber;

  @override
  int get hashCode => midiNumber.hashCode;
}
