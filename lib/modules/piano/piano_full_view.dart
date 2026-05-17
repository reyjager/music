import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/midi_sound_service.dart';

class PianoFullView extends StatefulWidget {
  const PianoFullView({Key? key}) : super(key: key);

  @override
  State<PianoFullView> createState() => _PianoFullViewState();
}

class _PianoFullViewState extends State<PianoFullView> {
  final MidiSoundService _midiSound = MidiSoundService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _midiSound.initialize();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _playNote(int midi) {
    _midiSound.playNote(midi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano (5 Octaves)'),
        toolbarHeight: 36,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildPiano(),
      ),
    );
  }

  Widget _buildPiano() {
    const startOctave = 2;
    const octaves = 5;
    const whiteKeysPerOctave = 7;
    const totalWhiteKeys = whiteKeysPerOctave * octaves;
    const whiteKeyWidth = 44.0;
    const whiteKeyHeight = 180.0;
    const blackKeyWidth = 28.0;
    const blackKeyHeight = 110.0;

    const whiteNotes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    const blackKeys = [
      {'whiteIdx': 0, 'midiOffset': 1},  // C#
      {'whiteIdx': 1, 'midiOffset': 3},  // D#
      {'whiteIdx': 3, 'midiOffset': 6},  // F#
      {'whiteIdx': 4, 'midiOffset': 8},  // G#
      {'whiteIdx': 5, 'midiOffset': 10}, // A#
    ];

    final totalWidth = whiteKeyWidth * totalWhiteKeys;

    return SizedBox(
      width: totalWidth,
      height: whiteKeyHeight,
      child: Stack(
        children: [
          Row(
            children: List.generate(totalWhiteKeys, (i) {
              final octave = startOctave + i ~/ 7;
              final noteIndex = i % 7;
              final note = whiteNotes[noteIndex];
              final midi = _whiteKeyMidi(noteIndex, octave);
              return GestureDetector(
                onTap: () => _playNote(midi),
                child: Container(
                  width: whiteKeyWidth,
                  height: whiteKeyHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black87, width: 0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('$note$octave',
                      style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ),
              );
            }),
          ),
          ...List.generate(octaves, (oct) {
            return blackKeys.map((bk) {
              final whiteIndex = oct * 7 + (bk['whiteIdx'] as int);
              final left = whiteIndex * whiteKeyWidth + whiteKeyWidth - blackKeyWidth / 2;
              final octave = startOctave + oct;
              final midi = (octave + 1) * 12 + (bk['midiOffset'] as int);
              return Positioned(
                left: left,
                top: 0,
                child: GestureDetector(
                  onTap: () => _playNote(midi),
                  child: Container(
                    width: blackKeyWidth,
                    height: blackKeyHeight,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              );
            }).toList();
          }).expand((e) => e),
        ],
      ),
    );
  }

  int _whiteKeyMidi(int noteIndex, int octave) {
    const offsets = [0, 2, 4, 5, 7, 9, 11];
    return (octave + 1) * 12 + offsets[noteIndex];
  }
}
