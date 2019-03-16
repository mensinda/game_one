import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'package:flutter/gestures.dart';

import 'package:game_one/model.dart';

class GameRoot extends Game {
  final DataModel model;

  Size screenSize;
  double posX = 0 ;

  GameRoot({@required this.model});

  void init() async {
    resize(await Flame.util.initialDimensions());

    Flame.util.addGestureRecognizer(_createDragRecognizer());
    Flame.util.addGestureRecognizer(_createTapRecognizer());

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

    // Paint the box
    double screenCenterY = screenSize.height / 2;
    Rect boxRect = Rect.fromLTWH(
      posX - 75,
      screenCenterY - 75,
      150,
      150
    );
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xffffffff);
    canvas.drawRect(boxRect, boxPaint);
  }

  @override
  void update(double t) {
    // TODO
    return;
  }

  @override
  void resize(Size size) {
    screenSize = size;
    posX = screenSize.width / 2;
    super.resize(size);
  }
}
