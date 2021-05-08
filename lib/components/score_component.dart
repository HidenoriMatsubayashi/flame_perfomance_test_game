import 'package:flame/components.dart';

import '../game.dart';

class ScoreComponent extends TextComponent with HasGameRef<SpaceShooterGame> {
  ScoreComponent() : super(
      "Score 0",
      position: Vector2.all(5),
  );

  @override
  void update(double dt) {
    super.update(dt);
    text = "Score ${gameRef.score}";
  }
}
