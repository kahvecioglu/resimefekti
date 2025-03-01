import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageProviderModel extends ChangeNotifier {
  Uint8List? selectedImage; // Ana resim (orijinal)
  Uint8List? filteredImage; // Filtrelenmiş resim
  bool isLoading = false;
  String errorMessage = '';
  bool showFilteredImage = false; // Filtreli resmi göstermek için
  bool showOriginalImage =
      true; // Orijinal resmi göstermek için (başlangıçta orijinal gösterilsin)

  // Seçilen resmi güncelle
  void updateSelectedImage(Uint8List bytes) {
    selectedImage = bytes;
    filteredImage = null; // Yeni resim seçildiğinde filtreyi sıfırla
    showOriginalImage = true; // Seçilen resim orijinal olacak
    showFilteredImage = false;
    notifyListeners();
  }

  // Filtreli resmi güncelle
  void updateFilteredImage(Uint8List bytes) {
    filteredImage = bytes;
    showFilteredImage = true; // Filtreli resim gösterilsin
    showOriginalImage = false; // Orijinal resim gizlensin
    notifyListeners();
  }

  // Orijinal resmi göstermek için
  void showOriginal() {
    showOriginalImage = true;
    showFilteredImage = false;
    notifyListeners();
  }

  // Filtreli resmi göstermek için
  void showFiltered() {
    showFilteredImage = true;
    showOriginalImage = false;
    notifyListeners();
  }

  // Loading durumunu güncelle
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Hata mesajını ayarla
  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }
}
