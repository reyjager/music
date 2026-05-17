import 'package:flutter/material.dart';
import '../../../models/clef_config.dart';
import '../training_view.dart';

class BassClefTrainingView extends StatelessWidget {
  const BassClefTrainingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TrainingView(config: ClefConfig.bass);
  }
}
