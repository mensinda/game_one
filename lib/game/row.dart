import 'dart:math';

import 'package:flame/animation.dart';
import 'package:game_one/game/components/animation.dart';
import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/sprite.dart';
import 'package:game_one/model.dart';

class GameRow extends MetaComp {
  final int numTiles;
  final Random rand;

  final DataModel model;

  GameRow({this.numTiles, this.rand, this.model});

  void generate({int leftB, int rightB}) {
    // Generate the background tiles
    for (int i = 0; i < numTiles; i++) {
      int tileIDX = rand.nextInt(3) + 1;
      GameSprite sp = GameSprite.square(1, 'ground-$tileIDX.png');
      add(sp);

      sp.x = i * tileSize;
      sp.y = 0;
      sp.compPriority = 0;
    }

    // Generate the border
    for (int i = 0; i < numTiles; i++) {
      if (leftB == i) {
        int tileIDX = rand.nextInt(2) + 1;
        _generateBoder('wall-$tileIDX-L.png', i);
      }

      if (rightB == i) {
        int tileIDX = rand.nextInt(2) + 1;
        _generateBoder('wall-$tileIDX-R.png', i);
      }
    }
  }

  void _generateBoder(String sprite, int tile) {
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

    GameAnimation border = GameAnimation.square(1, ani);
    add(border);

    border.x            = tile * tileSize;
    border.y            = 0;
    border.compPriority = 5;
  }

  @override
  void update(double t) {
    super.update(t);

    y += t * (speed ?? 0);
  }

  @override
  bool destroy() {
    return y > size.height;
  }
}

