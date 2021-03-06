import 'package:flame/util.dart';
import 'package:flame/flame.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:game_one/model.dart';
import 'package:game_one/bluetooth.dart';
import 'package:game_one/game/gameRoot.dart';
import 'package:game_one/tabs/settings.dart';
import 'package:game_one/tabs/bluetooth.dart';
import 'package:game_one/tabs/device.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() async {
  Flame.audio.disableLog();

  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);

  DataModel     model    = DataModel();
  GameBluetooth bleModel = GameBluetooth();
  GameRoot game = GameRoot(model: model, bleModel: bleModel);
  runApp(AppRoot(game: game, model: model, bleModel: bleModel));

  model.load();
  game.init();
}

class AppRoot extends StatelessWidget {
  final GameRoot      game;
  final DataModel     model;
  final GameBluetooth bleModel;
  AppRoot({this.game, this.model, this.bleModel});

  @override
  Widget build(BuildContext context) => ScopedModel<DataModel>(
    model: model,
    child: ScopedModel<GameBluetooth>(
      model: bleModel,
      child: _buildApp()
    )
  );

  Widget _buildApp() {
    return MaterialApp(
      title: 'game_one',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/loading':   (BuildContext context) => LoadingScreen(game: game),
        '/settings':  (BuildContext context) => HomeScreen(title: 'Game One'),
        '/':          (BuildContext context) => GameWrapper(game: game),
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
    return GestureDetector(
      onTapUp:     (TapUpDetails ev)      => game.handleTap(ev.globalPosition),
      onDoubleTap: ()                     => game.pause(),
      onPanDown:   (DragDownDetails ev)   => game.handleDrag(ev.globalPosition),
      onPanUpdate: (DragUpdateDetails ev) => game.handleDrag(ev.globalPosition),

      behavior: HitTestBehavior.opaque,
      child:    game.widget,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final GameRoot game;

  LoadingScreen({@required this.game});

  @override
  Widget build(BuildContext context) {
    game.onInit = () => Navigator.pop(context);

    return Container(
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Loading...',
                textDirection: null,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
    controller    = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GameBluetooth>(
      builder: (context, child, model) =>
        Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: Colors.blue,

            // Set the bottom property of the Appbar to include a Tab Bar
            bottom: TabBar(
                  controller: controller,
                  tabs: <Tab>[
                    Tab(icon: Icon(Icons.settings)),
                    Tab(icon: model.bluetoothIcon),
                    Tab(icon: Icon(Icons.settings_ethernet)),
                  ],
                ),
            ),

          body: TabBarView(
            controller: controller,
            children: <Widget>[
              Settings(),
              Bluetooth(),
              DeviceSettings(),
            ]
          )
        )
    );
  }
}

