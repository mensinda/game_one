import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';

import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/comparing.dart';
import 'package:vector_math/vector_math.dart';

import 'package:game_one/main.dart';
import 'package:game_one/bluetooth.dart';
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
  final GameBluetooth bleModel;

  Random rand;
  Size screenSize;
  double posX = 0 ;
  double tileSize = 50;
  double gameSpeed = 0;
  double darkenAlpha = 0;
  bool hasLost = false;

  Player       player;
  RowGenerator rows;
  YouDied      deathScreen;
  TabToStart   tabToStart;
  Paused       pausedText;
  GameText     rowDebugText;
  GameText     rowDebugText2;
  GameSettings settings;

  GameIsInit onInit = () {};

  OrderedSet<BaseComp> components = OrderedSet(Comparing.on((c) => c.priority()));

  GameRoot({@required this.model, @required this.bleModel});

  void init() async {
    navigatorKey.currentState.pushNamed('/loading');
    resize(await Flame.util.initialDimensions());

    rand = Random();

    await Flame.images.loadAll(<String>[
      'flame.png',
      'explosion.png',
      'ground.png',
      'wall-L.png',
      'wall-R.png',
      'wall-U.png',
      'wall-D.png',
      'edge-BL.png',
      'edge-BR.png',
      'edge-TL.png',
      'edge-TR.png',
      'corner-BL.png',
      'corner-BR.png',
      'corner-TL.png',
      'corner-TR.png',
      'block.png',
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

    List<GameBluetoothDev> devList = await bleModel.scan();
    for (GameBluetoothDev i in devList) {
      if (i.name.contains('TECO Wearable')) {
        await bleModel.connect(i);
        break;
      }
    }

    model.setLoaded();
    reset();
    print('GAME: INITIALIZED');

    onInit();
  }

  void reset() {
    if (!model.hasLoaded) {
      return;
    }

    if ((bleModel.conDev?.isConnected ?? false) == true) {
      bleModel.conDev.motors = [bleModel.conDev.startupMotorVal, bleModel.conDev.startupMotorVal, bleModel.conDev.startupMotorVal, bleModel.conDev.startupMotorVal];
      model.save();
    }

    posX        = screenSize.width / 2;
    gameSpeed   = model.game.gameSpeed;
    darkenAlpha = 0;
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
      rowDebugText  = GameText('<N/A>');
      rowDebugText2 = GameText('<N/A>');
      add(rowDebugText);
      add(rowDebugText2);
      rowDebugText.compPriority  = 100;
      rowDebugText2.compPriority = 100;
      rowDebugText.config  = TextConfig(fontSize: 12, color: Color(0xFFFFFFFF));
      rowDebugText2.config = TextConfig(fontSize: 12, color: Color(0xFFFFFFFF));
      rowDebugText2.y = rowDebugText.height * 1.25;
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

    if (model.game.darkenScreen && !(hasLost || !tabToStart.hasStarted || (pausedText?.isPaused ?? false))) {
      Rect  fullscreen = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
      Color blackAlpha = Color.fromARGB((darkenAlpha * 255).round(), 0, 0, 0);
      Paint tempPaint  = Paint();
      tempPaint.color  = blackAlpha;
      tempPaint.style  = PaintingStyle.fill;
      canvas.drawRect(fullscreen, tempPaint);
    }

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
      _updateWareable();
    }
  }

  void _updateRunning(double t) {
    player.posX     = posX;
    this.gameSpeed += t * model.game.gameSpeedup;
    components.forEach((c) => c.updateSpeed(this.gameSpeed));
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());

    darkenAlpha += t * model.game.darkenFactor;
    darkenAlpha =  min(0.95, darkenAlpha);

    bool wasHit = components.map((comp) => comp.intersect(player)).reduce((val, comp) => val || comp);
    rowDebugText?.text = 'Comp: ${components.length}; Rows: ${rows.components.length}; Speed: ${gameSpeed.round()}; Dark: ${(darkenAlpha * 100).round()}%; HIT: $wasHit';

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

  void _updateWareable() {
    ObstacleInfo obs = rows.currentObstacle;
    Rect         ply = player.toRect();

    if (obs?.middle == null) {
      return;
    }

    Vector2 dir = Vector2(obs.middle - ply.center.dx, ply.center.dy - obs.posY);
    double dist = dir.length;
    dir.scale(1 / dist);

    double up    = dir.dot(Vector2(0,  1));
    double left  = dir.dot(Vector2(-1, 0));
    double right = dir.dot(Vector2(1,  0));

    bleModel.conDev?.frontRel = up;
    bleModel.conDev?.leftRel  = - (obs.middle - ply.center.dx) / (screenSize.width * 0.33);
    bleModel.conDev?.rightRel =   (obs.middle - ply.center.dx) / (screenSize.width * 0.33);
    bleModel.conDev?.backRel  = obs.left != null ? 1 : 0;

    rowDebugText2?.text = 'LN: ${dist.floor()}; L: ${(left * 100).round()}; R: ${(right * 100).round()}; U: ${(up * 100).round()}';
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
