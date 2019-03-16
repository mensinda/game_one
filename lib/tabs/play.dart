import 'package:flutter/material.dart';

class Play extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            // The play button
            IconButton(
              icon: Icon(Icons.play_circle_filled),
              tooltip: 'Launch the game',
              iconSize: 200.0,
              color: Colors.red,
              onPressed: () {
                print('Starting the game...');
              }
            ),

            // Text
            Text(
              'Start the game',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )

          ],
        ),
      ),
    );
  }
}

