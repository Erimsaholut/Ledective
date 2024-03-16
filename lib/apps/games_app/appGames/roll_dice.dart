import 'dart:math';
import 'package:flutter/material.dart';


class RollTheDices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zar Sallama Oyunu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RollTheDicesScreen(),
    );
  }
}

class RollTheDicesScreen extends StatefulWidget {
  @override
  _RollTheDicesScreenState createState() => _RollTheDicesScreenState();
}

class _RollTheDicesScreenState extends State<RollTheDicesScreen> {
  int zar1 = 1;
  int zar2 = 1;

  void _rollDices() {
    setState(() {
      zar1 = Random().nextInt(6) + 1;
      zar2 = Random().nextInt(6) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zar Sallama Oyunu'),
        backgroundColor: Colors.red,
        leading: BackButton(onPressed: (){Navigator.pop(context);},),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      '$zar1',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                  ),
                  child: Center(
                    child: Text(
                      '$zar2',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _rollDices,
              child: Text('Zarları Salla'),
            ),
          ],
        ),
      ),
    );
  }
}
