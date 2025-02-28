import 'dart:io';
import 'package:flutter/material.dart';
import 'api_service.dart';

class ImageProcessor with ChangeNotifier {
  File? _originalImage;
  File? _processedImage;

  File? get originalImage => _originalImage;
  File? get processedImage => _processedImage;

  void setImage(File image) {
    _originalImage = image;
    _processedImage = null;
    notifyListeners();
  }

  Future<void> applyFilter(String filter) async {
    if (_originalImage == null) return;

    // Simulate image processing (replace with actual C++/OpenCV logic)
    await Future.delayed(Duration(seconds: 2));
    _processedImage = _originalImage;
    notifyListeners();
  }
/*
  Future<void> sendToPythonAPI() async {
    if (_originalImage == null) return;

  final response = await ApiService.sendImage(_originalImage!);
    if (response != null) {
      _processedImage = File(response);
      notifyListeners();
    }
  }
 */
}
