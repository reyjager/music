import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_reading_trainir/modules/home/home_view.dart';
// import '../modules/treble/treble_clef_training_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piano Sight Reading',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
