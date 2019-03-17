import 'dart:math';

import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/sprite.dart';

class GameRow extends MetaComp {
  final int numTiles;
  final Random rand;

  GameRow({this.numTiles, this.rand});

  void generate() {
    // Generate the background tiles
    for (int i = 0; i < numTiles; i++) {
      int tileIDX = rand.nextInt(3) + 1;
      GameSprite sp = GameSprite.square(1, 'ground-$tileIDX.png');
      add(sp);

      sp.x = i * tileSize;
      sp.y = 0;
      sp.compPriority = 0;
    }
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

