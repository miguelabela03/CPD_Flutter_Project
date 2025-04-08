import 'package:flutter/material.dart';

enum Consoles {
  PS5,
  PS4,
  PS3,
  PS2,
  XboxOne,
  Xbox360,
  Wii
}

class Console {
  const Console(this.title, this.color);

  final String title;
  final Color color;
}