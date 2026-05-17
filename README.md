# Piano Sight Reading Trainer

<p>
  <img src="assets/home.png" width="200">
  <img src="assets/treble.png" width="200">
  <img src="assets/bass.png" width="200">
  <img src="assets/symbols.png" width="200">
</p>

Flutter mobile app for acoustic piano sight-reading training using MVVM architecture with Stacked + GetX navigation.

## Architecture

### MVVM + Stacked + GetX

```
┌─────────────────────────────────────────────────────────┐
│                         View                            │
│              (StatefulWidget + Stacked)                 │
│  - Displays scrolling staff, notes, feedback            │
│  - Observes ViewModel via ViewModelBuilder.reactive     │
│  - Ticker-driven animation loop                         │
└────────────────────┬────────────────────────────────────┘
                     │ notifyListeners()
                     ▼
┌─────────────────────────────────────────────────────────┐
│                     ViewModel                           │
│              (extends BaseViewModel)                    │
│  - Scrolling note queue management                      │
│  - Score tracking (SessionStats)                        │
│  - Input validation (buttons + microphone)              │
│  - Reaction time tracking                               │
│  - Enharmonic note matching                             │
└────────────┬──────────────┬──────────────┬──────────────┘
             │              │              │
             ▼              ▼              ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│ NoteGenerator    │ │ AudioService │ │ MidiSoundService │
│ Service          │ │              │ │                  │
│ - Random note gen│ │ - Mic stream │ │ - WAV synthesis  │
│ - Clef-aware     │ │ - Pitch det. │ │ - Note playback  │
└──────────────────┘ │ - MIDI conv. │ └──────────────────┘
                     └──────────────┘
```

## Project Structure

```
lib/
├── main.dart
├── app/
│   └── app.dart                              # GetMaterialApp config
├── models/
│   ├── clef_config.dart                      # ClefConfig (treble/bass ranges, MIDI maps)
│   ├── musical_note.dart                     # Note data (MIDI, name, position)
│   └── session_stats.dart                    # Statistics tracking
├── modules/
│   ├── home/
│   │   ├── widget/
│   │   │   └── home_button_widget.dart       # Menu item card
│   │   ├── home_view.dart                    # Home screen (ListView menu)
│   │   └── home_viewmodel.dart               # Menu items + navigation
│   ├── symbols_reference/
│   │   ├── music_symbols.dart                # Symbol data definitions
│   │   └── symbols_reference_view.dart       # Symbol reference page
│   ├── training/
│   │   ├── clef/
│   │   │   ├── bass_page.dart                # Bass clef entry point
│   │   │   └── treble_page.dart              # Treble clef entry point
│   │   ├── training_view.dart                # Shared training UI (scrolling staff)
│   │   └── training_viewmodel.dart           # Training logic + state
│   └── widgets/
│       ├── music_symbols/
│       │   ├── accidentals_painter.dart
│       │   ├── articulations_painter.dart
│       │   ├── clefs_painter_widgets.dart
│       │   ├── dynamics_painter.dart
│       │   ├── key_signature_painter.dart
│       │   ├── measures_painter.dart
│       │   ├── music_staff_painter.dart
│       │   ├── note_values_painter.dart
│       │   ├── other_symbols_painter.dart
│       │   ├── rests_painter.dart
│       │   └── time_signature_painter.dart
│       ├── feedback_overlay.dart
│       ├── piano_keyboard.dart               # On-screen piano input
│       ├── staff_painter.dart                # CustomPainter for staff + notes
│       └── stats_bar.dart                    # Session stats display
├── services/
│   ├── audio_service.dart                    # Microphone pitch detection
│   ├── midi_sound_service.dart               # Synthesized piano playback
│   └── note_generator_service.dart           # Random note generation
└── utils/
    └── pitch_converter.dart                  # Frequency ↔ MIDI conversion
```

## Key Features

### Scrolling Note System
- Notes scroll right-to-left across the staff
- Hit zone at left side where notes must be answered
- Configurable scroll speed via slider
- Auto-spawns new notes as previous ones are answered

### Dual Input Modes
- **Piano Buttons**: On-screen keyboard with note buttons
- **Microphone**: Real-time pitch detection from acoustic piano

### Clef Support
- **Treble Clef**: MIDI 60–83 (C4–B5)
- **Bass Clef**: MIDI 36–59 (C2–B3)

### Enharmonic Matching
- Accepts enharmonic equivalents (e.g., C#/Db)
- Displays enharmonic labels in feedback

### Audio Feedback
- Synthesized piano sound on button press (WAV generation)
- Exponential decay envelope with harmonic overtones

### Music Symbols Reference
- Comprehensive reference page for music notation symbols
- Custom painters for clefs, dynamics, articulations, accidentals, etc.

### Statistics Tracking
- Correct/incorrect counts
- Accuracy percentage
- Most missed note
- Average reaction time (ms)
- Per-attempt review log

## Dependencies

| Package | Purpose |
|---------|---------|
| stacked | MVVM architecture |
| get | Navigation (GetX) |
| permission_handler | Microphone permissions |
| pitch_detector_dart | Pitch detection |
| record | Audio recording |
| just_audio | Audio playback |
| path_provider | Temp file storage |

## Setup

```bash
flutter pub get
flutter run
```

### Platform Setup
- **Android**: See [ANDROID_SETUP.md](ANDROID_SETUP.md)
- **iOS**: See [IOS_SETUP.md](IOS_SETUP.md) (AudioKit via CocoaPods)

## Development Status

### ✅ Completed
- MVVM structure with Stacked + GetX navigation
- Models (MusicalNote, SessionStats, ClefConfig)
- Services (AudioService, NoteGeneratorService, MidiSoundService)
- Scrolling staff with CustomPainter
- Treble + Bass clef training modes
- On-screen piano keyboard input
- Microphone pitch detection input
- Synthesized piano sound feedback
- Session statistics + attempt review
- Music symbols reference page
- Pause/resume, speed control, reset

### ⏳ Planned
- Difficulty levels (tolerance ±1 semitone vs exact)
- Note range customization
- Practice modes (scales, intervals)
- Progress tracking / daily streaks
- End-of-session summary screen
- Performance optimization (isolate-based pitch detection)

## License

MIT
