import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorLoader {
  static Map<String, PaletteGenerator> _colors = {};

  static Future<PaletteGenerator> getColor(String s) async {
    if (_colors[s] != null) {
      return _colors[s];
    }
    _colors[s] = await PaletteGenerator.fromImageProvider(NetworkImage(s));

    return _colors[s];
  }
}
