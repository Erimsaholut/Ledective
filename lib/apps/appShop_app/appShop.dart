import 'package:flutter/material.dart';

class AppShop extends StatefulWidget {
  const AppShop({Key? key}) : super(key: key);

  @override
  _AppShopState createState() => _AppShopState();
}

class _AppShopState extends State<AppShop> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AppShop"),
        backgroundColor: Colors.red,
      ),
      body: const SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.error_outline,
                size: 300,
                color: Colors.red,
              ),
              SizedBox(height: 30),
              Text(
                "Sorry\nappShop is currently not available",
                style:
                    TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
