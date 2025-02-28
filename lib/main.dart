import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:provider/provider.dart';

// Resim sağlayıcı sınıfı
class ImageProviderModel with ChangeNotifier {
  Uint8List? _selectedImage;
  Uint8List? _processedImage;
  bool _isLoading = false;

  Uint8List? get selectedImage => _selectedImage;
  Uint8List? get processedImage => _processedImage;
  bool get isLoading => _isLoading;

  void updateSelectedImage(Uint8List image) {
    _selectedImage = image;
    notifyListeners(); // UI'yi güncelle
  }

  void updateProcessedImage(Uint8List image) {
    _processedImage = image;
    notifyListeners(); // UI'yi güncelle
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners(); // UI'yi güncelle
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImageProviderModel(),
      child: ImageFilterApp(),
    ),
  );
}

class ImageFilterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  String _errorMessage = '';

  // Resim seçme işlemi
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageProvider =
          Provider.of<ImageProviderModel>(context, listen: false);

      // Resmi Uint8List'e dönüştür
      final bytes = await File(pickedFile.path).readAsBytes();

      // Provider ile resmi güncelle
      imageProvider.updateSelectedImage(bytes);
    }
  }

  // Filtre uygulama işlemi
  Future<void> _applyFilter(String filterType) async {
    final imageProvider =
        Provider.of<ImageProviderModel>(context, listen: false);
    if (imageProvider.selectedImage == null) return;

    // Yükleniyor durumunu başlat
    imageProvider.setLoading(true);
    _errorMessage = '';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.103:5000/process_image'), // API URL
    );

    // Seçilen resmi API'ye gönder
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageProvider.selectedImage!,
      filename: 'image.jpg',
    ));
    request.fields['filter'] = filterType;

    try {
      var response = await request
          .send()
          .timeout(Duration(seconds: 60)); // 60 saniye timeout

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();

        if (bytes.isNotEmpty) {
          // Filtrelenmiş resmi güncelle
          imageProvider.updateProcessedImage(bytes);
        } else {
          _errorMessage = 'Gelen veri boş.';
        }
      } else {
        _errorMessage = 'API hatası: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'API bağlantı hatası: $e';
    } finally {
      imageProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resim Filtreleme Uygulaması'),
        centerTitle: true,
      ),
      body: Consumer<ImageProviderModel>(
        builder: (context, imageProvider, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Seçilen resmi göster
                imageProvider.selectedImage == null
                    ? Text('Lütfen bir resim seçin.')
                    : Image.memory(imageProvider.selectedImage!),
                SizedBox(height: 20),

                // Filtrelenmiş resmi göster
                imageProvider.processedImage == null
                    ? Container()
                    : Image.memory(imageProvider.processedImage!),
                SizedBox(height: 20),

                // Resim seçme butonu
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Resim Seç'),
                ),
                SizedBox(height: 20),

                // Filtre uygulama butonları
                ElevatedButton(
                  onPressed: () => _applyFilter('grayscale'),
                  child: Text('Grayscale Uygula'),
                ),
                ElevatedButton(
                  onPressed: () => _applyFilter('blur'),
                  child: Text('Blur Uygula'),
                ),
                ElevatedButton(
                  onPressed: () => _applyFilter('sepia'),
                  child: Text('Sepia Uygula'),
                ),
                ElevatedButton(
                  onPressed: () => _applyFilter('invert'),
                  child: Text('Invert Uygula'),
                ),
                ElevatedButton(
                  onPressed: () => _applyFilter('edge'),
                  child: Text('Edge Uygula'),
                ),
                ElevatedButton(
                  onPressed: () => _applyFilter('contrast'),
                  child: Text('Contrast Uygula'),
                ),
                ElevatedButton(
                  onPressed: () => _applyFilter('brightness'),
                  child: Text('Brightness Uygula'),
                ),
                ElevatedButton(
                  onPressed: () => _applyFilter('mirror'),
                  child: Text('Mirror Uygula'),
                ),
                SizedBox(height: 20),

                // Yükleniyor göstergesi veya hata mesajı
                imageProvider.isLoading
                    ? CircularProgressIndicator()
                    : (_errorMessage.isNotEmpty
                        ? Text(_errorMessage,
                            style: TextStyle(color: Colors.red))
                        : Container()),
              ],
            ),
          );
        },
      ),
    );
  }
}
