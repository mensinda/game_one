import 'dart:ui';
import 'package:meta/meta.dart';

import 'package:flame/animation.dart';
import 'package:game_one/game/components/animation.dart';
import 'package:game_one/game/components/fillRect.dart';
import 'package:game_one/game/components/meta.dart';
import 'package:game_one/model.dart';

class Paused extends MetaComp {
  final DataModel model;
  bool isPaused = true;

  Paused({@required this.model});

  @override
  void onAdded() {
    GameAnimation text = GameAnimation.rectangle(
      4.0,
      0.5,
      Animation.sequenced(
        'pause.png',
        2,
        textureHeight: 64,
        textureWidth:  512,
        stepTime:      model.animation.tap2restart,
      )
    );

    add(GameFillRect.fullscreen(color: Color(0x88000000)));
    add(text);

    text.x = screenSize.width  / 2 - text.width  / 2;
    text.y = screenSize.height / 2 - text.height / 2;
  }

  @override
  bool destroy() => !isPaused;

  @override
  int priority() => 50;
}

