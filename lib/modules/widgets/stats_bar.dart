import 'package:flutter/material.dart';
import '../../models/session_stats.dart';

class StatsBar extends StatelessWidget {
  final SessionStats stats;

  const StatsBar({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildStatItem('Correct', stats.correctCount.toString(), Colors.green),
          buildStatItem(
              'Incorrect', stats.incorrectCount.toString(), Colors.red),
          buildStatItem(
              'Accuracy', '${stats.accuracy.toStringAsFixed(1)}%', Colors.blue),
        ],
      ),
    );
  }

  Widget buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
