import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:play_again_ma_swd62a/models/game_item.dart';

class GameDetailsScreen extends StatelessWidget {
  final GameItem gameItem;

  const GameDetailsScreen({super.key, required this.gameItem});

  @override
  Widget build(BuildContext context) {
    Widget content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Game Title
        Text(
          'Game Title: ${gameItem.gameTitle}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Selling Price
        Text(
          'Selling Price: €${gameItem.sellingPrice}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),

        // Genre
        Row(
          children: [
            Container(width: 16, height: 16, color: gameItem.genre.color),
            const SizedBox(width: 8),
            Text(
              'Genre: ${gameItem.genre.title}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Console
        Row(
          children: [
            Container(width: 16, height: 16, color: gameItem.console.color),
            const SizedBox(width: 8),
            Text(
              'Console: ${gameItem.console.title}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Image
        gameItem.image != null
            ? Container(
              width: 200,
              height: 500,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.memory(
                base64Decode(gameItem.image!),
                fit: BoxFit.cover,
              ),
            )
            : const Text("No Image Available", style: TextStyle(fontSize: 18)),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text("Game Details")),
      body: content,
    );
  }
}
