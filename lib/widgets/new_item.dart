import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:play_again_ma_swd62a/data/genres.dart';
import 'package:play_again_ma_swd62a/models/genre.dart';

import 'package:play_again_ma_swd62a/data/consoles.dart';
import 'package:play_again_ma_swd62a/models/console.dart';

import 'package:play_again_ma_swd62a/models/game_item.dart';

import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:play_again_ma_swd62a/services/noti_service.dart';

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
  File? _selectedImage;

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (returnedImage == null) return;
    final imageTemporary = File(returnedImage.path);
    setState(() {
      _selectedImage = imageTemporary;
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (returnedImage == null) return;
    final imageTemporary = File(returnedImage.path);
    setState(() {
      _selectedImage = imageTemporary;
    });
  }

  Future<String> convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  var isSendingData = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isSendingData = true;
      });

      final url = Uri.https(
        'play-again-ma-swd62a-default-rtdb.europe-west1.firebasedatabase.app',
        'game-list.json',
      );

      final base64Image =
          _selectedImage != null
              ? await convertImageToBase64(_selectedImage!)
              : null;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'gameTitle': _enteredGameTitle,
          'genre': _selectedGenre!.title,
          'console': _selectedConsole!.title,
          'sellingPrice': _enteredSellingPrice,
          'image': base64Image, // sent as string
        }),
      );

      Map<String, dynamic> responseData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GameItem(
          id: responseData["name"],
          gameTitle: _enteredGameTitle,
          genre: _selectedGenre!,
          console: _selectedConsole!,
          sellingPrice: _enteredSellingPrice,
          image: base64Image,
        ),
      );

      // Sending notification
      NotiService().showNotification(
        id: 0,
        title: "New Game Details",
        body: "The game details have been added successfully.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Add a New Game')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Game Title')),
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
                        decoration: const InputDecoration(
                          label: Text('Console'),
                        ),
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
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MaterialButton(
                              onPressed: _pickImageFromGallery,
                              child: const Text(
                                "Gallery Image",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MaterialButton(
                              onPressed: _pickImageFromCamera,
                              child: const Text(
                                "Camera",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _selectedImage == null
                        ? const Text("No Image Selected")
                        : Container(
                          width: 350,
                          height: 500,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Image.file(
                            _selectedImage!,
                            fit:
                                BoxFit
                                    .cover, // Ensures the image fits within the container
                          ),
                        ),
                  ],
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
                      child:
                          isSendingData
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
      ),
    );
  }
}
