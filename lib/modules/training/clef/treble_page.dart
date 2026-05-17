import 'package:flutter/material.dart';
import '../../../models/clef_config.dart';
import 'key_signature_selection_view.dart';

class TrebleClefTrainingView extends StatelessWidget {
  const TrebleClefTrainingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const KeySignatureSelectionView(config: ClefConfig.treble);
  }
}
