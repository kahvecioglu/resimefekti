import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class ImageDownloadService {
  // Resim indirme ve kaydetme işlemi
  Future<void> downloadImage(Uint8List imageBytes, BuildContext context) async {
    // Depolama izni kontrolü
    final permissionStatus = await Permission.storage.request();
    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Depolama izni verilmedi!')),
      );
      return;
    }

    // Downloads klasörünü alıyoruz
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klasör alınamadı!')),
      );
      return;
    }

    // Dosya yolunu oluşturuyoruz
    final file = File('${directory.path}/downloaded_image.png');

    // Resmi Downloads klasörüne kaydediyoruz
    await file.writeAsBytes(imageBytes);

    // Kullanıcıya geri bildirim veriyoruz
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            'Resim başarıyla indirildi!',
            textAlign: TextAlign.center, // Metni merkeze hizala
            style: TextStyle(
              color: Colors.white, // Yazı rengi
              fontSize: 16, // Yazı boyutu
            ),
          ),
        ),
        backgroundColor: Colors.green, // SnackBar arka plan rengi
        duration: Duration(seconds: 1),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            "Dosyanın konumu: " + file.path,
            textAlign: TextAlign.center, // Metni merkeze hizala
            style: TextStyle(
              color: Colors.white, // Yazı rengi
              fontSize: 14, // Yazı boyutu
            ),
          ),
        ),
        backgroundColor: Colors.green, // SnackBar arka plan rengi
        duration: Duration(seconds: 1),
      ),
    );

    // Dosyanın kaydedildiği yeri logluyoruz
    print('Dosya kaydedildi: ${file.path}');
  }
}
