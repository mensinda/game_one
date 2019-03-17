import 'dart:ui';

import 'package:flame/components/component.dart';

abstract class BaseComp extends PositionComponent {
  int xTiles;
  int yTiles;

  Size size;
  double tileSize;

  BaseComp({this.xTiles = 1, this.yTiles = 1});

  void updateTileSize(double ts) {
    this.tileSize = ts;
    this.width  = xTiles * ts;
    this.height = yTiles * ts;
  }

  @override
  void resize(Size s) {
    size = s;
    super.resize(s);
  }
}

