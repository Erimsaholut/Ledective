import 'package:flutter/material.dart';

import '../phone_app/call_screen.dart';
import 'contactPage.dart';

class ContactWidget extends StatelessWidget {
  final String number;
  final String person;
  final Color backGroundColor;
  final IconData icon;
  final Color? iconColor;

  const ContactWidget({super.key,
    required this.number,
    required this.person,
    this.icon = Icons.person,
    this.iconColor = Colors.black,
    this.backGroundColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactsPage(name: person, number: number),
            ),
          );
        },
        onLongPress: () {
          if (number.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CallScreen(number: number, person: person),
              ),
            );
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 3.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: backGroundColor,
                        child: Icon(
                          icon,
                          size: 50,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Colors.black,
                          width: 3.0,
                        ),
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 3.0,
                        ),
                        right: BorderSide(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          person,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20)
    ]);
  }
}
