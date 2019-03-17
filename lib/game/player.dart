import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:meta/meta.dart';

import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/animation.dart';

class Player extends MetaComp {
  double relPosY;
  double animationSpeed;

  Player({@required this.relPosY, @required this.animationSpeed}) {
    add(
      GameAnimation.square(
        1,
        Animation.sequenced(
          'flame.png',
          5,
          textureWidth: 128,
          textureHeight: 128,
          stepTime: animationSpeed
        )
      )
    );
  }

  set posX(double x) => this.x = x - this.width / 2;

  @override
  void resize(Size s) {
    super.resize(s);
    this.y = s.height / relPosY;
  }
}

