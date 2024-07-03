import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final String name;
  final String value;

  Field({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(name),
        Text(value),
      ],
    );
  }
}
