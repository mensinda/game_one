import 'dart:math';
import 'dart:ui';

import 'package:flame/animation.dart';
import 'package:game_one/game/components/animation.dart';
import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/sprite.dart';
import 'package:game_one/model.dart';

class GameRow extends MetaComp {
  final Random rand;

  final DataModel model;

  GameRow({this.rand, this.model});

  void generate({double top, int leftB, int rightB}) {
    this.y = top;

    // Generate the background tiles
    for (int i = 0; i < model.game.numTiles; i++) {
      int tileIDX = rand.nextInt(4);
      GameSprite sp = GameSprite.square(1, 'ground-$tileIDX.png');
      add(sp);

      sp.x = i * tileSize;
      sp.y = 0;
      sp.compPriority = 0;
    }

    // Generate the border
    for (int i = 0; i < model.game.numTiles; i++) {
      if (leftB == i) {
        int tileIDX = rand.nextInt(3);
        _generateBoder('wall-$tileIDX-L.png', i, 0);
      }

      if (rightB == i) {
        int tileIDX = rand.nextInt(3);
        _generateBoder('wall-$tileIDX-R.png', i, 0.5 * tileSize);
      }
    }

    // Generate the hit box
    hitBox = Rect.fromLTWH(0, this.y, size.height, tileSize);
  }

  void _generateBoder(String sprite, int tile, double offset) {
    Animation ani = Animation.variableSequenced(
      sprite,
      11,
      <double>[
        rand.nextDouble() * model.animation.wallPause, // 1
        model.animation.wallSpeed,                     // 2
        model.animation.wallSpeed,                     // 3
        model.animation.wallSpeed,                     // 4
        model.animation.wallSpeed,                     // 5
        model.animation.wallSpeed,                     // 6
        model.animation.wallSpeed,                     // 7
        model.animation.wallSpeed,                     // 8
        model.animation.wallSpeed,                     // 9
        model.animation.wallSpeed,                     // 10
        model.animation.wallPause,                     // 11
      ],
      textureHeight: 128,
      textureWidth:  64,
    );

    GameAnimation border = GameAnimation.rectangle(0.5, 1, ani);
    add(border);

    border.x            = tile * tileSize + offset;
    border.y            = 0;
    border.compPriority = 5;
    border.hitBox       = Rect.fromLTWH(border.x, this.y, border.width, border.height);
  }

  @override
  void update(double t) {
    super.update(t);

    double deltaY = t * (speed ?? 0);
    y            += deltaY;
    hitBox        = hitBox.translate(0, deltaY);

    components.forEach((comp) => comp.hitBox = comp.hitBox?.translate(0, deltaY));
  }

  @override
  bool destroy() {
    return y > size.height;
  }
}

