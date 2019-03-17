import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:game_one/game/components/base.dart';

class GameSprite extends BaseComp {
  Sprite sprite;

  GameSprite();

  GameSprite.square(int ts, String imagePath)                    : this.rectangle(ts, ts, imagePath);
  GameSprite.rectangle(int xTiles, int yTiles, String imagePath) : this.fromSprite(xTiles, yTiles, new Sprite(imagePath));
  GameSprite.fromSprite(int xTiles, int yTiles, this.sprite)     : super(xTiles: xTiles, yTiles: yTiles);

  @override
  render(Canvas canvas) {
    prepareCanvas(canvas);
    sprite.render(canvas, width, height);
  }

  @override
  bool loaded() {
    return sprite != null && sprite.loaded() && x != null && y != null;
  }

  @override
  void update(double t) {}
}

