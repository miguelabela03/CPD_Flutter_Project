import 'package:play_again_ma_swd62a/models/console.dart';
import 'package:play_again_ma_swd62a/models/genre.dart';

class GameItem {
  GameItem({
    required this.id,
    required this.gameTitle,
    required this.genre,
    required this.console,
    required this.sellingPrice,
    required this.image
  });

  final String id;
  final String gameTitle;
  final Genre genre;
  final Console console;
  final double sellingPrice;
  final String? image;
}