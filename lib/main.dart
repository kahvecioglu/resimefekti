import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // İzinler için
import 'api.dart'; // api.dart dosyasını içeri aktar
import 'image_provider_model.dart'; // image_provider_model.dart dosyasını içeri aktar

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
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isShowingOriginal = false; // Orijinal resmi gösterme durumu
  final ApiService _apiService = ApiService(); // ApiService nesnesi

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageProvider =
          Provider.of<ImageProviderModel>(context, listen: false);
      final bytes = await File(pickedFile.path).readAsBytes();

      if (bytes.lengthInBytes > 1024 * 1024) {
        imageProvider.setError('Lütfen 1 MB’den küçük bir resim seçin.');
        return;
      }

      imageProvider.reset(); // Her şeyi sıfırla
      imageProvider.updateSelectedImage(bytes);
    }
  }

  Future<void> _applyFilter(String filterType) async {
    final imageProvider =
        Provider.of<ImageProviderModel>(context, listen: false);
    if (imageProvider.selectedImage == null) return;

    imageProvider.setLoading(true);
    imageProvider.clearError();

    // 3 saniye bekle
    await Future.delayed(Duration(seconds: 3));

    try {
      final processedImage = await _apiService.processImage(
          imageProvider.selectedImage!, filterType);

      if (processedImage != null) {
        imageProvider.updateProcessedImage(processedImage);
      }
    } catch (e) {
      imageProvider.setError(e.toString());
    } finally {
      imageProvider.setLoading(false);
    }
  }

  Future<void> _downloadImage(Uint8List imageBytes) async {
    // İzinleri kontrol et ve gerekli izinleri al
    final permissionStatus = await Permission.storage.request();
    if (!permissionStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Depolama izni verilmedi!')),
      );
      return;
    }

    // Android cihazında dış depolama alanındaki Downloads klasörünü alıyoruz
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klasör alınamadı!')),
      );
      return;
    }

    // Downloads klasörü içinde dosyayı kaydediyoruz
    final file = File('${directory.path}/downloaded_image.png');

    await file.writeAsBytes(imageBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resim başarıyla indirildi!')),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("konum :" + file.path)),
    );

    // Dosyanın kaydedildiği yeri yazdırma (geliştirici için)
    print('Dosya kaydedildi: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 173, 23, 23),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, const Color.fromARGB(255, 4, 150, 155)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Resim Filtreleme Uygulaması',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blue], // Aynı renk gradyanı
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<ImageProviderModel>(
          builder: (context, imageProvider, child) {
            return Stack(
              children: [
                Center(
                  child: imageProvider.selectedImage == null
                      ? Icon(
                          Icons.image,
                          size: 150,
                          color: Colors.white,
                        )
                      : Image.memory(
                          _isShowingOriginal
                              ? imageProvider.selectedImage!
                              : imageProvider.processedImage ??
                                  imageProvider.selectedImage!,
                          fit: BoxFit.contain,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                ),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: imageProvider.errorMessage.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            imageProvider.errorMessage,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(),
                ),
                if (imageProvider.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                // İndirme butonunu üst kısma taşıdık
                Positioned(
                  top: 120, // Üstten 120 px aşağıda
                  left: 0,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: imageProvider.isLoading ||
                            imageProvider.selectedImage == null
                        ? null
                        : () => _downloadImage(imageProvider.selectedImage!),
                    child: Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      backgroundColor: Colors.teal,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              imageProvider.isLoading ? null : _pickImage,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(20),
                            backgroundColor: Colors.teal,
                          ),
                        ),
                        SizedBox(width: 20),
                        ..._filterButtons(imageProvider),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _isShowingOriginal = true;
                      });
                    },
                    onLongPressUp: () {
                      setState(() {
                        _isShowingOriginal = false;
                      });
                    },
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: Colors.teal,
                      child: Icon(
                        _isShowingOriginal
                            ? Icons.circle
                            : Icons.circle_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _filterButtons(ImageProviderModel imageProvider) {
    List<Map<String, dynamic>> filterTypes = [
      {'label': 'Grayscale', 'icon': Icons.photo_filter},
      {'label': 'Blur', 'icon': Icons.blur_on},
      {'label': 'Sepia', 'icon': Icons.color_lens},
      {'label': 'Contrast', 'icon': Icons.tune},
      {'label': 'Brightness', 'icon': Icons.brightness_6},
      {'label': 'Mirror', 'icon': Icons.flip},
      {'label': 'Negative', 'icon': Icons.photo_size_select_large},
      {'label': 'Vignette', 'icon': Icons.vignette},
      {'label': 'Posterize', 'icon': Icons.photo_filter},
    ];

    return filterTypes.map((filter) {
      return _modernFilterButton(filter['label'], filter['icon']);
    }).toList();
  }

  Widget _modernFilterButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed:
            Provider.of<ImageProviderModel>(context, listen: false).isLoading ||
                    _isShowingOriginal
                ? null
                : () => _applyFilter(text.toLowerCase()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
