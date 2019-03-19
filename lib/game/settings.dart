import 'dart:ui';

import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/sprite.dart';
import 'package:game_one/main.dart';

class GameSettings extends MetaComp {
  GameSprite settingsCog;
  Rect bg;
  Paint bgPaint;

  double paddingMult;

  GameSettings({this.paddingMult = 0.25}) {
    settingsCog = GameSprite.square(.5, 'cogwheel.png');

    bgPaint       = Paint();
    bgPaint.color = Color(0xaa000000);

    add(settingsCog);
  }

  bool handleTab(Offset position) {
    if (!toRect().contains(position)) {
      return false;
    }

    print('GAME: ==> SETTINGS');
    navigatorKey.currentState.pushNamed('/settings');
    return true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(bg, bgPaint);
    super.render(canvas);
  }

  @override
  void updateTileSize(double ts) {
    super.updateTileSize(ts);

    double padding = tileSize * paddingMult;
    settingsCog.x = padding / 2;
    settingsCog.y = padding / 2;

    x      = 0;
    y      = 0;
    width  = settingsCog.width + padding;
    height = settingsCog.width + padding;

    bg = Rect.fromLTWH(x, y, width, height);
  }

  @override
  int priority() => 25;
}