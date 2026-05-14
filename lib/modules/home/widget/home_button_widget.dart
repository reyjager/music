import 'package:flutter/material.dart';
import '../home_viewmodel.dart';

class HomeButtonWidget extends StatelessWidget {
  final HomeMenuItem menu;
  final VoidCallback onTap;

  const HomeButtonWidget({super.key, required this.menu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              children: [
                Icon(
                  menu.icon,
                  color: Colors.white,
                  size: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        menu.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(
                        menu.description,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
