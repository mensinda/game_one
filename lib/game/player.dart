import 'dart:ui';

import 'package:meta/meta.dart';

import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/sprite.dart';

class Player extends MetaComp {
  double relPosY;

  Player({@required this.relPosY}) {
    add(GameSprite.square(1, 'flame-1.png'));
  }

  set posX(double x) => this.x = x - this.width / 2;

  @override
  void resize(Size s) {
    super.resize(s);
    this.y = s.height / relPosY;
  }
}

