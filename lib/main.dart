import 'package:flame/util.dart';
import 'package:flame/flame.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:game_one/model.dart';
import 'package:game_one/game/game-root.dart';
import 'package:game_one/tabs/play.dart';
import 'package:game_one/tabs/settings.dart';
import 'package:game_one/tabs/bluetooth.dart';

void main() async {
  Flame.audio.disableLog();

  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);

  DataModel model = DataModel();
  GameRoot game = GameRoot(model: model);
  runApp(AppRoot(game: game, model: model));

  game.init();
}

class AppRoot extends StatelessWidget {
  final GameRoot game;
  final DataModel model;
  AppRoot({this.game, this.model});

  @override
  Widget build(BuildContext context) => ScopedModel<DataModel>(model: model, child: _buildApp());

  Widget _buildApp() {
    return MaterialApp(
      title: 'game_one',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/':     (BuildContext context) => HomeScreen(title: 'Game One'),
        '/game': (BuildContext context) => GameWrapper(game: game),
      },
    );
  }
}

class GameWrapper extends StatelessWidget {
  final GameRoot game;
  GameWrapper({Key key, @required this.game}) : super(key: key) {
    game.reset();
  }

  @override
  Widget build(BuildContext context) {
    return game.widget;
  }
}

class HomeScreen extends StatefulWidget {
  final String title;
  HomeScreen({this.title});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,

        // Set the bottom property of the Appbar to include a Tab Bar
        bottom: TabBar(
          controller: controller,
          tabs: <Tab>[
            Tab(icon: Icon(Icons.videogame_asset)),
            Tab(icon: Icon(Icons.settings)),
            Tab(icon: Icon(Icons.settings_bluetooth)),
          ],
        ),
      ),

      body: TabBarView(
        controller: controller,
        children: <Widget>[
          Play(),
          Settings(),
          Bluetooth()
        ]
      )
    );
  }
}

