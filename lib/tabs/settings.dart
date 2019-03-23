import 'package:flutter/material.dart';
import 'package:game_one/model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:card_settings/card_settings.dart';

class Settings extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: ScopedModelDescendant<DataModel>(
         builder: (context, child, model) => CardSettings.sectioned(
          children: <CardSettingsSection> [

            // Animations
            CardSettingsSection(
              header: CardSettingsHeader(label: 'Animation speed'),
              children: <Widget>[

                CardSettingsSlider(
                  label: 'Player',
                  initialValue: model.animation.playerSpeed,
                  min: 0.01,
                  max: 0.25,
                  onChangedEnd: (val) => model.animation.playerSpeed = val
                ),

                CardSettingsSlider(
                  label: 'Wall',
                  initialValue: model.animation.wallSpeed,
                  min: 0.01,
                  max: 0.25,
                  onChangedEnd: (val) => model.animation.wallSpeed = val
                ),

                CardSettingsSlider(
                  label: 'Wall animation pause',
                  initialValue: model.animation.wallPause,
                  min: 0.1,
                  max: 0.9,
                  onChangedEnd: (val) => model.animation.wallPause = val
                ),

                CardSettingsSlider(
                  label: 'Death screen speed',
                  initialValue: model.animation.deathScreen,
                  min: 0.01,
                  max: 0.25,
                  onChangedEnd: (val) => model.animation.deathScreen = val
                ),

                CardSettingsSlider(
                  label: 'Tab to restart blink speed',
                  initialValue: model.animation.tap2restart,
                  min: 0.3,
                  max: 1.9,
                  onChangedEnd: (val) => model.animation.tap2restart = val
                ),

              ]
            ),

            // Game settings
            CardSettingsSection(
              header: CardSettingsHeader(label: 'Game settings'),
              children: <Widget>[

                CardSettingsSlider(
                  label: 'Player height',
                  initialValue: model.game.playerRelPos,
                  min: 1.05,
                  max: 2.5,
                  onChangedEnd: (val) => model.game.playerRelPos = val,
                ),

                CardSettingsSlider(
                  label: 'Game speed',
                  initialValue: model.game.gameSpeed,
                  min: 5,
                  max: 500,
                  onChangedEnd: (val) => model.game.gameSpeed = val,
                ),

                CardSettingsSlider(
                  label: 'Max player speed',
                  initialValue: model.game.maxPlayerSpeed,
                  min: 5,
                  max: 500,
                  onChangedEnd: (val) => model.game.maxPlayerSpeed = val,
                ),

                CardSettingsInt(
                  label: 'Number of game tiles',
                  initialValue: model.game.numTiles,
                  onChanged: (val) => model.game.numTiles = val,
                ),

              ]
            ),

            // Generator settings
            CardSettingsSection(
              header: CardSettingsHeader(label: 'Generator'),
              children: <Widget>[

                CardSettingsInt(
                  label: 'Min Obstacle Gap',
                  initialValue: model.generator.minObstacleGap,
                  onChanged: (val) => model.generator.minObstacleGap = val,
                ),

                CardSettingsInt(
                  label: 'Max Obstacle Gap',
                  initialValue: model.generator.maxObstacleGap,
                  onChanged: (val) => model.generator.maxObstacleGap = val,
                ),



                CardSettingsInt(
                  label: 'Min Corridor Length',
                  initialValue: model.generator.minCorridorLength,
                  onChanged: (val) => model.generator.minCorridorLength = val,
                ),

                CardSettingsInt(
                  label: 'Max Corridor Length',
                  initialValue: model.generator.maxCorridorLength,
                  onChanged: (val) => model.generator.maxCorridorLength = val,
                ),

                CardSettingsInt(
                  label: 'Min Corridor Width',
                  initialValue: model.generator.minCorridorWidth,
                  onChanged: (val) => model.generator.minCorridorWidth = val,
                ),

                CardSettingsInt(
                  label: 'Max Corridor Width',
                  initialValue: model.generator.maxCorridorWidth,
                  onChanged: (val) => model.generator.maxCorridorWidth = val,
                ),



                CardSettingsInt(
                  label: 'Min Block Heigth',
                  initialValue: model.generator.minBlockHeight,
                  onChanged: (val) => model.generator.minBlockHeight = val,
                ),

                CardSettingsInt(
                  label: 'Max Block Height',
                  initialValue: model.generator.maxBlockHeight,
                  onChanged: (val) => model.generator.maxBlockHeight = val,
                ),

              ]
            ),

            // Debug settings
            CardSettingsSection(
              header: CardSettingsHeader(label: 'Debug settings'),
              children: <Widget>[

                CardSettingsSwitch(
                  label: 'Debug text',
                  initialValue: model.game.debugText,
                  onChanged: (val) => model.game.debugText = val,
                ),

                CardSettingsSwitch(
                  label: 'Render hit box',
                  initialValue: model.game.renderHitBox,
                  onChanged: (val) => model.game.renderHitBox = val,
                ),

                CardSettingsSwitch(
                  label: 'Immortal Player',
                  initialValue: model.game.immortal,
                  onChanged: (val) => model.game.immortal = val,
                ),

                CardSettingsSwitch(
                  label: 'Draw obstacle lines',
                  initialValue: model.game.drawLines,
                  onChanged: (val) => model.game.drawLines = val,
                ),

              ]
            ),

            // Save / reset
            CardSettingsSection(
              header: CardSettingsHeader(label: 'Actions'),
              children: <Widget>[
                CardSettingsButton(
                  label: 'Save',
                  onPressed: () {
                    model.save();
                  },
                  backgroundColor: Colors.greenAccent,
                  textColor: Colors.black,
                ),

                CardSettingsButton(
                  label: 'Reset',
                  onPressed: () async {
                    model.reset();
                    Navigator.popAndPushNamed(context, '/settings');
                  },
                  isDestructive: true,
                  backgroundColor: Colors.redAccent,
                  textColor: Colors.white,
                ),
              ]
            )

          ]
        )
      ),
    );
  }
}

