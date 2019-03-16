import 'package:flame/components/component.dart';

abstract class BaseComp extends PositionComponent {
  int xTiles;
  int yTiles;

  BaseComp({this.xTiles = 1, this.yTiles = 1});

  void updateTileSize(double ts) {
    this.width  = xTiles * ts;
    this.height = yTiles * ts;
  }
}
