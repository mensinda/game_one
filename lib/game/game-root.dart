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
import 'package:game_one/game/components/base.dart';

class GameRoot extends Game {
  final DataModel model;
  final int numTilesWidth = 8;

  Size screenSize;
  double posX = 0 ;
  double tileSize = 50;

  Player player;

  OrderedSet<BaseComp> components = OrderedSet(Comparing.on((c) => c.priority()));

  GameRoot({@required this.model});

  void init() async {
    resize(await Flame.util.initialDimensions());

    Flame.util.addGestureRecognizer(_createDragRecognizer());
    Flame.util.addGestureRecognizer(_createTapRecognizer());

    await Flame.images.loadAll(<String>[
      'flame.png',
      'flame-1.png',
      'flame-2.png',
      'flame-3.png',
      'flame-4.png',
      'flame-5.png',
      'ground-1.png',
      'ground-2.png',
      'ground-3.png',
      'ground-4.png',
    ]);

    print('INITIALIZED GAME');
    model.setLoaded();
  }

  void reset() {
    posX = screenSize.width / 2;

    // Remove all components
    components.clear();

    // Re-add components
    player = Player(
      relPosY: model.game.playerRelPos,
      animationSpeed: model.animation.playerSpeed
    );

    add(player);

    print('GAME RESET');
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
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, Component c) {
    if (!c.loaded()) {
      return;
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @mustCallSuper
  void preAdd(BaseComp c) {
    // first time resize
    if (screenSize != null) {
      c.resize(screenSize);
    }
    if (tileSize != null) {
      c.updateTileSize(tileSize);
    }
  }

  void add(BaseComp c) {
    preAdd(c);
    components.add(c);
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
    components.forEach((c) => c.updateTileSize(tileSize));
    super.resize(size);
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
}
