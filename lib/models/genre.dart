import 'package:flutter/material.dart';

enum Genres {
  action,
  rpg,
  sports,
  adventure,
  shooter,
  platform
}

class Genre {
  const Genre(this.title, this.color);

  final String title;
  final Color color;
}