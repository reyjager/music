import 'package:flutter/material.dart';
import 'package:music_reading_trainir/modules/home/home_viewmodel.dart';
import 'package:music_reading_trainir/modules/home/widget/home_button_widget.dart';
import 'package:stacked/stacked.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => HomeViewmodel(),
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(),
            body: SafeArea(
                child: ListView.builder(
              itemCount: model.menuItems.length,
              itemBuilder: (context, index) => HomeButtonWidget(
                  menu: model.menuItems[index],
                  onTap: model.menuItems[index].onTap),
            )),
          );
        });
  }
}
