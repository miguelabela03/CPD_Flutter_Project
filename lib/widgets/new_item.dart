import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:play_again_ma_swd62a/data/genres.dart';
import 'package:play_again_ma_swd62a/models/genre.dart';

import 'package:play_again_ma_swd62a/data/consoles.dart';
import 'package:play_again_ma_swd62a/models/console.dart';

import 'package:play_again_ma_swd62a/models/game_item.dart';

import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredGameTitle = '';
  var _selectedGenre = genres[Genres.action];
  var _selectedConsole = consoles[Consoles.PS2];
  var _enteredSellingPrice = 1.00;

  var isSendingData = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isSendingData = true;
      });

      final url = Uri.https(
          'play-again-ma-swd62a-default-rtdb.europe-west1.firebasedatabase.app',
          'game-list.json');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'gameTitle': _enteredGameTitle,
          'genre': _selectedGenre!.title,
          'console': _selectedConsole!.title,
          'sellingPrice': _enteredSellingPrice
          // Implement Image
        }),
      );

      Map<String, dynamic> responseData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(GameItem(
        id: responseData["name"],
        gameTitle: _enteredGameTitle,
        genre: _selectedGenre!,
        console: _selectedConsole!,
        sellingPrice: _enteredSellingPrice
        // Implement Image
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Game Title'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredGameTitle = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Genre
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedGenre,
                      items: [
                        for (final genre in genres.entries)
                          DropdownMenuItem(
                            value: genre.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: genre.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(genre.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedGenre = value!;
                        });
                      },
                      decoration: const InputDecoration(label: Text('Genre')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Console
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedConsole,
                      items: [
                        for (final console in consoles.entries)
                          DropdownMenuItem(
                            value: console.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: console.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(console.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedConsole = value!;
                        });
                      },
                      decoration: const InputDecoration(label: Text('Console')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text('Selling Price'),
                  prefixText: '€',
                ),
                initialValue: '1.00',
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.tryParse(value)! <= 0) {
                    return 'Please enter a valid price.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredSellingPrice = double.parse(value!);
                },
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: isSendingData ? null : _saveItem,
                    child: isSendingData
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
