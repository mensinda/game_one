import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

import 'package:game_one/game/baseComp.dart';

class Player extends SpriteComponent {
  double relPosY;

  Player({@required this.relPosY}) {
    this.sprite = Sprite('flame-1.png');
  }

  void setTileSize(double ts) {
    this.width = ts;
    this.height = ts;
  }

  set posX(double x) => this.x = x - this.width / 2;

  @override
  void resize(Size s) {
    this.y = s.height / relPosY;
  }
}

