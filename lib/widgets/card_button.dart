import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String title;
  final Widget image;
  final Function action;

  CardButton({required this.title, required this.image, required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[50],
      elevation: 5,
      child: InkWell(
        onTap: () {
          action();
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Align(alignment: Alignment.centerLeft, child: image)),
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
