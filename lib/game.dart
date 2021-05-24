import 'dart:ffi' as ffi;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:joystick_plugin/joystick_plugin.dart';

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
      joystickFileDescriptor = openFD();
    } else {
      joystickFileDescriptor = -1;
    }
  }

  static XAxis? currentX; // `null` means not currently pressed
  static YAxis? currentY;
  static const double distance = 250;

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
    if (usesGamepad) {
      final ffi.Pointer<JSEvent> event = flushFD(joystickFileDescriptor);
      if (event != ffi.nullptr) {
        switch (event.ref.type) {
          case JS_EVENT_BUTTON:
            switch (event.ref.number) {
              // A or B buttons mean fire
              case 0:
              case 1:
                if (event.ref.value == 1) {
                  player?.beginFire();
                } else {
                  player?.stopFire();
                }
                break;
              case 2: // X
                break;
              case 3: // Y
                break;
              case 4: // L
                break;
              case 5: // R
                break;
              case 6: // Select
                break;
              case 7: // Start
                break;
              default:
                // TODO just ignore these
                throw Exception("Oops! Unsupported button: ${event.ref.number}");
            }
            break;
          case JS_EVENT_AXIS:
            switch (event.ref.number) {
              case 6: // X-axis
                if (event.ref.value > 0) {
                  currentX = XAxis.Right;
                } else if (event.ref.value < 0) {
                  currentX = XAxis.Left;
                } else {
                  currentX = null;
                }
                break;
              case 7: // Y-axis
                if (event.ref.value > 0) {
                  currentY = YAxis.Down;
                } else if (event.ref.value < 0) {
                  currentY = YAxis.Up;
                } else {
                  currentY = null;
                }
                break;
              default:
                throw Exception(
                    'Unimplemented joystick axis ${event.ref.number}');
            }
            break;
          case JS_EVENT_INIT:
            // These should be discarded by the C code
            throw Exception('Received unexpected JS_EVENT_INIT event');
          default:
            throw Exception('Unknown event type ${event.ref.type}');
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
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
