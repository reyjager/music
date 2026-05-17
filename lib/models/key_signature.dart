class KeySignature {
  final String name;
  final List<String> sharps; // note letters with sharps in this key
  final List<String> flats; // note letters with flats in this key

  const KeySignature({
    required this.name,
    this.sharps = const [],
    this.flats = const [],
  });

  bool isNatural(String letter) =>
      !sharps.contains(letter) && !flats.contains(letter);

  bool hasSharp(String letter) => sharps.contains(letter);
  bool hasFlat(String letter) => flats.contains(letter);

  /// Treble clef staff positions for sharps (F C G D A E B)
  static const List<int> trebleSharpPositions = [4, 1, 5, 2, -1, 3, 0];

  /// Treble clef staff positions for flats (B E A D G C F)
  static const List<int> trebleFlatPositions = [0, 3, -1, 2, -2, 1, -3];

  /// Bass clef staff positions for sharps (F C G D A E B)
  static const List<int> bassSharpPositions = [2, -1, 3, 0, -3, 1, -2];

  /// Bass clef staff positions for flats (B E A D G C F)
  static const List<int> bassFlatPositions = [-2, 1, -3, 0, -4, -1, -5];

  static const List<KeySignature> allKeys = [
    KeySignature(name: 'C Major'),
    KeySignature(name: 'G Major', sharps: ['F']),
    KeySignature(name: 'D Major', sharps: ['F', 'C']),
    KeySignature(name: 'A Major', sharps: ['F', 'C', 'G']),
    KeySignature(name: 'E Major', sharps: ['F', 'C', 'G', 'D']),
    KeySignature(name: 'B Major', sharps: ['F', 'C', 'G', 'D', 'A']),
    KeySignature(name: 'F# Major', sharps: ['F', 'C', 'G', 'D', 'A', 'E']),
    KeySignature(name: 'C# Major', sharps: ['F', 'C', 'G', 'D', 'A', 'E', 'B']),
    KeySignature(name: 'F Major', flats: ['B']),
    KeySignature(name: 'Bb Major', flats: ['B', 'E']),
    KeySignature(name: 'Eb Major', flats: ['B', 'E', 'A']),
    KeySignature(name: 'Ab Major', flats: ['B', 'E', 'A', 'D']),
    KeySignature(name: 'Db Major', flats: ['B', 'E', 'A', 'D', 'G']),
    KeySignature(name: 'Gb Major', flats: ['B', 'E', 'A', 'D', 'G', 'C']),
    KeySignature(name: 'Cb Major', flats: ['B', 'E', 'A', 'D', 'G', 'C', 'F']),
  ];
}
