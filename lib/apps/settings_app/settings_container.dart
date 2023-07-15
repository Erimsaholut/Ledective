import 'package:flutter/material.dart';

class SettingsContainer extends StatelessWidget {
  final String name;
  final Color? iconColor;
  final Color? backGroundColor;
  final VoidCallback? onLongPressed;
  final VoidCallback? onPressed;

  const SettingsContainer({
    Key? key,
    required this.name,
    this.iconColor,
    this.backGroundColor,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      child: Column(
        children: [
          TextButton(
            onPressed: onPressed,
            onLongPress: onLongPressed,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              padding: MaterialStateProperty.all(EdgeInsets.zero),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 3.0,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: TextButton(
                          onPressed: (){
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => CallScreen(number: _phoneNumber),
                              //   ),
                              // );
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                              Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                name,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
