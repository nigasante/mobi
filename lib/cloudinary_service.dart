import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static final cloudinary = CloudinaryPublic(
    'dgp3eeblm', // Your cloud name
    'newsapi123', // Your upload preset
    cache: false,
  );

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      print('Sending request to Cloudinary...');

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'demo', // Optional: organize uploads in folders
        ),
      );

      print('Upload successful! URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
