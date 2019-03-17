import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimationData {
  static const String PREFIX = 'animation/';

  double playerSpeed;
  double wallSpeed;
  double wallPause;

  AnimationData() { reset(); }

  void load(SharedPreferences prefs) async {
    playerSpeed = prefs.getDouble( PREFIX + 'playerSpeed' ) ?? playerSpeed;
    wallSpeed   = prefs.getDouble( PREFIX + 'wallSpeed'   ) ?? wallSpeed;
    wallPause   = prefs.getDouble( PREFIX + 'wallPause'   ) ?? wallPause;
  }

  void save(SharedPreferences prefs) async {
    await prefs.setDouble( PREFIX + 'playerSpeed', playerSpeed );
    await prefs.setDouble( PREFIX + 'wallSpeed',   wallSpeed );
    await prefs.setDouble( PREFIX + 'wallPause',   wallPause );
  }

  void reset() {
    playerSpeed = 0.05;
    wallSpeed   = 0.1;
    wallPause   = 0.5;
  }
}

class GameSettings {
  static const String PREFIX = 'game/';

  double playerRelPos;
  double gameSpeed;
  int    numTiles;
  bool   debugText;

  GameSettings() { reset(); }

  void load(SharedPreferences prefs) async {
    playerRelPos = prefs.getDouble( PREFIX + 'playerRelPos' ) ?? playerRelPos;
    gameSpeed    = prefs.getDouble( PREFIX + 'gameSpeed'    ) ?? gameSpeed;
    numTiles     = prefs.getInt(    PREFIX + 'numTiles'     ) ?? numTiles;
    debugText    = prefs.getBool(   PREFIX + 'debugText'    ) ?? debugText;
  }

  void save(SharedPreferences prefs) async {
    await prefs.setDouble( PREFIX + 'playerRelPos', playerRelPos );
    await prefs.setDouble( PREFIX + 'gameSpeed',    gameSpeed    );
    await prefs.setInt(    PREFIX + 'numTiles',     numTiles     );
    await prefs.setBool(   PREFIX + 'debugText',    debugText    );
  }

  void reset() {
    playerRelPos = 1.3;
    gameSpeed    = 200;
    numTiles     = 6;
    debugText    = false;
  }
}

class DataModel extends Model {
  bool _hasLoaded = false;

  final AnimationData _animationData = AnimationData();
  final GameSettings  _gameSettings  = GameSettings();

  bool          get hasLoaded => _hasLoaded;
  AnimationData get animation => _animationData;
  GameSettings  get game      => _gameSettings;

  void setLoaded() {
    _hasLoaded = true;
    notifyListeners();
  }

  void load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _animationData.load(prefs);
    _gameSettings.load(prefs);

    print('MODEL LOADED');
    notifyListeners();
  }

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _animationData.save(prefs);
    _gameSettings.save(prefs);

    print('MODEL SAVED');
    notifyListeners();
  }

  void reset() {
    _animationData.reset();
    _gameSettings.reset();

    print('MODEL RESET');
    notifyListeners();
  }

  void updated() => notifyListeners();
}

