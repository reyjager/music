enum ClefType { treble, bass, alto, tenor }

class ClefConfig {
  final String title;
  final ClefType clefType;
  final Map<String, int> noteToMidiMap;
  final List<int> noteRange;

  const ClefConfig({
    required this.title,
    required this.clefType,
    required this.noteToMidiMap,
    required this.noteRange,
  });

  bool get isBassClef => clefType == ClefType.bass;

  static const treble = ClefConfig(
    title: 'Treble Clef Training',
    clefType: ClefType.treble,
    noteToMidiMap: {
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
    },
    noteRange: [
      60,
      61,
      62,
      63,
      64,
      65,
      66,
      67,
      68,
      69,
      70,
      71,
      72,
      73,
      74,
      75,
      76,
      77,
      78,
      79,
      80,
      81,
      82,
      83
    ],
  );

  static const bass = ClefConfig(
    title: 'Bass Clef Training',
    clefType: ClefType.bass,
    noteToMidiMap: {
      'C': 48,
      'C#': 49,
      'D': 50,
      'D#': 51,
      'E': 52,
      'F': 53,
      'F#': 54,
      'G': 55,
      'G#': 56,
      'A': 57,
      'A#': 58,
      'B': 59,
    },
    noteRange: [
      36,
      37,
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      51,
      52,
      53,
      54,
      55,
      56,
      57,
      58,
      59
    ],
  );
}
