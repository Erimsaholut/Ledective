import 'package:flutter/material.dart';


class sizedRow extends StatelessWidget {
  const sizedRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 110,
          width: 110,
        ),
        SizedBox(
          height: 110,
          width: 110,
        ),
        SizedBox(
          height: 110,
          width: 110,
        ),
      ],
    );
  }
}
