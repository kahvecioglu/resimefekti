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
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isShowingOriginal = false; // Orijinal resmi gösterme durumu

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

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.103:5000/process_image'),
    );

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageProvider.selectedImage!,
      filename: 'image.jpg',
    ));
    request.fields['filter'] = filterType;

    try {
      var response = await request.send().timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        if (bytes.isNotEmpty) {
          imageProvider.updateProcessedImage(bytes);
        } else {
          imageProvider.setError('Gelen veri boş.');
        }
      } else {
        imageProvider.setError('API hatası: ${response.statusCode}');
      }
    } catch (e) {
      imageProvider.setError('Bağlantı Sorunu: ${e.toString()}');
    } finally {
      imageProvider.setLoading(false);
    }
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
