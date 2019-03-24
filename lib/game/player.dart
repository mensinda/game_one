import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:meta/meta.dart';

import 'package:game_one/model.dart';
import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/animation.dart';

class Player extends MetaComp {
  final DataModel model;

  double _destPosX;
  double _posX;

  Animation runningAnimation;

  Player({@required this.model}) {
    runningAnimation = Animation.sequenced(
      'flame.png',
      4,
      textureWidth: 128,
      textureHeight: 128,
      stepTime: model.animation.playerSpeed
    );

    add(GameAnimation.square(1, runningAnimation));

    hitBoxColor = Color(0xffffff00);
  }

  void die() {
    components.clear();
    runningAnimation = Animation.sequenced(
      'explosion.png',
      11,
      textureWidth: 256,
      textureHeight: 256,
      stepTime: model.animation.explSpeed
    );
    runningAnimation.loop = false;

    add(GameAnimation.square(2, runningAnimation));
  }

  set posX(double x) => this._destPosX = x;

  @override
  void resize(Size s) {
    super.resize(s);
    this.y = s.height / model.game.playerRelPos;

    this._destPosX = s.width / 2;
    this._posX     = this._destPosX;
  }

  @override
  void update(double t) {
    super.update(t);

    double maxDeltaX = t * model.game.maxPlayerSpeed;
    if (this._posX < this._destPosX) {
      if ((this._destPosX - this._posX) > maxDeltaX) {
        this._posX += maxDeltaX;
      } else {
        this._posX = this._destPosX;
      }
    } else if (this._posX > this._destPosX) {
      if ((this._posX - this._destPosX) > maxDeltaX) {
        this._posX -= maxDeltaX;
      } else {
        this._posX = this._destPosX;
      }
    }

    this.x      = this._posX - this.width / 2;
    double hw   = (tileSize ?? 16) / 1.75;
    double ofs  = (this.width  / 2 - hw / 2);
    this.hitBox = Rect.fromLTWH(this.x + ofs, this.y + ofs * 0.25, hw, hw);
  }

  @override
  int priority() => 10;
}

