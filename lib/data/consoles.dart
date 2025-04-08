import 'package:flutter/material.dart';
import 'package:play_again_ma_swd62a/models/console.dart';

const consoles = {
  Consoles.PS2: Console("PS2", Color.fromARGB(255, 255, 255, 0)),
  Consoles.PS3: Console("PS3", Color.fromARGB(255, 212, 126, 6)),
  Consoles.PS4: Console("PS4", Color.fromARGB(255, 218, 36, 16)),
  Consoles.PS5: Console("PS5", Color.fromARGB(255, 27, 199, 30)),
  Consoles.Wii: Console("Wii", Color.fromARGB(255, 10, 215, 198)),
  Consoles.Xbox360: Console("Xbox 360", Color.fromARGB(255, 13, 19, 187)),
  Consoles.XboxOne: Console("Xbox One", Color.fromARGB(255, 113, 11, 168)),
};