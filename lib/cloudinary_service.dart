import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dgp3eeblm';
  static const String uploadPreset = 'newsapi123';  // Make sure this matches your Postman request

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
      );

      final bytes = await imageFile.readAsBytes();
      
      // Create multipart request matching your Postman configuration
      final request = http.MultipartRequest('POST', url);
      
      // Add file first
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );
      
      // Add upload_preset after file
      request.fields['upload_preset'] = uploadPreset;

      print('Sending request to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      
      print('Cloudinary response status: ${response.statusCode}');
      print('Cloudinary response: $responseString');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        final secureUrl = jsonResponse['secure_url'];
        print('Upload successful! URL: $secureUrl');
        return secureUrl;
      }

      print('Upload failed with status: ${response.statusCode}');
      print('Error response: $responseString');
      throw Exception('Upload failed: ${response.statusCode}');
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}