import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:game_one/game/components/base.dart';

class GameAnimation extends BaseComp {
  Animation animation;

  GameAnimation();

  GameAnimation.square(int ts,                    this.animation) : super(xTiles: ts, yTiles: ts);
  GameAnimation.rectangle(int xTiles, int yTiles, this.animation) : super(xTiles: xTiles, yTiles: yTiles);

  @override
  bool loaded() => animation?.loaded() ?? false;

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    animation.getSprite().render(canvas, width, height);
  }

  @override
  void update(double t) {
    animation.update(t);
  }
}

