import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class ImageService {
  static const String _imgbbApiKey = '10b390d333552ca6a62cebae7a643453';

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Create request
      final url = Uri.parse('https://api.imgbb.com/1/upload');
      var request = http.MultipartRequest('POST', url);
      
      // Add API key
      request.fields['key'] = _imgbbApiKey;
      
      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      
      print('Starting upload to ImgBB...');
      
      // Send request
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      
      print('ImgBB Response: $responseString');
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        if (jsonResponse['success'] == true) {
          final imageUrl = jsonResponse['data']['display_url'];
          print('Upload successful: $imageUrl');
          return imageUrl;
        }
      }
      
      print('Upload failed. Status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}