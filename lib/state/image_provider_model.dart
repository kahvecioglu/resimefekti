import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageProviderModel extends ChangeNotifier {
  Uint8List? selectedImage;
  Uint8List? processedImage;
  bool isLoading = false;
  String errorMessage = '';
  bool showProcessedImage = false;

  void updateSelectedImage(Uint8List? image) {
    selectedImage = image;
    processedImage = null;
    errorMessage = '';
    showProcessedImage = false; // Orijinal resmi göster
    notifyListeners();
  }

  void updateProcessedImage(Uint8List? image) {
    processedImage = image;
    showProcessedImage = true; // Filtreli resmi göster
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    errorMessage = '';
    notifyListeners();
  }

  void reset() {
    selectedImage = null;
    processedImage = null;
    showProcessedImage = false;
    errorMessage = '';
    isLoading = false;
    notifyListeners();
  }
}
