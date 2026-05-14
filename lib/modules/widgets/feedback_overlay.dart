// import 'package:flutter/material.dart';

// class FeedbackOverlay extends StatelessWidget {
//   final bool isCorrect;
//   final String? correctAnswer;

//   const FeedbackOverlay({Key? key, required this.isCorrect, this.correctAnswer}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isCorrect ? Icons.check_circle : Icons.cancel,
//               size: 120,
//               color: isCorrect ? Colors.green : Colors.red,
//             ),
//             if (!isCorrect && correctAnswer != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: Text(
//                   'Correct: $correctAnswer',
//                   style: const TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
