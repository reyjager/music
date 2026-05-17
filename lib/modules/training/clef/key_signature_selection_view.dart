import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/clef_config.dart';
import '../../../models/key_signature.dart';
import '../../widgets/music_symbols/key_signature_painter.dart';
import '../training_view.dart';

class KeySignatureSelectionView extends StatelessWidget {
  final ClefConfig config;

  const KeySignatureSelectionView({Key? key, required this.config})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${config.title} - Select Key')),
      body: ListView.builder(
        itemCount: KeySignature.allKeys.length,
        itemBuilder: (context, index) {
          final ks = KeySignature.allKeys[index];
          return ListTile(
            title: Text(ks.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KeySignatureWidget(
                  sharps: ks.sharps.length,
                  flats: ks.flats.length,
                  clefType: config.isBassClef ? 'bass' : 'treble',
                  size: 40,
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => Get.to(() => TrainingView(
                  config: config,
                  keySignature: ks,
                )),
          );
        },
      ),
    );
  }
}
