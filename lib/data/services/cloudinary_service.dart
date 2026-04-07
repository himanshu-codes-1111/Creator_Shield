import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  /// TODO: Replace with your actual Cloudinary Cloud Name
  static const String _cloudName = 'drtcoubct';
  
  /// TODO: Replace with your actual Cloudinary Unsigned Upload Preset
  static const String _uploadPreset = 'creator_proof_preset';

  static const String _cloudinaryUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload';

  /// Uploads a local [File] to Cloudinary.
  /// Throws an [Exception] if the upload fails or the HTTP response is not 200.
  /// Returns the securely hosted 'secure_url' string from Cloudinary.
  Future<String> uploadFile(File file) async {
    try {
      if (!await file.exists()) {
        throw Exception("Local file could not be read or does not exist.");
      }

      var request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
      
      request.fields['upload_preset'] = _uploadPreset;
      
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path)
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Cloudinary upload failed: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      rethrow;
    }
  }
}
