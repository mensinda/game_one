import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:game_one/game/components/base.dart';

class GameFillRect extends BaseComp {
  Rect  rect;

  Color _color;
  Paint _paint;
  bool  _fullscreen;

  GameFillRect({@required this.rect, @required Color color}) {
    _fullscreen  = false;
    _color       = color;
    _paint       = Paint();
    _paint.color = color;
  }

  GameFillRect.fullscreen({@required Color color}) {
    _fullscreen  = true;
    _color       = color;
    _paint       = Paint();
    _paint.color = color;
  }

  @override
  void resize(Size s) {
    super.resize(s);
    if (_fullscreen) {
      rect =Rect.fromLTWH(0, 0, s.width, s.height);
    }
  }

  @override
  bool loaded() => rect != null;

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    canvas.drawRect(rect, _paint);
  }

  @override
  void update(double t) {}

  Color get color => _color;
  set color(Color c) {
    _color       = c;
    _paint.color = color;
  }
}