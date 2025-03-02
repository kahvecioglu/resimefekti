import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:resimefekti/services/image_download_service.dart';
import 'services/api.dart';
import 'state/image_provider_model.dart';
import 'package:resimefekti/services/image_filter_service.dart';

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
  bool _isShowingOriginal = false;
  final ApiService _apiService = ApiService();
  final ImageFilterService _imageFilterService = ImageFilterService();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

      imageProvider.reset();
      imageProvider.updateSelectedImage(bytes);
    }
  }

  Future<void> _applyFilter(String filterType) async {
    final imageProvider =
        Provider.of<ImageProviderModel>(context, listen: false);
    await _imageFilterService.applyFilter(imageProvider, filterType);
  }

  Future<void> _downloadImage(Uint8List imageBytes) async {
    final imageDownloadService = ImageDownloadService();
    await imageDownloadService.downloadImage(imageBytes, context);
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Uygulamadan çıkmak istediğinizden emin misiniz?'),
        content: Text('Tüm veriler kaybolabilir.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Uygulamadan çıkmak için exit() fonksiyonunu çağırıyoruz
              exit(0);
            },
            child: Text('Çık'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      drawer: Drawer(
        backgroundColor: Colors.teal[300],
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, const Color.fromARGB(255, 4, 150, 155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text(
                'Home',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Menüden çıkış
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text(
                'Quit',
                style: TextStyle(color: Colors.white),
              ),
              onTap: _showQuitDialog, // Quit tıklandığında onay dialog'u göster
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blue],
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
                  top: 120,
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
                  height: 25,
                  width: 25,
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
