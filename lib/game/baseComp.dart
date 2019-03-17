import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';

import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

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

class GameSprite extends BaseComp {
  Sprite sprite;

  GameSprite();

  GameSprite.square(int ts, String imagePath)                    : this.rectangle(ts, ts, imagePath);
  GameSprite.rectangle(int xTiles, int yTiles, String imagePath) : this.fromSprite(xTiles, yTiles, new Sprite(imagePath));
  GameSprite.fromSprite(int xTiles, int yTiles, this.sprite)     : super(xTiles: xTiles, yTiles: yTiles);

  @override
  render(Canvas canvas) {
    prepareCanvas(canvas);
    sprite.render(canvas, width, height);
  }

  @override
  bool loaded() {
    return sprite != null && sprite.loaded() && x != null && y != null;
  }

  @override
  void update(double t) {}
}

class MetaComp extends BaseComp {
  OrderedSet<BaseComp> components = OrderedSet(Comparing.on((c) => c.priority()));
  Size size;

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    canvas.save();
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, Component c) {
    if (!c.loaded()) {
      return;
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @mustCallSuper
  void preAdd(BaseComp c) {
    // first time resize
    if (size != null) {
      c.resize(size);
    }
    if (tileSize != null) {
      c.updateTileSize(tileSize);
    }
  }

  void add(BaseComp c) {
    preAdd(c);
    components.add(c);
  }

  @override
  bool loaded() {
    if (x == null || y == null) {
      return false;
    }

    return components.map((comp) => comp.loaded()).reduce((val, comp) => val && comp);
  }

  @override
  void update(double t) {
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
  }

  @override
  void updateTileSize(double ts) {
    super.updateTileSize(ts);
    components.forEach((comp) => comp.updateTileSize(ts));
  }

  @override
  void resize(Size s) {
    super.resize(s);
    components.forEach((comp) => comp.resize(s));
  }
}

