import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // image paketini kullanacağız
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

    // Resmi 'image' paketini kullanarak yükleyelim
    img.Image? image = img.decodeImage(await _originalImage!.readAsBytes());

    if (image == null) return;

    // Filtresi seçilene göre işlemi uygula
    if (filter == 'grayscale') {
      image = img.grayscale(image);
    } else if (filter == 'blur') {
      image = img.gaussianBlur(image, radius: 12);
    } else if (filter == 'sepia') {
      image = img.sepia(image);
    } else if (filter == 'invert') {
      image = img.invert(image);
    } else if (filter == 'edge') {
      image = img.sobel(image);
    } else if (filter == 'contrast') {
      image = img.adjustColor(image, contrast: 1.5);
    } else if (filter == 'brightness') {
      image = img.adjustColor(image, brightness: 1.5);
    } else if (filter == 'mirror') {
      image = img.flipHorizontal(image);
    }

    // İşlenmiş resmi kaydedelim
    final processedFile = await _saveProcessedImage(image);

    // Processed image güncellemesi
    _processedImage = processedFile;
    notifyListeners();
  }

  Future<File> _saveProcessedImage(img.Image image) async {
    // Dosyayı kaydetmek için geçici bir yol oluşturuyoruz
    final directory = await Directory.systemTemp.createTemp();
    final outputPath = '${directory.path}/processed_image.png';

    // İşlenmiş resmi kaydediyoruz
    final file = File(outputPath)..writeAsBytesSync(img.encodePng(image));
    return file;
  }

  Future<void> sendToPythonAPI() async {
    if (_originalImage == null) return;

    final response = await ApiService.sendImage(_originalImage!, 'grayscale');
    if (response != null) {
      _processedImage = File(response);
      notifyListeners();
    }
  }
}
