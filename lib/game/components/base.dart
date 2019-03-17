import 'dart:ui';

import 'package:flame/components/component.dart';

abstract class BaseComp extends PositionComponent {
  double xTiles;
  double yTiles;
  int compPriority = 0;
  double speed = 0;

  Size size;
  double tileSize;

  BaseComp({this.xTiles = 1, this.yTiles = 1});

  void updateTileSize(double ts) {
    this.tileSize = ts;
    this.width  = xTiles * ts;
    this.height = yTiles * ts;
  }

  void updateSpeed(double s) {
    speed = s;
  }

  @override
  void resize(Size s) {
    size = s;
    super.resize(s);
  }

  @override
  int priority() => compPriority;
}

