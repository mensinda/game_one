import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:game_one/model.dart';
import 'package:game_one/game/row.dart';
import 'package:game_one/game/components/meta.dart';

class RowGenerator extends MetaComp {
  final Random    rand;
  final DataModel model;
  GameRow lastRow;

  RowGenerator({@required this.model, @required this.rand}) {
    hitBoxHitColor = Color(0x00000000); // Make the hit box transparent
  }

  GameRow nextRow() {
    double  nextY = (lastRow?.y ?? screenSize.height) - tileSize;
    GameRow row   = GameRow(rand: rand, model: model);
    add(row);

    int leftBorderAt  = 1;
    int rightBorderAt = model.game.numTiles - 1;

    List<TileType> tiles = <TileType>[];

    // Generate tile list
    for (int i = 0; i < model.game.numTiles; i++) {
      TileType newTile = TileType.empty;
      if (i <  leftBorderAt)  { newTile = TileType.block; }
      if (i == leftBorderAt)  { newTile = TileType.borderL; }
      if (i == rightBorderAt) { newTile = TileType.borderR; }
      if (i >  rightBorderAt) { newTile = TileType.block; }

      tiles.add(newTile);
    }

    row.generate(top: nextY, tiles: tiles);
    return row;
  }

  @override
  void onAdded() {
    while ((lastRow?.y ?? 100) > -1) {
      lastRow = nextRow();
    }
  }

  @override
  void update(double t) {
    super.update(t);
    while ((lastRow?.y ?? 100) > -1) {
      lastRow = nextRow();
    }
  }

  @override
  void resize(Size s) {
    super.resize(s);
    hitBox = Rect.fromLTRB(0, 0, screenSize.width, screenSize.height);
  }
}