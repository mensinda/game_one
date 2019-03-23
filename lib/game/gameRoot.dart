import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/text_config.dart';

import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/comparing.dart';

import 'package:game_one/main.dart';
import 'package:game_one/model.dart';
import 'package:game_one/game/player.dart';
import 'package:game_one/game/rowGenerator.dart';
import 'package:game_one/game/you-died.dart';
import 'package:game_one/game/tabToStart.dart';
import 'package:game_one/game/paused.dart';
import 'package:game_one/game/settings.dart';
import 'package:game_one/game/obstacles.dart';
import 'package:game_one/game/components/text.dart';
import 'package:game_one/game/components/base.dart';

typedef void GameIsInit();

class GameRoot extends Game {
  final DataModel model;

  Random rand;
  Size screenSize;
  double posX = 0 ;
  double tileSize = 50;
  double gameSpeed = 0;
  bool hasLost = false;

  Player       player;
  RowGenerator rows;
  YouDied      deathScreen;
  TabToStart   tabToStart;
  Paused       pausedText;
  GameText     rowDebugText;
  GameSettings settings;

  GameIsInit onInit = () {};

  OrderedSet<BaseComp> components = OrderedSet(Comparing.on((c) => c.priority()));

  GameRoot({@required this.model});

  void init() async {
    navigatorKey.currentState.pushNamed('/loading');
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
      'wall-0-U.png',
      'wall-1-U.png',
      'wall-2-U.png',
      'wall-0-D.png',
      'wall-1-D.png',
      'wall-2-D.png',
      'edge-BL.png',
      'edge-BR.png',
      'edge-TL.png',
      'edge-TR.png',
      'block-0.png',
      'block-1.png',
      'block-2.png',
      'block-3.png',
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
      'start.png',
      'pause.png',
      'cogwheel.png',
    ]);

    model.setLoaded();
    reset();
    print('GAME: INITIALIZED');

    onInit();
  }

  void reset() {
    if (!model.hasLoaded) {
      return;
    }

    posX        = screenSize.width / 2;
    gameSpeed   = model.game.gameSpeed;
    hasLost     = false;
    deathScreen = null;
    tabToStart  = null;
    settings    = null;
    player      = null;
    rows        = null;

    resize(screenSize);

    // Remove all components
    components.clear();
    if (model.game.debugText) {
      rowDebugText = GameText('<N/A>');
      add(rowDebugText);
      rowDebugText.compPriority = 100;
      rowDebugText.config = TextConfig(fontSize: 12, color: Color(0xFFFFFFFF));
    } else {
      rowDebugText = null;
    }

    // Re-add components
    player     = Player(model: model);
    tabToStart = TabToStart(model: this.model);
    settings   = GameSettings();
    rows       = RowGenerator(model: this.model, rand: this.rand, player: player);

    add(tabToStart);
    add(player);
    add(settings);
    add(rows);

    // Configure components
    player.posX = posX;

    print('GAME: RESET');
  }

  @override
  void render(Canvas canvas) {
    if (!model.hasLoaded) {
      return;
    }

    canvas.save();
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();

    if (model.game.renderHitBox) {
      components.forEach((comp) => comp.renderHitBox(canvas));
    }

    if (model.game.drawLines) {
      canvas.restore();
      canvas.restore();
      _renderObstacleLines(canvas);
    }
  }

  void _renderObstacleLines(Canvas canvas) {
    ObstacleInfo obs = rows.currentObstacle;
    if (obs == null) {
      return;
    }

    Paint paint = Paint();
    paint.color = Color(0xff00ffff);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.25;

    List<Path> paths = <Path>[];

    if (obs.left != null) {
      Path p = Path();
      p.moveTo(player.toRect().center.dx, player.toRect().center.dy);
      p.lineTo(obs.left, obs.posY);
      paths.add(p);
    }

    if (obs.right != null) {
      Path p = Path();
      p.moveTo(player.toRect().center.dx, player.toRect().center.dy);
      p.lineTo(obs.right, obs.posY);
      paths.add(p);
    }

    if (obs.middle != null) {
      Path p = Path();
      p.moveTo(player.toRect().center.dx, player.toRect().center.dy);
      p.lineTo(obs.middle, obs.posY);
      paths.add(p);
    }

    for (Path i in paths) {
      canvas.drawPath(i, paint);
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
    c.updateSpeed(this.gameSpeed);
    c.onAdded();
  }

  void add(BaseComp c) {
    preAdd(c);
    components.add(c);
  }

  @override
  void update(double t) {
    if (!model.hasLoaded) {
      return;
    }

    if (hasLost || !tabToStart.hasStarted || (pausedText?.isPaused ?? false)) {
      _updatePaused(t);
    } else {
      _updateRunning(t);
    }
  }

  void _updateRunning(double t) {
    player.posX     = posX;
    this.gameSpeed += t * model.game.gameSpeedup;
    components.forEach((c) => c.updateSpeed(this.gameSpeed));
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());

    bool wasHit = components.map((comp) => comp.intersect(player)).reduce((val, comp) => val || comp);
    rowDebugText?.text = 'Comp: ${components.length}; Rows: ${rows.components.length}; Speed: ${gameSpeed.round()}; HIT: $wasHit';

    if (model.game.renderHitBox) {
      player.hitBoxColor = wasHit ? Color(0xffffffff) : Color(0xffffff00);
    }

    if (wasHit && !model.game.immortal) {
      print('GAME: DIE DIE DIE');
      player.hitBoxColor = Color(0xffffffff);
      hasLost = true;

      player.die();
      deathScreen = YouDied(model: this.model);
      add(deathScreen);
    }
  }

  void _updatePaused(double t) {
    player?.update(t);
    deathScreen?.update(t);
    tabToStart?.update(t);
    pausedText?.update(t);
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

  void pause() {
    if ((pausedText?.isPaused ?? false) || !tabToStart.hasStarted) {
      print('GAME: ALREADY PAUSED');
      return;
    }

    pausedText = Paused(model: this.model);
    add(pausedText);
    print('GAME: PAUSED');
  }

  void handleTap(Offset position) {
    if (settings.handleTab(position)) {
      reset();
      return;
    }

    if (deathScreen?.canRestart ?? false) {
      print('GAME: RESTARTING');
      reset();
    }

    if (!tabToStart.hasStarted) {
      print('GAME: STARTING');
      tabToStart.hasStarted = true;
    }

    if (pausedText?.isPaused ?? false) {
      print('GAME: CONTINUE');
      pausedText.isPaused = false;
    }
  }
}
