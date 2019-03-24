import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/animation.dart';
import 'package:game_one/game/components/animation.dart';
import 'package:game_one/game/components/meta.dart';
import 'package:game_one/game/components/sprite.dart';
import 'package:game_one/model.dart';

enum TileType {
  borderL,
  borderR,
  borderU,
  borderD,
  edgeBL,
  edgeBR,
  edgeTL,
  edgeTR,
  cornerBL,
  cornerBR,
  cornerTL,
  cornerTR,
  block,
  empty
}

class TileCfg {
  String d;
  double w;
  double h;
  double o;

  double tileSize;

  TileCfg({this.d, this.w, this.h, this.o});

  String get sprite  => 'wall-$d.png';
  double get width   => this.w * 32 * 4;
  double get height  => this.h * 32 * 4;
  double get offsetX => this.w < 1.0 ? this.o * tileSize : 0.0;
  double get offsetY => this.h < 1.0 ? this.o * tileSize : 0.0;
}

class GameRow extends MetaComp {
  final Random rand;

  final DataModel model;

  GameRow({this.rand, this.model});

  void generate({@required double top, @required List<TileType> tiles}) {
    this.y = top;

    // Generate the background tiles
    for (int i = 0; i < model.game.numTiles; i++) {
      GameSprite sp = GameSprite.square(1, 'ground.png');
      add(sp);

      sp.x = i * tileSize;
      sp.y = 0;
      sp.compPriority = 0;
    }

    // Generate the forground tiles
    addElements(tiles: tiles, offset: 0.0);

    // Generate the hit box
    hitBox = Rect.fromLTWH(0, this.y, screenSize.height, tileSize);
  }

  void addElements({List<TileType> tiles, double offset}) {
    for (int i = 0; i < tiles.length; i++) {
      TileType current = tiles[i];
      if (current == TileType.empty) {
        continue;
      }

      switch (current) {
        case TileType.block:   _generateBlock(i, offset); break;
        case TileType.borderL:
        case TileType.borderR:
        case TileType.borderU:
        case TileType.borderD: _generateBorder(current, i, offset); break;
        case TileType.edgeBL:
        case TileType.edgeBR:
        case TileType.edgeTL:
        case TileType.edgeTR: _generateEdge(current, i, offset); break;
        case TileType.cornerBL:
        case TileType.cornerBR:
        case TileType.cornerTL:
        case TileType.cornerTR: _generateCorner(current, i, offset); break;
        case TileType.empty:
        default: break;
      }
    }
  }

  void _generateBlock(int tileIdx, double offset) {
    GameSprite sp = GameSprite.square(1, 'block.png');
    add(sp);
    sp.x            = tileIdx * tileSize + offset;
    sp.y            = 0;
    sp.compPriority = 5;
    sp.hitBox       = Rect.fromLTWH(sp.x, this.y, sp.width, sp.height);
  }

  void _generateCorner(TileType current, int tileIdx, double offset) {
    String tile;
    double dx = 0;
    double dy = 0;
    switch (current) {
      case TileType.cornerBL: tile = 'corner-BL.png'; dy = 0;  dx = .5; break;
      case TileType.cornerBR: tile = 'corner-BR.png'; dy = 0;  dx = 0;  break;
      case TileType.cornerTL: tile = 'corner-TL.png'; dy = .5; dx = .5; break;
      case TileType.cornerTR: tile = 'corner-TR.png'; dy = .5; dx = 0;  break;
      default: return;
    }

    GameSprite sp = GameSprite.square(0.5, tile);
    add(sp);
    sp.x            = (tileIdx + dx) * tileSize + offset;
    sp.y            = dy * tileSize;
    sp.compPriority = 5;
    sp.hitBox       = Rect.fromLTWH(sp.x + .5 * dx * tileSize, this.y + sp.y + .5 * dy * tileSize, sp.width * .5, sp.height * .5);
  }

  void _generateBorder(TileType current, int tileIdx, double offset) {
    TileCfg tile;
    switch (current) {
      case TileType.borderL: tile = TileCfg(d: 'L', w: 0.5, h: 1.0, o: 0.0); break;
      case TileType.borderR: tile = TileCfg(d: 'R', w: 0.5, h: 1.0, o: 0.5); break;
      case TileType.borderU: tile = TileCfg(d: 'U', w: 1.0, h: 0.5, o: 0.5); break;
      case TileType.borderD: tile = TileCfg(d: 'D', w: 1.0, h: 0.5, o: 0.0); break;
      default: return;
    }

    tile.tileSize = this.tileSize;

    Animation ani = Animation.variableSequenced(
      tile.sprite,
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
      textureWidth:  tile.width,
      textureHeight: tile.height,
    );

    GameAnimation border = GameAnimation.rectangle(tile.w, tile.h, ani);
    add(border);

    border.x            = tile.offsetX + tileIdx * tileSize + offset;
    border.y            = tile.offsetY;
    border.compPriority = 5;
    border.hitBox       = Rect.fromLTWH(border.x, this.y + border.y, border.width, border.height);
  }

  void _generateEdge(TileType current, int tileIdx, double offset) {
    String tile;
    switch (current) {
      case TileType.edgeBL: tile = 'edge-BL.png'; break;
      case TileType.edgeBR: tile = 'edge-BR.png'; break;
      case TileType.edgeTL: tile = 'edge-TL.png'; break;
      case TileType.edgeTR: tile = 'edge-TR.png'; break;
      default: return;
    }

    Animation ani = Animation.variableSequenced(
      tile,
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
      textureWidth:  128,
      textureHeight: 128,
    );

    GameAnimation edge = GameAnimation.square(1, ani);
    add(edge);

    edge.x            = tileIdx * tileSize + offset;
    edge.y            = 0;
    edge.compPriority = 5;
    edge.hitBox       = Rect.fromLTWH(edge.x, this.y, edge.width, edge.height);
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
  bool destroy() => y > screenSize.height;
}

