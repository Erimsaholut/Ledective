import 'package:flutter/material.dart';
import 'package:ledective/apps/contacts_app/contactPage.dart';
import '../phone_app/call_screen.dart';
import 'chat_page.dart';

class MatesMessage extends StatelessWidget {
  final VoidCallback? onLongPressed;
  final VoidCallback? onPressed;
  final Color? backGroundColor;
  final Color? iconColor;
  final String? surname;
  final String message;
  final String number;
  final String person;
  final IconData icon;
  const MatesMessage({
    this.backGroundColor = Colors.teal,
    this.icon = Icons.person,
    required this.person,
    this.onLongPressed,
    this.message = "",
    this.number = "",
    this.iconColor = Colors.black,
    this.onPressed,
    this.surname,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MatesChatPAGE(person: person),
              ),
            );
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
                          child: Text(
                            person,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
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
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Tap to talk",
                            style: TextStyle(
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
        ),const SizedBox(height: 30,)
      ],
    );
  }
}
