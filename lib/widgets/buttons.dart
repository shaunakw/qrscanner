import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FaBackButton extends StatelessWidget {
  const FaBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20.0),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
