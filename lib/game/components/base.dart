import 'dart:ui';

import 'package:flame/components/component.dart';

abstract class BaseComp extends PositionComponent {
  double xTiles;
  double yTiles;
  int compPriority = 0;
  double speed = 0;

  Size size;
  double tileSize;

  Rect  hitBox;
  Color hitBoxColor    = Color(0xff00ff00);
  Color hitBoxHitColor = Color(0xffff0000);
  bool  lastWasHit     = false;

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

  void renderHitBox(Canvas canvas) {
    if (hitBox == null) {
      return;
    }

    Path  path        = Path();
    Paint paint       = Paint();
    paint.color       = lastWasHit ? hitBoxHitColor : hitBoxColor;
    paint.style       = PaintingStyle.stroke;
    paint.strokeWidth = lastWasHit ? 5.0 : 1.0;

    path.addRect(hitBox);
    canvas.drawPath(path, paint);
  }

  bool intersect(BaseComp comp) {
    if (comp == this || hitBox == null || comp.hitBox == null) {
      return false;
    }

    return lastWasHit = hitBox.overlaps(comp.hitBox);
  }
}

