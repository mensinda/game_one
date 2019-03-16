import 'package:flutter/material.dart';
import 'package:game_one/model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Play extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: ScopedModelDescendant<DataModel>(
            builder: (context, child, model) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: model.hasLoaded ? _buildDefault(context) : _buildLoading(context),
            ),
        ),
      ),
    );
  }

  List<Widget> _buildDefault(BuildContext context) {
    return <Widget>[
      // The play button
      IconButton(
        icon: Icon(Icons.play_circle_filled),
        tooltip: 'Launch the game',
        iconSize: 200.0,
        color: Colors.red,
        onPressed: () {
          Navigator.pushNamed(context, '/game');
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
    ];
  }

  List<Widget> _buildLoading(BuildContext context) {
    return <Widget> [
      SpinKitFadingGrid (
        color: Colors.black87,
        size: 200.0,
        duration: Duration(milliseconds: 750),
        shape: BoxShape.rectangle,
      ),

      SizedBox(height: 25),

      Text(
        'Loading...',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      )
    ];
  }
}

