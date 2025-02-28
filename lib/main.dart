import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'image_processor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FiltResim',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => ImageProcessor(),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageProcessor processor) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      processor.setImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final processor = Provider.of<ImageProcessor>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('FiltResim'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: processor.originalImage != null
                  ? Image.file(processor.originalImage!)
                  : Icon(Icons.image_outlined, size: 100, color: Colors.grey),
            ),
          ),
          Expanded(
            child: processor.processedImage != null
                ? Image.file(processor.processedImage!)
                : SizedBox(),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildFilterButton(
                    Icons.add, 'Seç', () => _pickImage(processor)),
                _buildFilterButton(Icons.grain, 'Gri',
                    () => processor.applyFilter('grayscale')),
                _buildFilterButton(Icons.blur_on, 'Bulanık',
                    () => processor.applyFilter('blur')),
                _buildFilterButton(Icons.filter_vintage, 'Sepia',
                    () => processor.applyFilter('sepia')),
                _buildFilterButton(Icons.invert_colors, 'Ters',
                    () => processor.applyFilter('invert')),
                _buildFilterButton(Icons.shutter_speed, 'Keskin',
                    () => processor.applyFilter('edge')),
                _buildFilterButton(Icons.tonality, 'Kontrast',
                    () => processor.applyFilter('contrast')),
                _buildFilterButton(Icons.wb_sunny, 'Parlak',
                    () => processor.applyFilter('brightness')),
                _buildFilterButton(
                    Icons.flip, 'Ayna', () => processor.applyFilter('mirror')),
                _buildFilterButton(Icons.cloud_upload, 'API',
                    () => processor.sendToPythonAPI()),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
      IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.blueAccent),
      label: Text(label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}
