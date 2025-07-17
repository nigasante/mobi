import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dgp3eebim';
  static const String uploadPreset = '516289367488993';
  static const String apiKey = '516289367488993';
  static const String apiSecret = 'Ptm_HEJ-njj9agUbaYP3yzR2_mM';

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
      );
      
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();
      
      // Create form data
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'image.jpg',
          ),
        );

      print('Starting upload to Cloudinary...');
      
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      
      print('Cloudinary Response: $responseString');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        final imageUrl = jsonResponse['secure_url'];
        print('Upload successful: $imageUrl');
        return imageUrl;
      }

      print('Upload failed. Status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}