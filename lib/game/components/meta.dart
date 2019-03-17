import 'dart:ui';

import 'package:game_one/game/components/base.dart';
import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

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
  void renderComponent(Canvas canvas, BaseComp c) {
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

