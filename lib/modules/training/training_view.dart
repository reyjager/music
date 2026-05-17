import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import '../../models/clef_config.dart';
import '../../services/audio_service.dart';
import '../../services/note_generator_service.dart';
import '../widgets/staff_painter.dart';
import '../widgets/piano_keyboard.dart';
import '../widgets/stats_bar.dart';
import 'training_viewmodel.dart';

class TrainingView extends StatefulWidget {
  final ClefConfig config;

  const TrainingView({Key? key, required this.config}) : super(key: key);

  @override
  State<TrainingView> createState() => _TrainingViewState();
}

class _TrainingViewState extends State<TrainingView>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  TrainingViewModel? _model;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _model?.tick());
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  List<NotePosition> buildNotePositions(TrainingViewModel model) {
    return model.scrollingNotes.map((sn) {
      return NotePosition(
        note: sn.note,
        xFraction: sn.xFraction,
        color: model.noteColorFor(sn),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TrainingViewModel>.reactive(
      viewModelBuilder: () => TrainingViewModel(
        config: widget.config,
        audioService: AudioService(),
        noteGenerator: NoteGeneratorService(),
      ),
      onViewModelReady: (model) {
        _model = model;
        model.initialize();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.config.title),
            actions: [
              IconButton(
                icon: Icon(model.isRunning ? Icons.pause : Icons.play_arrow),
                tooltip: model.isRunning ? 'Pause' : 'Resume',
                onPressed: model.togglePause,
              ),
              IconButton(
                icon: Icon(model.showFeedbackEnabled
                    ? Icons.visibility
                    : Icons.visibility_off),
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
                StatsBar(stats: model.stats),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.speed, size: 20),
                      Expanded(
                        child: Slider(
                          value: model.scrollSpeed,
                          min: 0.001,
                          max: 0.008,
                          onChanged: model.setScrollSpeed,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SegmentedButton<ClefInputMode>(
                    segments: const [
                      ButtonSegment(
                          value: ClefInputMode.buttons,
                          label: Text('Buttons'),
                          icon: Icon(Icons.piano)),
                      ButtonSegment(
                          value: ClefInputMode.microphone,
                          label: Text('Mic'),
                          icon: Icon(Icons.mic)),
                    ],
                    selected: {model.inputMode},
                    onSelectionChanged: (s) => model.toggleInputMode(s.first),
                  ),
                ),
                Container(
                  height: 200,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: StaffPainter(
                          isBassClef: widget.config.isBassClef,
                          noteQueue: buildNotePositions(model),
                        ),
                        size: Size.infinite,
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          margin: const EdgeInsets.only(left: 60),
                          color: Colors.blue.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (model.inputMode == ClefInputMode.buttons)
                  PianoKeyboard(onNotePressed: model.manualNotePress),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: model.lastAnswerFeedback != null
                      ? Text(
                          model.lastAnswerFeedback!,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: model.isCorrect ? Colors.green : Colors.red,
                          ),
                        )
                      : model.currentNote != null
                          ? Text(
                              'Play: ${model.currentNote!.noteName}',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            )
                          : const SizedBox.shrink(),
                ),
                if (model.inputMode == ClefInputMode.microphone)
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

  void showReviewOverlay(BuildContext context, TrainingViewModel model) {
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
