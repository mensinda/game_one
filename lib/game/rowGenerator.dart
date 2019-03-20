import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:game_one/model.dart';
import 'package:game_one/game/row.dart';
import 'package:game_one/game/components/meta.dart';

class DataHelper {
  final Random    rand;
  final DataModel model;

  DataHelper(this.rand, this.model);

  int random(int min, int max) => rand.nextInt(max - min + 1) + min;

  int get width    => model.game.numTiles;
  int get leftIDX  => 0;
  int get rightIDX => model.game.numTiles - 1;

  GeneratorModel get gen => model.generator;
}

// =================
// === Obstacles ===
// =================

abstract class Obstacle {
  final DataHelper data;

  int length;
  int totalLength;

  Obstacle(this.data) {
    this.totalLength = this.length = _computeLength();
  }

  bool get isFinished => length <= 0;
  bool get isFirst    => length == totalLength;
  bool get isLast     => length == 1;

  int            _computeLength();
  List<TileType> _nextRowImp(List<TileType> tiles);

  List<TileType> nextRow() {
    List<TileType> tiles;
    tiles = List<TileType>.filled(data.width, TileType.empty);
    tiles = _nextRowImp(tiles);
    length--;
    return tiles;
  }
}

class WideCorridor extends Obstacle {
  WideCorridor(DataHelper d) : super(d);

  @override
  int _computeLength() => data.random(data.gen.minObstacleGap, data.gen.maxObstacleGap);

  @override
  List<TileType> _nextRowImp(List<TileType> tiles) {
    tiles[data.leftIDX]  = TileType.borderL;
    tiles[data.rightIDX] = TileType.borderR;
    return tiles;
  }
}

class NarrowCorridor extends Obstacle {
  int leftIDX;
  int rightIDX;

  NarrowCorridor(DataHelper d) : super(d) {
    int width     = data.random(data.gen.minCorridorWidth, data.gen.maxCorridorWidth);
    int numBlocks = data.width - width - 1;
    int left      = data.random(0, numBlocks);
    int right     = numBlocks - left;

    this.leftIDX  = data.leftIDX + left;
    this.rightIDX = data.rightIDX - right;
  }

  @override
  int _computeLength() => data.random(data.gen.minCorridorLength, data.gen.maxCorridorLength);


  List<TileType> _nextRowImpCenter(List<TileType> tiles) {
    tiles.fillRange(0,             this.leftIDX, TileType.block);
    tiles.fillRange(this.rightIDX, data.width,   TileType.block);
    tiles[this.leftIDX]  = TileType.borderL;
    tiles[this.rightIDX] = TileType.borderR;
    return tiles;
  }

  List<TileType> _nextRowImpBorder(List<TileType> tiles, TileType tile) {
    tiles.fillRange(0,                 this.leftIDX, tile);
    tiles.fillRange(this.rightIDX + 1, data.width,   tile);

    if (this.leftIDX > data.leftIDX) {
      tiles[data.leftIDX] = this.isFirst ? TileType.edgeBR : TileType.edgeTR;
    } else {
      tiles[data.leftIDX] = TileType.borderL;
    }

    if (this.rightIDX < data.rightIDX) {
      tiles[data.rightIDX] = this.isFirst ? TileType.edgeBL : TileType.edgeTL;
    } else {
      tiles[data.rightIDX] = TileType.borderR;
    }

    return tiles;
  }

  @override
  List<TileType> _nextRowImp(List<TileType> tiles) {
    if (this.isFirst) {
      return _nextRowImpBorder(tiles, TileType.borderD);
    }

    if (this.isLast) {
      return _nextRowImpBorder(tiles, TileType.borderU);
    }

    return _nextRowImpCenter(tiles);
  }
}

class SpikeWall extends Obstacle {
  SpikeWall(DataHelper d) : super(d);

  @override
  int _computeLength() => data.random(data.gen.minBlockHeight, data.gen.maxBlockHeight);

  @override
  List<TileType> _nextRowImp(List<TileType> tiles) {
    tiles[0]              = TileType.borderU;
    tiles[data.width - 1] = TileType.borderD;
    return tiles;
  }
}

// ======================
// === Main Generator ===
// ======================

class RowGenerator extends MetaComp {
  final Random     rand;
  final DataModel  model;
  final DataHelper dataHelper;
  GameRow lastRow;

  List<Obstacle> obstacles = <Obstacle>[];

  RowGenerator({@required this.model, @required this.rand}) : dataHelper = DataHelper(rand, model) {
    hitBoxHitColor = Color(0x00000000); // Make the hit box transparent
  }

  void generateObstacle() {
    switch (rand.nextInt(2)) {
      case 0: obstacles.add(SpikeWall(dataHelper));      break;
      case 1: obstacles.add(NarrowCorridor(dataHelper)); break;
      default:
    }
    obstacles.add(WideCorridor(dataHelper));
  }

  Obstacle currentObstacle() {
    if (obstacles.isEmpty) {
      generateObstacle();
    }

    if (obstacles[0].isFinished) {
      obstacles.removeAt(0);
      return currentObstacle();
    }

    return obstacles[0];
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

    row.generate(top: nextY, tiles: currentObstacle().nextRow());
    return row;
  }

  @override
  void onAdded() {
    obstacles.add(WideCorridor(dataHelper));
    obstacles.add(WideCorridor(dataHelper));
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