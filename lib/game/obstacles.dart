import 'dart:math';

import 'package:game_one/game/row.dart';
import 'package:game_one/model.dart';

class DataHelper {
  final Random    rand;
  final DataModel model;
  double          tileSize;

  DataHelper(this.rand, this.model, this.tileSize);

  int random(int min, int max) => rand.nextInt(max - min + 1) + min;

  int get width    => model.game.numTiles;
  int get leftIDX  => 0;
  int get rightIDX => model.game.numTiles - 1;

  GeneratorModel get gen => model.generator;
}

class ObstacleInfo {
  double middle;
  double left;
  double right;

  double posY;

  ObstacleInfo({this.left, this.right, this.middle});
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

  double get offset           => 0.0;
  bool   get hasVariableLayer => false;

  ObstacleInfo get obstacleInfo;

  int            _computeLength();
  List<TileType> _nextRowImp(List<TileType> tiles);

  List<TileType> nextRow() {
    List<TileType> tiles;
    tiles = List<TileType>.filled(data.width, TileType.empty);
    tiles = _nextRowImp(tiles);
    return tiles;
  }

  List<TileType> nextVariableLayer() => <TileType>[];

  void finishedRow() => length--;
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

  @override
  ObstacleInfo get obstacleInfo => null;
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

  @override
  ObstacleInfo get obstacleInfo {
    double left  = (this.leftIDX + 0.5) * data.tileSize;
    double right = (this.rightIDX + 0.5) * data.tileSize;
    return ObstacleInfo(left: left, right: right, middle: (left + right) / 2);
  }
}

class SpikeWall extends Obstacle {
  double pos;

  SpikeWall(DataHelper d) : super(d) {
    this.pos = data.rand.nextDouble() * (data.width - 3) * data.tileSize + data.tileSize * 1.5;
  }

  @override
  int _computeLength() => data.random(data.gen.minBlockHeight, data.gen.maxBlockHeight) + 1;

  @override
  List<TileType> _nextRowImp(List<TileType> tiles) {
    tiles[data.leftIDX]  = TileType.borderL;
    tiles[data.rightIDX] = TileType.borderR;
    return tiles;
  }

  @override
  List<TileType> nextVariableLayer() {
    if (this.isFirst) {
      return <TileType>[TileType.empty, TileType.borderD, TileType.empty];
    }

    if (this.isLast) {
      return <TileType>[TileType.empty, TileType.borderU, TileType.empty];
    }

    return <TileType>[TileType.borderR, TileType.block, TileType.borderL];
  }

  @override
  ObstacleInfo get obstacleInfo => ObstacleInfo(middle: this.pos);

  @override
  double get offset           => this.pos - data.tileSize * 1.5;

  @override
  bool   get hasVariableLayer => true;
}

