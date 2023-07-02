import 'package:flutter/material.dart';
import 'package:ledective/apps/settings_app/settings_container.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color kThemeColor = Colors.grey.shade500;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: const BackButton(),
        backgroundColor: kThemeColor,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kThemeColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView(
            children: const [
              SizedBox(height: 20),
              SettingsContainer(name: "Main Screen Background Color",),
            ],
          ),
        ),
      ),
    );
  }
}
