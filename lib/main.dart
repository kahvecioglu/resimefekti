import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImageProviderModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

class ImageProviderModel extends ChangeNotifier {
  Uint8List? selectedImage;
  Uint8List? processedImage;
  bool isLoading = false;

  // Seçilen resmi güncelle
  void updateSelectedImage(Uint8List? image) {
    selectedImage = image;
    notifyListeners();
  }

  // İşlenmiş resmi güncelle
  void updateProcessedImage(Uint8List? image) {
    processedImage = image;
    notifyListeners();
  }

  // Yükleniyor durumunu ayarla
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
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

    // 5 saniye bekle simülasyonu
    await Future.delayed(Duration(seconds: 12));

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
      var response = await request.send();

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
      _errorMessage = 'Bağlantı hatası Tekrar deneyin: $e';
    } finally {
      imageProvider.setLoading(false); // Yükleniyor durumunu sonlandır
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 45, 77),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 45, 77),
        title: Text(
          'Resim Filtreleme Uygulaması',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Consumer<ImageProviderModel>(
        builder: (context, imageProvider, child) {
          return Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Seçilen resmi göster
                  imageProvider.selectedImage == null
                      ? Text(
                          'Lütfen bir resim seçin.',
                          style: TextStyle(color: Colors.white),
                        )
                      : Image.memory(imageProvider.selectedImage!),
                  SizedBox(height: 20),

                  // Filtrelenmiş resmi göster
                  imageProvider.processedImage == null
                      ? Container()
                      : Image.memory(imageProvider.processedImage!),
                  SizedBox(height: 20),

                  // Hata mesajı
                  _errorMessage.isNotEmpty
                      ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                      : Container(),
                ],
              ),

              // Yükleniyor göstergesi, resimlerin üstünde
              if (imageProvider.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(
                        0.5), // Sayfanın geri kalanını karartmak için
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 5, // Geniş yükleme çubuğu
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),

              // Sabit butonlar, ekranın altında
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Resim seçme butonu
                      ElevatedButton(
                        onPressed: imageProvider.isLoading ? null : _pickImage,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 7, 71, 148)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('+'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('grayscale'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Grayscale'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('blur'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Blur'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('sepia'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Sepia'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('invert'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Invert'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('edge'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Edge'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('contrast'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Contrast'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('brightness'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Brightness'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('mirror'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Mirror'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('negative'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Negative'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: imageProvider.isLoading
                            ? null
                            : () => _applyFilter('vignette'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xFF00BFFF)), // Açık Mavi
                          foregroundColor: MaterialStateProperty.all(
                              Color(0xFFFFFFFF)), // Beyaz yazı
                        ),
                        child: Text('Vignette'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
