import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Remove the static getter and replace with proper initialization
  static final cloudinary = CloudinaryPublic(
    'dgp3eebim',  // Replace with your Cloudinary cloud name
    'newsapi123',  // Replace with your unsigned upload preset
    cache: false,
  );

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      print('Starting Cloudinary upload process...');
      print('Image path: ${imageFile.path}');

      if (!(await imageFile.length() > 0)) {
        print('Error: Image file is empty or invalid');
        return null;
      }

      final cloudinaryFile = CloudinaryFile.fromFile(
        imageFile.path,
        resourceType: CloudinaryResourceType.Image,
        folder: 'demo',
      );

      print('Uploading to Cloudinary...');
      final response = await cloudinary.uploadFile(cloudinaryFile);

      if (response.secureUrl.isNotEmpty) {
        print('Upload successful!');
        print('Secure URL: ${response.secureUrl}');
        return response.secureUrl;
      } else {
        print('Upload failed: No secure URL received');
        return null;
      }
    } catch (e, stackTrace) {
      print('Cloudinary upload error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}