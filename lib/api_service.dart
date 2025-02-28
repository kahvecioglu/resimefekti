import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String apiUrl = 'http://10.0.2.2:5000/process';

  static Future<String?> sendImage(File image, String filter) async {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // Resmi gönderiyoruz
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'png'),
      ),
    );

    // Filtreyi form verisi olarak ekliyoruz
    request.fields['filter'] = filter;

    var response = await request.send();
    if (response.statusCode == 200) {
      // Yanıt olarak resmin kaydedildiği yolu alıyoruz
      final responseString = await response.stream.bytesToString();
      return responseString; // Yanıt olarak işlenmiş resmin yolu dönecek
    } else {
      return null;
    }
  }
}
