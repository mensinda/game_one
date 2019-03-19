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

                CardSettingsInt(
                  label: 'Number of game tiles',
                  initialValue: model.game.numTiles,
                  onChanged: (val) => model.game.numTiles = val,
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

