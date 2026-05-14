import 'package:flutter/material.dart';
import '../widgets/music_symbols/music_symbols.dart';

class SymbolsReferenceView extends StatelessWidget {
  const SymbolsReferenceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Music Symbols'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Notes'),
              Tab(text: 'Rests'),
              Tab(text: 'Clefs'),
              Tab(text: 'Accidentals'),
              Tab(text: 'Dynamics'),
              Tab(text: 'Articulations'),
              Tab(text: 'Time Sig.'),
              Tab(text: 'Key Sig.'),
              Tab(text: 'Measures'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTab([
              _symbolItem(const NoteValueWidget(noteType: 'whole', size: 50),
                  'Whole Note (4 beats)'),
              _symbolItem(const NoteValueWidget(noteType: 'half', size: 50),
                  'Half Note (2 beats)'),
              _symbolItem(const NoteValueWidget(noteType: 'quarter', size: 50),
                  'Quarter Note (1 beat)'),
              _symbolItem(const NoteValueWidget(noteType: 'eighth', size: 50),
                  'Eighth Note (½ beat)'),
              _symbolItem(
                  const NoteValueWidget(noteType: 'sixteenth', size: 50),
                  'Sixteenth Note (¼ beat)'),
            ]),
            _buildTab([
              _symbolItem(const RestWidget(restType: 'whole', size: 50),
                  'Whole Rest (4 beats)'),
              _symbolItem(const RestWidget(restType: 'half', size: 50),
                  'Half Rest (2 beats)'),
              _symbolItem(const RestWidget(restType: 'quarter', size: 50),
                  'Quarter Rest (1 beat)'),
              _symbolItem(const RestWidget(restType: 'eighth', size: 50),
                  'Eighth Rest (½ beat)'),
              _symbolItem(const RestWidget(restType: 'sixteenth', size: 50),
                  'Sixteenth Rest (¼ beat)'),
            ]),
            _buildTab([
              _symbolItem(const ClefWidget(clefType: 'treble', size: 50),
                  'Treble Clef'),
              _symbolItem(
                  const ClefWidget(clefType: 'bass', size: 50), 'Bass Clef'),
              _symbolItem(
                  const ClefWidget(clefType: 'alto', size: 50), 'Alto Clef'),
              _symbolItem(
                  const ClefWidget(clefType: 'tenor', size: 50), 'Tenor Clef'),
            ]),
            _buildTab([
              _symbolItem(
                  const AccidentalWidget(accidentalType: 'sharp', size: 50),
                  '♯ Sharp'),
              _symbolItem(
                  const AccidentalWidget(accidentalType: 'flat', size: 50),
                  '♭ Flat'),
              _symbolItem(
                  const AccidentalWidget(accidentalType: 'natural', size: 50),
                  '♮ Natural'),
              _symbolItem(
                  const AccidentalWidget(
                      accidentalType: 'doubleSharp', size: 50),
                  '𝄪 Double Sharp'),
              _symbolItem(
                  const AccidentalWidget(
                      accidentalType: 'doubleFlat', size: 50),
                  '𝄫 Double Flat'),
            ]),
            _buildTab([
              _symbolItem(const DynamicsWidget(dynamicType: 'pp', size: 50),
                  'Pianissimo (very soft)'),
              _symbolItem(const DynamicsWidget(dynamicType: 'p', size: 50),
                  'Piano (soft)'),
              _symbolItem(const DynamicsWidget(dynamicType: 'mp', size: 50),
                  'Mezzo-piano (moderately soft)'),
              _symbolItem(const DynamicsWidget(dynamicType: 'mf', size: 50),
                  'Mezzo-forte (moderately loud)'),
              _symbolItem(const DynamicsWidget(dynamicType: 'f', size: 50),
                  'Forte (loud)'),
              _symbolItem(const DynamicsWidget(dynamicType: 'ff', size: 50),
                  'Fortissimo (very loud)'),
              _symbolItem(const DynamicsWidget(dynamicType: 'sfz', size: 50),
                  'Sforzando (sudden emphasis)'),
            ]),
            _buildTab([
              _symbolItem(
                  const ArticulationWidget(
                      articulationType: 'staccato', size: 50),
                  'Staccato (short, detached)'),
              _symbolItem(
                  const ArticulationWidget(
                      articulationType: 'legato', size: 50),
                  'Legato / Slur (smooth)'),
              _symbolItem(
                  const ArticulationWidget(
                      articulationType: 'accent', size: 50),
                  'Accent (stressed)'),
              _symbolItem(
                  const ArticulationWidget(
                      articulationType: 'tenuto', size: 50),
                  'Tenuto (held)'),
            ]),
            _buildTab([
              _symbolItem(
                  const TimeSignatureWidget(upper: 4, lower: 4, size: 50),
                  '4/4 - Common Time'),
              _symbolItem(
                  const TimeSignatureWidget(upper: 3, lower: 4, size: 50),
                  '3/4 - Waltz Time'),
              _symbolItem(
                  const TimeSignatureWidget(upper: 2, lower: 4, size: 50),
                  '2/4 - March Time'),
              _symbolItem(
                  const TimeSignatureWidget(upper: 6, lower: 8, size: 50),
                  '6/8 - Compound Duple'),
              _symbolItem(
                  const TimeSignatureWidget(upper: 2, lower: 2, size: 50),
                  '2/2 - Cut Time'),
              _symbolItem(
                  const TimeSignatureWidget(upper: 3, lower: 8, size: 50),
                  '3/8'),
              _symbolItem(
                  const TimeSignatureWidget(upper: 9, lower: 8, size: 50),
                  '9/8 - Compound Triple'),
              _symbolItem(
                  const TimeSignatureWidget(upper: 12, lower: 8, size: 50),
                  '12/8 - Compound Quadruple'),
            ]),
            _buildTab([
              _symbolItem(
                  const KeySignatureWidget(
                      sharps: 0, flats: 0, size: 50, clefType: 'treble'),
                  'C Major / A Minor (no accidentals)'),
              _symbolItem(const KeySignatureWidget(sharps: 1, size: 50),
                  'G Major / E Minor (1 sharp)'),
              _symbolItem(const KeySignatureWidget(sharps: 2, size: 50),
                  'D Major / B Minor (2 sharps)'),
              _symbolItem(const KeySignatureWidget(sharps: 3, size: 50),
                  'A Major / F# Minor (3 sharps)'),
              _symbolItem(const KeySignatureWidget(sharps: 4, size: 50),
                  'E Major / C# Minor (4 sharps)'),
              _symbolItem(const KeySignatureWidget(sharps: 5, size: 50),
                  'B Major / G# Minor (5 sharps)'),
              _symbolItem(const KeySignatureWidget(flats: 1, size: 50),
                  'F Major / D Minor (1 flat)'),
              _symbolItem(const KeySignatureWidget(flats: 2, size: 50),
                  'Bb Major / G Minor (2 flats)'),
              _symbolItem(const KeySignatureWidget(flats: 3, size: 50),
                  'Eb Major / C Minor (3 flats)'),
              _symbolItem(const KeySignatureWidget(flats: 4, size: 50),
                  'Ab Major / F Minor (4 flats)'),
              _symbolItem(const KeySignatureWidget(flats: 5, size: 50),
                  'Db Major / Bb Minor (5 flats)'),
            ]),
            _buildTab([
              _symbolItem(const MeasureWidget(barlineType: 'single', size: 50),
                  'Single Barline'),
              _symbolItem(const MeasureWidget(barlineType: 'double', size: 50),
                  'Double Barline'),
              _symbolItem(const MeasureWidget(barlineType: 'final', size: 50),
                  'Final Barline (end of piece)'),
              _symbolItem(
                  const MeasureWidget(barlineType: 'repeatStart', size: 50),
                  'Repeat Start'),
              _symbolItem(
                  const MeasureWidget(barlineType: 'repeatEnd', size: 50),
                  'Repeat End'),
              _symbolItem(
                  const MeasureWidget(barlineType: 'repeatBoth', size: 50),
                  'Repeat Both (end & start)'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(List<Widget> items) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items,
    );
  }

  Widget _symbolItem(Widget symbol, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 80, height: 80, child: Center(child: symbol)),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
