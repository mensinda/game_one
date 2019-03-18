import 'package:flame/animation.dart';
import 'package:flame/sprite.dart';
import 'package:game_one/game/components/animation.dart';
import 'package:game_one/game/components/meta.dart';
import 'package:game_one/model.dart';

class YouDied extends MetaComp {
  GameAnimation sprite;
  GameAnimation restart;
  Animation     anim;
  DataModel     model;

  YouDied({this.model});

  void init() => _youDied();

  void _youDied() {
    Sprite s01 = Sprite('death-screen-10.png');
    Sprite s02 = Sprite('death-screen-20.png');
    Sprite s03 = Sprite('death-screen-30.png');
    Sprite s04 = Sprite('death-screen-40.png');
    Sprite s05 = Sprite('death-screen-50.png');
    Sprite s06 = Sprite('death-screen-60.png');
    Sprite s07 = Sprite('death-screen-70.png');
    Sprite s08 = Sprite('death-screen-80.png');
    Sprite s09 = Sprite('death-screen-90.png');
    Sprite s10 = Sprite('death-screen-100.png');

    List<Frame> frames = <Frame>[
      Frame(s01, model.animation.deathScreen),
      Frame(s02, model.animation.deathScreen),
      Frame(s03, model.animation.deathScreen),
      Frame(s04, model.animation.deathScreen),
      Frame(s05, model.animation.deathScreen),
      Frame(s06, model.animation.deathScreen),
      Frame(s07, model.animation.deathScreen),
      Frame(s06, model.animation.deathScreen),
      Frame(s05, model.animation.deathScreen),
      Frame(s04, model.animation.deathScreen),
      Frame(s05, model.animation.deathScreen),
      Frame(s06, model.animation.deathScreen),
      Frame(s07, model.animation.deathScreen),
      Frame(s08, model.animation.deathScreen),
      Frame(s09, model.animation.deathScreen),
      Frame(s10, model.animation.deathScreen),
    ];

    anim   = Animation(frames, loop: false);
    sprite = GameAnimation.rectangle(5, 4.5, anim);
    add(sprite);
    sprite.x = size.width  / 2 - sprite.width  / 2;
    sprite.y = size.height / 2 - sprite.height / 1.5;
  }

  void _tapToRestart() {
    restart = GameAnimation.rectangle(
      4,
      0.5,
      Animation.sequenced(
        'restart.png',
        2,
        textureHeight: 64,
        textureWidth:  512,
        stepTime:      model.animation.tap2restart,
      )
    );

    add(restart);
    restart.x = size.width / 2 - restart.width / 2;
    restart.y = sprite.toRect().bottom + restart.height;
  }

  @override
  void update(double t) {
    super.update(t);

    if (restart == null && anim.isLastFrame) {
      _tapToRestart();
    }
  }

  bool get canRestart => restart != null;
}