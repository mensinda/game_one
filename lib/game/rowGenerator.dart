import 'dart:math';
import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:game_one/model.dart';
import 'package:game_one/game/row.dart';
import 'package:game_one/game/player.dart';
import 'package:game_one/game/obstacles.dart';
import 'package:game_one/game/components/meta.dart';

class RowGenerator extends MetaComp {
  final Random     rand;
  final DataModel  model;
  final DataHelper dataHelper;
  final Player     player;
  GameRow lastRow;

  List<Obstacle>     obstaclesRowGen = <Obstacle>[];
  List<ObstacleInfo> obstacles       = <ObstacleInfo>[];

  RowGenerator({@required this.model, @required this.rand, @required this.player}) : dataHelper = DataHelper(rand, model, 16) {
    hitBoxHitColor = Color(0x00000000); // Make the hit box transparent
  }

  void generateObstacle(double posY) {
    Obstacle obs;
    switch (rand.nextInt(3)) {
      case 0:
      case 1: obs = SpikeWall(dataHelper);      break;
      case 2: obs = NarrowCorridor(dataHelper); break;
      default:
    }
    obstaclesRowGen.add(obs);
    obstaclesRowGen.add(WideCorridor(dataHelper));

    ObstacleInfo obsInfo = obs.obstacleInfo;
    obsInfo.posY = posY + tileSize;
    obstacles.add(obsInfo);
  }

  Obstacle _currentObsRowGen(double posY) {
    if (obstaclesRowGen.isEmpty) {
      generateObstacle(posY);
    }

    if (obstaclesRowGen[0].isFinished) {
      obstaclesRowGen.removeAt(0);
      return _currentObsRowGen(posY);
    }

    return obstaclesRowGen[0];
  }

  ObstacleInfo get currentObstacle => obstacles.isEmpty ? null : obstacles[0];

  GameRow nextRow() {
    double  nextY = (lastRow?.y ?? screenSize.height) - tileSize;
    GameRow row   = GameRow(rand: rand, model: model);
    add(row);

    Obstacle obs = _currentObsRowGen(nextY);
    row.generate(top: nextY, tiles: obs.nextRow());
    if (obs.hasVariableLayer) {
      row.addElements(tiles: obs.nextVariableLayer(), offset: obs.offset);
    }

    obs.finishedRow();
    return row;
  }

  @override
  void onAdded() {
    dataHelper.tileSize = this.tileSize;
    obstaclesRowGen.add(WideCorridor(dataHelper));
    obstaclesRowGen.add(WideCorridor(dataHelper));
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

    double deltaY = t * (speed ?? 0);
    obstacles.forEach(     (obs) => obs.posY += deltaY                   );
    obstacles.removeWhere( (obs) => obs.posY > player.toRect().center.dy );
  }

  @override
  void updateTileSize(double ts) {
    super.updateTileSize(ts);
    dataHelper.tileSize = ts;
  }

  @override
  void resize(Size s) {
    super.resize(s);
    hitBox = Rect.fromLTRB(0, 0, screenSize.width, screenSize.height);
  }
}