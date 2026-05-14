import 'package:flutter/material.dart';

class PianoKeyboard extends StatelessWidget {
  final void Function(String note) onNotePressed;

  const PianoKeyboard({Key? key, required this.onNotePressed})
      : super(key: key);

  static const whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  static const blackKeys = [
    {'note': 'C#\nDb', 'index': 0, 'value': 'C#'},
    {'note': 'D#\nEb', 'index': 1, 'value': 'D#'},
    {'note': 'F#\nGb', 'index': 3, 'value': 'F#'},
    {'note': 'G#\nAb', 'index': 4, 'value': 'G#'},
    {'note': 'A#\nBb', 'index': 5, 'value': 'A#'},
  ];
  static const whiteKeyWidth = 44.0;
  static const whiteKeyHeight = 160.0;
  static const blackKeyWidth = 28.0;
  static const blackKeyHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    final totalWidth = whiteKeyWidth * whiteKeys.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: SizedBox(
          width: totalWidth,
          height: whiteKeyHeight,
          child: Stack(
            children: [
              Row(
                children: whiteKeys.map((note) {
                  return SizedBox(
                    width: whiteKeyWidth,
                    height: whiteKeyHeight,
                    child: GestureDetector(
                      onTap: () => onNotePressed(note),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(note, style: const TextStyle(fontSize: 14)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              ...blackKeys.map((key) {
                final left = (key['index'] as int) * whiteKeyWidth +
                    whiteKeyWidth -
                    blackKeyWidth / 2;
                return Positioned(
                  left: left,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => onNotePressed(key['value'] as String),
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
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        key['note'] as String,
                        style:
                            const TextStyle(fontSize: 9, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
