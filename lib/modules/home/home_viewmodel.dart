import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_reading_trainir/modules/piano/piano_full_view.dart';
import 'package:music_reading_trainir/modules/symbols_reference/symbols_reference_view.dart';
import 'package:music_reading_trainir/modules/training/clef/bass_page.dart';
import 'package:music_reading_trainir/modules/training/clef/treble_page.dart';
import 'package:stacked/stacked.dart';

class HomeMenuItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  HomeMenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

class HomeViewmodel extends BaseViewModel {
  final List<HomeMenuItem> menuItems = [
    HomeMenuItem(
      title: "Treble Clef",
      description: "Reading exercise for treble notes",
      onTap: () => Get.to(() => const TrebleClefTrainingView()),
      icon: Icons.music_note,
    ),
    HomeMenuItem(
      title: "Bass Clef",
      description: "Reading exercise for bass notes",
      onTap: () => Get.to(() => const BassClefTrainingView()),
      icon: Icons.music_video,
    ),
    HomeMenuItem(
      title: "Music Symbols",
      description: "Reference guide for all music symbols",
      onTap: () => Get.to(() => const SymbolsReferenceView()),
      icon: Icons.library_music,
    ),
    HomeMenuItem(
      title: "Piano",
      description: "5-octave piano keyboard",
      onTap: () => Get.to(() => const PianoFullView()),
      icon: Icons.piano,
    ),
  ];
}
