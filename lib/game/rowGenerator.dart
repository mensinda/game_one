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

  RowGenerator({@required this.model, @required this.rand});

  GameRow nextRow() {
    double  nextY = (lastRow?.y ?? screenSize.height) - tileSize;
    GameRow row   = GameRow(rand: rand, model: model);
    add(row);

    row.generate(
      top:    nextY,
      leftB:  0,
      rightB: model.game.numTiles - 1,
    );

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