import 'package:flutter/material.dart';
import '../../../models/clef_config.dart';
import 'key_signature_selection_view.dart';

class BassClefTrainingView extends StatelessWidget {
  const BassClefTrainingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const KeySignatureSelectionView(config: ClefConfig.bass);
  }
}
