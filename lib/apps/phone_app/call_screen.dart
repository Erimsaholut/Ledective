import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ledective/apps/tools/round_icon_button.dart';

import '../../data_base/datas.dart';
import '../matesApp_app/mates_massage.dart';

const IconData videoON= Icons.videocam;
const IconData videoOFF= Icons.videocam_off;

const IconData micON= Icons.mic;
const IconData micOFF= Icons.mic_off;

const IconData volumeON= Icons.volume_up_rounded;
const IconData volumeOFF= Icons.volume_off;



class CallScreen extends StatefulWidget {
  final String number;
  final String? person;

  const CallScreen({Key? key, required this.number, this.person}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  late String callPerson;


  DataDepo db = DataDepo();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _animation = StepTween(begin: 0, end: 3).animate(_animationController);

    _animationController.repeat();

    Timer(const Duration(seconds: 15), () {
      Navigator.pop(context);
    });

    Timer(const Duration(seconds: 5), () {
      db.recents.add(
        MatesMessage(
          person: widget.number,
          number: widget.number,
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.person != null && widget.person!.isNotEmpty) {
      callPerson = widget.person!;
    } else {
      callPerson = widget.number;
    }



    return Container(
      decoration: BoxDecoration(color: Colors.green.shade200),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  callPerson,
                  style: const TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 10,),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    String callingText = 'Calling.';
                    for (int i = 0; i < _animation.value; i++) {
                      callingText += '.';
                    }
                    return Text(
                      callingText,
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.none,
                        fontSize: 23.0,
                      ),
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                RoundIconButton(myIcon: videoON),
                RoundIconButton(myIcon: micON),
                RoundIconButton(myIcon: volumeON),
              ],
            ),
            RoundIconButton(
              myIcon: Icons.call_end,
              iconColor: Colors.red,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
