import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final String desc;
  LoadingIndicator({required this.desc});
  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        SizedBox(
          height: 5.0,
        ),
        Text(
          widget.desc,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
