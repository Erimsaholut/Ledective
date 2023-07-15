import 'package:flutter/material.dart';


class sizedRow extends StatelessWidget {
  const sizedRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const[
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
