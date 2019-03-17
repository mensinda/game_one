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
                )

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
                    Navigator.pushNamed(context, '/');
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

class Settingssss extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ScopedModelDescendant<DataModel>(
          builder: (context, child, model) {
            return Form(
              key: _formKey,
              child: CardSettings.sectioned(
                children: <CardSettingsSection> [],
              ),
            );
          },
          /*builder: (context, child, model) => ListView(
            children: <Widget>[
              SizedBox(height: 25),
              _buildHeading(context, 'Animations'),

              CupertinoSettings(
                items: <Widget>[
                  CSHeader('Animations'),
                  CSWidget(
                    CupertinoSlider(
                      label: 'Player animation speed = ${(100 * model.animation.playerSpeed).round() / 100}',
                      value: model.animation.playerSpeed,
                      min: 0.01,
                      max: 1.0,
                      onChanged: (val) => model.animation.playerSpeed = val,
                      divisions: 1000,
                    ),
                  ),
                ],
              ),

              Card(
                child:
              ),

              Divider(),

              _buildButtons(context, model),
            ],
          ),*/
        ),
      ),
    );
  }

  Widget _buildHeading(BuildContext context, String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildButtons(BuildContext context, DataModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text('Reset'),
            onPressed: () {
              model.reset();
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text('Save'),
            onPressed: () {
              model.save();
            },
          ),
        ),
      ],
    );
  }
}

