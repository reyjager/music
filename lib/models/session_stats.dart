class SessionStats {
  int correctCount = 0;
  int incorrectCount = 0;
  Map<int, int> missedNotes = {}; // MIDI number → miss count
  List<int> reactionTimes = []; // milliseconds

  double get accuracy {
    final total = correctCount + incorrectCount;
    return total == 0 ? 0 : (correctCount / total) * 100;
  }

  int? get mostMissedNote {
    if (missedNotes.isEmpty) return null;
    return missedNotes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get averageReactionTime {
    if (reactionTimes.isEmpty) return 0;
    return reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;
  }

  void recordCorrect(int reactionTimeMs) {
    correctCount++;
    reactionTimes.add(reactionTimeMs);
  }

  void recordIncorrect(int expectedMidi, int reactionTimeMs) {
    incorrectCount++;
    reactionTimes.add(reactionTimeMs);
    missedNotes[expectedMidi] = (missedNotes[expectedMidi] ?? 0) + 1;
  }

  void reset() {
    correctCount = 0;
    incorrectCount = 0;
    missedNotes.clear();
    reactionTimes.clear();
  }
}
