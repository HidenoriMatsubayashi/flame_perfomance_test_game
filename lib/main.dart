import 'dart:io' as io;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';

import './game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!io.Platform.isLinux) {
    throw Exception('This game only supports Linux');
  }
  await Flame.device.setPortrait();
  await Flame.device.fullScreen();
  runApp(GameWidget(game: SpaceShooterGame()));
}
