import 'package:flutter/cupertino.dart';

class IncomingMessage extends StatefulWidget {
  final String message;
  final int delaySec;

  const IncomingMessage({
    Key? key,
    required this.message,
    this.delaySec = 0,
  }) : super(key: key);

  @override
  _IncomingMessageState createState() => _IncomingMessageState();
}


class _IncomingMessageState extends State<IncomingMessage> {
  late Duration delayDuration;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    delayDuration = Duration(seconds: widget.delaySec);
    _startTimer();
  }

  void _startTimer() {
    if (delayDuration == Duration.zero) {
      _setVisible(true);
    } else {
      Future.delayed(delayDuration, () {
        _setVisible(true);
      });
    }
  }

  void _setVisible(bool visible) {
    setState(() {
      _isVisible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minHeight = 60.0;
        final maxHeight = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isVisible)
              Padding(
                padding: const EdgeInsets.only(right: 80),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.message,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
