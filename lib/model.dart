import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimationDataModel {
  static const String PREFIX = 'animation/';

  double playerSpeed;
  double explSpeed;
  double wallSpeed;
  double wallPause;
  double deathScreen;
  double tap2restart;

  AnimationDataModel() { reset(); }

  void load(SharedPreferences prefs) async {
    playerSpeed = prefs.getDouble( PREFIX + 'playerSpeed' ) ?? playerSpeed;
    explSpeed   = prefs.getDouble( PREFIX + 'explSpeed'   ) ?? explSpeed;
    wallSpeed   = prefs.getDouble( PREFIX + 'wallSpeed'   ) ?? wallSpeed;
    wallPause   = prefs.getDouble( PREFIX + 'wallPause'   ) ?? wallPause;
    deathScreen = prefs.getDouble( PREFIX + 'deathScreen' ) ?? deathScreen;
    tap2restart = prefs.getDouble( PREFIX + 'tap2restart' ) ?? tap2restart;
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setDouble( PREFIX + 'playerSpeed', playerSpeed );
    await prefs.setDouble( PREFIX + 'explSpeed',   explSpeed );
    await prefs.setDouble( PREFIX + 'wallSpeed',   wallSpeed );
    await prefs.setDouble( PREFIX + 'wallPause',   wallPause );
    await prefs.setDouble( PREFIX + 'deathScreen', deathScreen );
    await prefs.setDouble( PREFIX + 'tap2restart', tap2restart );
  }

  void reset() {
    playerSpeed = 0.100;
    explSpeed   = 0.075;
    wallSpeed   = 0.050;
    wallPause   = 0.400;
    deathScreen = 0.090;
    tap2restart = 1.000;
  }
}

class GameSettingsModel {
  static const String PREFIX = 'game/';

  double playerRelPos;
  double gameSpeed;
  double gameSpeedup;
  double maxPlayerSpeed;
  int    numTiles;
  double darkenFactor;
  bool   darkenScreen;
  bool   debugText;
  bool   renderHitBox;
  bool   immortal;
  bool   drawLines;

  GameSettingsModel() { reset(); }

  void load(SharedPreferences prefs) {
    playerRelPos   = prefs.getDouble( PREFIX + 'playerRelPos'   ) ?? playerRelPos;
    gameSpeed      = prefs.getDouble( PREFIX + 'gameSpeed'      ) ?? gameSpeed;
    gameSpeedup    = prefs.getDouble( PREFIX + 'gameSpeedup'    ) ?? gameSpeedup;
    maxPlayerSpeed = prefs.getDouble( PREFIX + 'maxPlayerSpeed' ) ?? maxPlayerSpeed;
    numTiles       = prefs.getInt(    PREFIX + 'numTiles'       ) ?? numTiles;
    darkenFactor   = prefs.getDouble( PREFIX + 'darkenFactor'   ) ?? darkenFactor;
    darkenScreen   = prefs.getBool(   PREFIX + 'darkenScreen'   ) ?? darkenScreen;
    debugText      = prefs.getBool(   PREFIX + 'debugText'      ) ?? debugText;
    renderHitBox   = prefs.getBool(   PREFIX + 'renderHitBox'   ) ?? renderHitBox;
    immortal       = prefs.getBool(   PREFIX + 'immortal'       ) ?? immortal;
    drawLines      = prefs.getBool(   PREFIX + 'drawLines'      ) ?? drawLines;
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setDouble( PREFIX + 'playerRelPos',   playerRelPos   );
    await prefs.setDouble( PREFIX + 'gameSpeed',      gameSpeed      );
    await prefs.setDouble( PREFIX + 'gameSpeedup',    gameSpeedup    );
    await prefs.setDouble( PREFIX + 'maxPlayerSpeed', maxPlayerSpeed );
    await prefs.setInt(    PREFIX + 'numTiles',       numTiles       );
    await prefs.setDouble( PREFIX + 'darkenFactor',   darkenFactor   );
    await prefs.setBool(   PREFIX + 'darkenScreen',   darkenScreen   );
    await prefs.setBool(   PREFIX + 'debugText',      debugText      );
    await prefs.setBool(   PREFIX + 'renderHitBox',   renderHitBox   );
    await prefs.setBool(   PREFIX + 'immortal',       immortal       );
    await prefs.setBool(   PREFIX + 'drawLines',      drawLines      );
  }

  void reset() {
    playerRelPos   = 1.3;
    gameSpeed      = 200;
    gameSpeedup    = 2;
    maxPlayerSpeed = 300;
    numTiles       = 6;
    darkenFactor   = 0.005;
    darkenScreen   = true;
    debugText      = false;
    renderHitBox   = false;
    immortal       = false;
    drawLines      = false;
  }
}

class GeneratorModel {
  static const String PREFIX = 'generator/';

  int minObstacleGap;
  int maxObstacleGap;

  int minCorridorLength;
  int maxCorridorLength;
  int minCorridorWidth;
  int maxCorridorWidth;

  int minBlockHeight;
  int maxBlockHeight;
  int minBlockWidth;
  int maxBlockWidth;

  GeneratorModel() { reset(); }

  void load(SharedPreferences prefs) {
    minObstacleGap    = prefs.getInt( PREFIX + 'minObstacleGap'    ) ?? minObstacleGap;
    maxObstacleGap    = prefs.getInt( PREFIX + 'maxObstacleGap'    ) ?? maxObstacleGap;

    minCorridorLength = prefs.getInt( PREFIX + 'minCorridorLength' ) ?? minCorridorLength;
    maxCorridorLength = prefs.getInt( PREFIX + 'maxCorridorLength' ) ?? maxCorridorLength;
    minCorridorWidth  = prefs.getInt( PREFIX + 'minCorridorWidth'  ) ?? minCorridorWidth;
    maxCorridorWidth  = prefs.getInt( PREFIX + 'maxCorridorWidth'  ) ?? maxCorridorWidth;

    minBlockHeight    = prefs.getInt( PREFIX + 'minBlockHeight'    ) ?? minBlockHeight;
    maxBlockHeight    = prefs.getInt( PREFIX + 'maxBlockHeight'    ) ?? maxBlockHeight;
    minBlockWidth     = prefs.getInt( PREFIX + 'minBlockWidth'     ) ?? minBlockWidth;
    maxBlockWidth     = prefs.getInt( PREFIX + 'maxBlockWidth'     ) ?? maxBlockWidth;
  }

  Future<void> save(SharedPreferences prefs) async {
    await prefs.setInt( PREFIX + 'minObstacleGap',    minObstacleGap    );
    await prefs.setInt( PREFIX + 'maxObstacleGap',    maxObstacleGap    );

    await prefs.setInt( PREFIX + 'minCorridorLength', minCorridorLength );
    await prefs.setInt( PREFIX + 'maxCorridorLength', maxCorridorLength );
    await prefs.setInt( PREFIX + 'minCorridorWidth',  minCorridorWidth  );
    await prefs.setInt( PREFIX + 'maxCorridorWidth',  maxCorridorWidth  );

    await prefs.setInt( PREFIX + 'minBlockHeight',    minBlockHeight    );
    await prefs.setInt( PREFIX + 'maxBlockHeight',    maxBlockHeight    );
    await prefs.setInt( PREFIX + 'minBlockWidth',     minBlockWidth     );
    await prefs.setInt( PREFIX + 'maxBlockWidth',     maxBlockWidth     );
  }

  void reset() {
    minObstacleGap    = 4;
    maxObstacleGap    = 7;

    minCorridorLength = 4;
    maxCorridorLength = 7;
    minCorridorWidth  = 2;
    maxCorridorWidth  = 3;

    minBlockHeight = 1;
    maxBlockHeight = 2;
  }
}

class DataModel extends Model {
  bool _hasLoaded = false;

  final AnimationDataModel _animationData = AnimationDataModel();
  final GameSettingsModel  _gameSettings  = GameSettingsModel();
  final GeneratorModel     _gnererator    = GeneratorModel();

  bool               get hasLoaded => _hasLoaded;
  AnimationDataModel get animation => _animationData;
  GameSettingsModel  get game      => _gameSettings;
  GeneratorModel     get generator => _gnererator;

  void setLoaded() {
    _hasLoaded = true;
    notifyListeners();
  }

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _animationData.load(prefs);
    _gameSettings.load(prefs);
    _gnererator.load(prefs);

    print('MODEL: LOADED');
    notifyListeners();
  }

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await _animationData.save(prefs);
    await _gameSettings.save(prefs);
    await _gnererator.save(prefs);

    print('MODEL: SAVED');
    notifyListeners();
  }

  void reset() {
    _animationData.reset();
    _gameSettings.reset();

    print('MODEL: RESET');
    notifyListeners();
  }

  void updated() => notifyListeners();
}

