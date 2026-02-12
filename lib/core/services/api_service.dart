import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS/Web/Windows
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static Future<Map<String, dynamic>> analyzeDocuments(
    List<String> filePaths,
    String userId,
  ) async {
    final uri = Uri.parse('$baseUrl/analyze-documents');
    var request = http.MultipartRequest('POST', uri);

    // Add user_id header (using hyphen per backend fix)
    request.headers['user-id'] = userId;

    // Add files
    for (var path in filePaths) {
      if (kIsWeb) {
        // Handle web files if necessary (not fully implemented here as file_picker returns bytes for web)
        // This implementation assumes file paths are available (Desktop/Mobile)
      } else {
        final file = File(path);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath('files', path));
        }
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to analyze documents: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
