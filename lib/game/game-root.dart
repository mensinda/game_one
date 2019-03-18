import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/text_config.dart';

import 'package:flutter/gestures.dart';

import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/comparing.dart';

import 'package:game_one/model.dart';
import 'package:game_one/game/player.dart';
import 'package:game_one/game/row.dart';
import 'package:game_one/game/you-died.dart';
import 'package:game_one/game/components/text.dart';
import 'package:game_one/game/components/base.dart';

class GameRoot extends Game {
  final DataModel model;

  Random rand;
  Size screenSize;
  double posX = 0 ;
  double tileSize = 50;
  int rowsAdded = 0;
  bool hasLost = false;

  Player player;
  GameRow lastRow;
  YouDied deathScreen;

  GameText rowDebugText;

  OrderedSet<BaseComp> components = OrderedSet(Comparing.on((c) => c.priority()));

  GameRoot({@required this.model});

  void init() async {
    resize(await Flame.util.initialDimensions());

    rand = Random();

    await Flame.images.loadAll(<String>[
      'flame.png',
      'ground-0.png',
      'ground-1.png',
      'ground-2.png',
      'ground-3.png',
      'wall-0-L.png',
      'wall-1-L.png',
      'wall-2-L.png',
      'wall-0-R.png',
      'wall-1-R.png',
      'wall-2-R.png',
      'death-screen-10.png',
      'death-screen-20.png',
      'death-screen-30.png',
      'death-screen-40.png',
      'death-screen-50.png',
      'death-screen-60.png',
      'death-screen-70.png',
      'death-screen-80.png',
      'death-screen-90.png',
      'death-screen-100.png',
      'restart.png',
    ]);

    print('INITIALIZED GAME');
    model.setLoaded();
  }

  void reset() {
    posX = screenSize.width / 2;
    rowsAdded = 0;
    hasLost = false;
    deathScreen = null;

    resize(screenSize);

    // Remove all components
    components.clear();
    lastRow = null;
    if (model.game.debugText) {
      rowDebugText = GameText('<N/A>');
      add(rowDebugText);
      rowDebugText.compPriority = 50;
      rowDebugText.config = TextConfig(fontSize: 12, color: Color(0xFFFFFFFF));
      print('Enabling debug text');
    } else {
      rowDebugText = null;
    }

    // Re-add components
    player = Player(
      relPosY: model.game.playerRelPos,
      animationSpeed: model.animation.playerSpeed
    );

    add(player);
    fillRows();

    print('GAME RESET');
  }

  GameRow newRow(double nextY) {
    GameRow row = GameRow(rand: rand, model: model);
    add(row);

    row.generate(
      top:    nextY,
      leftB:  0,
      rightB: model.game.numTiles - 1,
    );

    return row;
  }

  void fillRows() {
    while ((lastRow?.y ?? 100) > -1) {
      lastRow = newRow((lastRow?.y ?? screenSize.height) - tileSize);
      rowsAdded++;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();

    if (model.game.renderHitBox) {
      components.forEach((comp) => comp.renderHitBox(canvas));
    }
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, BaseComp c) {
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
    c.updateSpeed(model.game.gameSpeed);
  }

  void add(BaseComp c) {
    preAdd(c);
    components.add(c);
  }

  @override
  void update(double t) {
    if (hasLost) {
      _updateLost(t);
    } else {
      _updateRunning(t);
    }
  }

  void _updateRunning(double t) {
    player.posX = posX;
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
    fillRows();

    bool wasHit = components.map((comp) => comp.intersect(player)).reduce((val, comp) => val || comp);
    rowDebugText?.text = 'Comp: ${components.length}; Rows: $rowsAdded; HIT: $wasHit';

    if (wasHit) {
      print('You are dead!');
      player.hitBoxColor = Color(0xffffffff);
      hasLost = true;

      player.die();
      deathScreen = YouDied(model: this.model);
      add(deathScreen);
      deathScreen.init();
    }
  }

  void _updateLost(double t) {
    player.update(t);
    deathScreen.update(t);
  }

  @override
  void resize(Size size) {
    screenSize = size;
    tileSize = screenSize.width / model.game.numTiles;
    components.forEach((c) => c.resize(size));
    components.forEach((c) => c.updateTileSize(tileSize));
    super.resize(size);
  }


  // Input handlers
  void handleDrag(Offset position) {
    posX = position.dx;
  }

  void handleTap(Offset position) {
    if (deathScreen?.canRestart ?? false) {
      reset();
    }
  }
}
