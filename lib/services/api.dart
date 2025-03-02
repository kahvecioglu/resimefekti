// api.dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Uint8List?> processImage(Uint8List image, String filterType) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.103:5000/process_image'),
      );

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        image,
        filename: 'image.jpg',
      ));
      request.fields['filter'] = filterType;

      var response = await request.send().timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        if (bytes.isNotEmpty) {
          return bytes;
        } else {
          throw Exception('Gelen veri boş.');
        }
      } else {
        throw Exception('API hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Sorunu: ${e.toString()}');
    }
  }
}
