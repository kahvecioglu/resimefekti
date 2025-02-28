import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageProviderModel with ChangeNotifier {
  Uint8List? _selectedImage;

  Uint8List? get selectedImage => _selectedImage;

  void updateSelectedImage(Uint8List image) {
    _selectedImage = image;
    notifyListeners(); // UI'yi güncelle
  }
}
