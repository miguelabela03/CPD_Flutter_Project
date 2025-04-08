import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

import 'package:play_again_ma_swd62a/data/consoles.dart';
import 'package:play_again_ma_swd62a/data/genres.dart';

import 'package:play_again_ma_swd62a/models/game_item.dart';
import 'package:play_again_ma_swd62a/widgets/new_item.dart';

import 'package:http/http.dart' as http;

class GameList extends StatefulWidget {
  const GameList({super.key});

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  List<GameItem> _gameItems = [];
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future _loadItems() async {
    final url = Uri.https(
        'play-again-ma-swd62a-default-rtdb.europe-west1.firebasedatabase.app',
        'game-list.json');

    final response = await http.get(url);

    final List<GameItem> loadedList = [];

    final data = json.decode(response.body);

    if (data == null) {
      setState(() {
        isLoading = false;
        _gameItems = [];
      });
      return;
    }

    final Map<String, dynamic> firebaseData = data as Map<String, dynamic>;

    for (final item in firebaseData.entries) {
      final selectGenre = genres.entries
          .firstWhere(
              (genreItem) => genreItem.value.title == item.value["genre"])
          .value;

      final selectConsole = consoles.entries
          .firstWhere(
              (consoleItem) => consoleItem.value.title == item.value["console"])
          .value;

      loadedList.add(GameItem(
          id: item.key,
          gameTitle: item.value["gameTitle"],
          genre: selectGenre,
          console: selectConsole,
          sellingPrice: item.value["sellingPrice"]
          //image: item.value["image"]
          ));
    }

    setState(() {
      isLoading = false;
      _gameItems = loadedList;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GameItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _gameItems.add(newItem);
    });
  }

  void removeItem(GameItem item) {
    final url = Uri.https(
        'play-again-ma-swd62a-default-rtdb.europe-west1.firebasedatabase.app',
        'game-list/${item.id}.json');

    http.delete(url);

    setState(() {
      _gameItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Items in the list'),
    );

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_gameItems.isNotEmpty) {
      content = RefreshIndicator(
        onRefresh: _loadItems,
        child: ListView.builder(
          itemCount: _gameItems.length,
          itemBuilder: (ctx, index) => Dismissible(
            onDismissed: (direction) {
              removeItem(_gameItems[index]);
            },
            key: ValueKey(_gameItems[index].id),
            child: ListTile(
              title: Text(_gameItems[index].gameTitle),
              leading: Container(
                width: 24,
                height: 24,
                color: _gameItems[index].genre.color,
              ),
              trailing: Text(
                "€${_gameItems[index].sellingPrice}",
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Games'),
          actions: [
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: content);
  }
}
