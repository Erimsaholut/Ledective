import 'package:flutter/material.dart';

Color containerColor = Colors.black38;

class MailContainer extends StatefulWidget {
  final String title;
  final String message;

  const MailContainer({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  _MailContainerState createState() => _MailContainerState();
}

class _MailContainerState extends State<MailContainer> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String shortMessage = widget.message;


    String shortTitle =
    widget.title.length > 16 ? "${widget.title.substring(0, 12)}.com" : widget.title;

    return Container(

      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isExpanded ? null : 100,
              decoration: BoxDecoration(
                color: containerColor,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            shortTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isExpanded ? widget.message : shortMessage,
                            style: const TextStyle(fontSize: 25),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.transparent,
                        width: 10,
                        child: Scrollbar(
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: double.infinity),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
