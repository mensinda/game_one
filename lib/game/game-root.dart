import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components/component.dart';

import 'package:flutter/gestures.dart';

import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/comparing.dart';

import 'package:game_one/model.dart';
import 'package:game_one/game/player.dart';

class GameRoot extends Game {
  final DataModel model;
  final int numTilesWidth = 8;

  Size screenSize;
  double posX = 0 ;
  double tileSize = 50;

  Player player;

  OrderedSet<Component> components = OrderedSet(Comparing.on((c) => c.priority()));

  GameRoot({@required this.model});

  void init() async {
    resize(await Flame.util.initialDimensions());

    Flame.util.addGestureRecognizer(_createDragRecognizer());
    Flame.util.addGestureRecognizer(_createTapRecognizer());

    await Flame.images.loadAll(<String>[
      'flame-1.png',
      'flame-2.png',
      'flame-3.png',
      'flame-4.png',
      'flame-5.png',
    ]);

    player = Player(relPosY: 1.3);
    player.setTileSize(tileSize);
    player.resize(screenSize);
    components.add(player);

    print('INITIALIZED GAME');
    model.setLoaded();
  }

  GestureRecognizer _createDragRecognizer() {
    PanGestureRecognizer pan = new PanGestureRecognizer();
    pan.onDown   = (DragDownDetails position)   => this.handleDrag(position.globalPosition);
    pan.onUpdate = (DragUpdateDetails position) => this.handleDrag(position.globalPosition);
    return pan;
  }

  TapGestureRecognizer _createTapRecognizer() {
    TapGestureRecognizer tapper = new TapGestureRecognizer();
    tapper.onTapUp = (TapUpDetails details) => this.handleTap(details);
    return tapper;
  }

  void reset() {
    posX = screenSize.width / 2;
    print('RESET GAME');
  }

  void handleDrag(Offset position) {
    posX = position.dx;
  }

  void handleTap(TapUpDetails details) {
  }

  @override
  void render(Canvas canvas) {
    // Paint a black background
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff000000);
    canvas.drawRect(bgRect, bgPaint);

    canvas.save();
    components.forEach((comp) => comp.render(canvas));
    canvas.restore();
  }

  @override
  void update(double t) {
    player.posX = posX;
    components.forEach((c) => c.update(t));
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / numTilesWidth;
    components.forEach((c) => c.resize(size));
    player?.setTileSize(tileSize);
    super.resize(size);
  }
}
