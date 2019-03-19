import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:meta/meta.dart';

import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/animation.dart';

class Player extends MetaComp {
  double relPosY;
  double animationSpeed;

  Animation runningAnimation;

  Player({@required this.relPosY, @required this.animationSpeed}) {
    runningAnimation = Animation.sequenced(
      'flame.png',
      5,
      textureWidth: 128,
      textureHeight: 128,
      stepTime: animationSpeed
    );

    add(GameAnimation.square(1, runningAnimation));

    hitBoxColor = Color(0xffffff00);
  }

  void die() {
    components.clear();
  }

  set posX(double x) {
    this.x      = x - this.width / 2;
    double hw   = (tileSize ?? 16) / 2;
    this.hitBox = Rect.fromLTWH(this.x + hw / 2, this.y + hw / 2, hw, hw);
  }

  @override
  void resize(Size s) {
    super.resize(s);
    this.y = s.height / relPosY;
  }

  @override
  void update(double t) {
    super.update(t);
  }

  @override
  int priority() => 10;
}

