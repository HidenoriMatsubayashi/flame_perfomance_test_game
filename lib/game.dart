//import 'dart:ffi' as ffi;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
//import 'package:joystick_plugin/joystick_plugin.dart';

import './components/player_component.dart';
import './components/enemy_creator.dart';
import './components/star_background_creator.dart';
import './components/score_component.dart';

enum ButtonPress {
  Up,
  Down,
}

enum XAxis {
  Left,
  Right,
}

enum YAxis {
  Up,
  Down,
}

class SpaceShooterGame extends BaseGame with HasCollidables {
  SpaceShooterGame()
      : usesGamepad = const String.fromEnvironment('USES_GAMEPAD') == 'TRUE';

  final bool usesGamepad;
  PlayerComponent? player;

  int score = 0;
  late final int joystickFileDescriptor;

  final debugTextconfig = TextPaint(
    config: TextPaintConfig(color: const Color(0xFFFFFFFF)),
  );

  @override
  Future<void> onLoad() async {
    add(player = PlayerComponent());

    add(EnemyCreator());
    add(StarBackGroundCreator());

    add(ScoreComponent());

    if (usesGamepad) {
      joystickFileDescriptor = -1; //openFD();
    } else {
      joystickFileDescriptor = -1;
    }
  }

  static XAxis? currentX; // `null` means not currently pressed
  static YAxis? currentY;
  static const double distance = 375;

  @override
  void update(double dt) {
    super.update(dt);

    // move x axis
    switch (currentX) {
      case null:
        // don't move
        break;
      case XAxis.Left:
        player?.move(-distance * dt, 0);
        break;
      case XAxis.Right:
        player?.move(distance * dt, 0);
        break;
    }
    // move y axis
    switch (currentY) {
      case null:
        // don't move
        break;
      case YAxis.Up:
        player?.move(0, -distance * dt);
        break;
      case YAxis.Down:
        player?.move(0, distance * dt);
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.scale(1);
    super.render(canvas);

    debugTextconfig.render(canvas, fps(120).toString(), Vector2(0, 50));
    debugTextconfig.render(
        canvas, 'Objects: ${components.length}', Vector2(0, 100));
  }

  void increaseScore() {
    score++;
  }

  void playerTakeHit() {
    player!.takeHit();
    score = 0;
  }
}
