import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/animation.dart';
import 'package:game_one/game/components/animation.dart';
import 'package:game_one/game/components/fillRect.dart';
import 'package:game_one/game/components/meta.dart';
import 'package:game_one/model.dart';

class TabToStart extends MetaComp {
  final DataModel model;
  bool hasStarted = false;

  TabToStart({@required this.model});

  @override
  void onAdded() {
    GameAnimation text = GameAnimation.rectangle(
      3.5,
      0.5,
      Animation.sequenced(
        'start.png',
        2,
        textureHeight: 64,
        textureWidth:  448,
        stepTime:      model.animation.tap2restart,
      )
    );

    add(GameFillRect.fullscreen(color: Color(0x88000000)));
    add(text);

    text.x = screenSize.width  / 2 - text.width  / 2;
    text.y = screenSize.height / 2 - text.height / 2;
  }

  @override
  bool destroy() => hasStarted;

  @override
  int priority() => 50;
}

