import 'package:flutter/material.dart';


class PhotoWidget extends StatelessWidget {
  final double scale;
  final String adress;
  const PhotoWidget({Key? key,this.scale=1.5,required this.adress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(adress,scale: scale)
      ],
    );
  }
}

