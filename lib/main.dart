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
      title: 'EverPixel',
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
        title: Text('EverPixel'),
      ),
      body: Column(
        children: [
          if (processor.originalImage != null)
            Expanded(
              child: Image.file(processor.originalImage!),
            ),
          if (processor.processedImage != null)
            Expanded(
              child: Image.file(processor.processedImage!),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _pickImage(processor),
                child: Text('Select Image'),
              ),
              ElevatedButton(
                onPressed: () => processor.applyFilter('grayscale'),
                child: Text('Grayscale'),
              ),
              ElevatedButton(
                onPressed: () => processor.applyFilter('blur'),
                child: Text('Blur'),
              ),
              /* ElevatedButton(
                onPressed: () => processor.sendToPythonAPI(),
                child: Text('Send to Python API'),
              ), */
            ],
          ),
        ],
      ),
    );
  }
}
