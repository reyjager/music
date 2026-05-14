import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'treble_clef_training_viewmodel.dart';
export 'treble_clef_training_viewmodel.dart' show InputMode;
import '../../models/musical_note.dart';
import '../widgets/staff_painter.dart';
import '../widgets/piano_keyboard.dart';
import '../widgets/stats_bar.dart';
import '../../services/audio_service.dart';
import '../../services/note_generator_service.dart';

class TrebleClefTrainingView extends StatefulWidget {
  const TrebleClefTrainingView({Key? key}) : super(key: key);

  @override
  State<TrebleClefTrainingView> createState() => _TrebleClefTrainingViewState();
}

class _TrebleClefTrainingViewState extends State<TrebleClefTrainingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _noteAnimController;
  late Animation<double> _noteAnimation;
  MusicalNote? _lastNote;

  @override
  void initState() {
    super.initState();
    _noteAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );
    _noteAnimation = Tween<double>(begin: 1.0, end: 0.35).animate(
      CurvedAnimation(parent: _noteAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _noteAnimController.dispose();
    super.dispose();
  }

  void _checkNoteChanged(MusicalNote? currentNote) {
    if (currentNote != _lastNote) {
      _lastNote = currentNote;
      _noteAnimController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TrebleClefTrainingViewModel>.reactive(
      viewModelBuilder: () => TrebleClefTrainingViewModel(
        audioService: AudioService(),
        noteGenerator: NoteGeneratorService(),
      ),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) {
        _checkNoteChanged(model.currentNote);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Treble clef Sight Reading'),
            actions: [
              IconButton(
                icon: Icon(
                  model.showFeedbackEnabled
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                tooltip: 'Toggle feedback',
                onPressed: model.toggleShowFeedback,
              ),
              IconButton(
                icon: const Icon(Icons.list_alt),
                onPressed: () => showReviewOverlay(context, model),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: model.resetSession,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Stats bar
                StatsBar(stats: model.stats),

                // Input mode toggle
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SegmentedButton<InputMode>(
                    segments: const [
                      ButtonSegment(
                          value: InputMode.buttons,
                          label: Text('Buttons'),
                          icon: Icon(Icons.piano)),
                      ButtonSegment(
                          value: InputMode.microphone,
                          label: Text('Mic'),
                          icon: Icon(Icons.mic)),
                    ],
                    selected: {model.inputMode},
                    onSelectionChanged: (s) => model.toggleInputMode(s.first),
                  ),
                ),

                // Staff display
                Container(
                  height: 200,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _noteAnimation,
                        builder: (context, _) => LayoutBuilder(
                          builder: (context, constraints) {
                            final noteX =
                                constraints.maxWidth * _noteAnimation.value;
                            return CustomPaint(
                              painter: StaffPainter(
                                note: model.currentNote,
                                noteColor: model.noteColor,
                                noteXOffset: noteX,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                      ),
                      if (model.showFeedback && model.showFeedbackEnabled)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  (model.isCorrect ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              model.isCorrect
                                  ? '✓ ${model.lastPressed}'
                                  : '✗ ${model.lastPressed} → ${model.correctAnswer}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Piano keyboard (only in button mode)
                if (model.inputMode == InputMode.buttons)
                  PianoKeyboard(onNotePressed: model.manualNotePress),

                // Current note name (for debugging)
                if (model.currentNote != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Play: ${model.currentNote!.noteName}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),

                // Listening indicator (only in mic mode)
                if (model.inputMode == InputMode.microphone)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              model.isListening ? Icons.mic : Icons.mic_off,
                              color: model.isListening
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              model.isListening
                                  ? 'Listening...'
                                  : 'Not listening',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (model.lastDetectedMidi != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Heard: ${model.lastDetectedNoteName}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showReviewOverlay(
      BuildContext context, TrebleClefTrainingViewModel model) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Review',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (model.attempts.isEmpty)
                const Text('No attempts yet.')
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: model.attempts.length,
                    itemBuilder: (context, index) {
                      final a = model.attempts[index];
                      final correct = a['correct'] as bool;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          correct ? Icons.check_circle : Icons.cancel,
                          color: correct ? Colors.green : Colors.red,
                        ),
                        title: Text('Pressed: ${a['pressed']}'),
                        subtitle: Text('Expected: ${a['expected']}'),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
