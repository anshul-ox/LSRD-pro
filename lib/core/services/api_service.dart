import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // ═══════════════════════════════════════════════════════════════════════════
  // BACKEND URL CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // DEPLOYMENT MODES:
  // 1. PRODUCTION (Cloud/Cloudflare): Set _useProductionBackend = true
  //    - Update _productionBackendUrl with your deployed backend URL
  //
  // 2. LOCAL DEVELOPMENT:
  //    - Android Emulator: Set _usePhysicalDevice = false
  //    - Physical Device: Set _usePhysicalDevice = true
  //    - Update _physicalDeviceIP with your computer's IP
  //
  // ═══════════════════════════════════════════════════════════════════════════

  // ⚠️ PRODUCTION MODE: Set to true when using cloud backend
  static const bool _useProductionBackend = true;

  // ⚠️ PRODUCTION URL: Your deployed backend URL (without trailing slash)
  // Render.com: Deployed backend with no timeout limits
  static const String _productionBackendUrl = 'https://lsrd-pro.onrender.com';

  // ⚠️ LOCAL DEVELOPMENT: Set to true when testing on physical Android device
  static const bool _usePhysicalDevice = false;

  // ⚠️ LOCAL DEVELOPMENT: Your computer's local IP address (for physical devices)
  static const String _physicalDeviceIP = '192.168.1.88';

  static String get baseUrl {
    // PRODUCTION MODE: Use cloud backend
    if (_useProductionBackend) {
      return _productionBackendUrl;
    }

    // LOCAL DEVELOPMENT MODE
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Use physical device IP if configured, otherwise use emulator address
      if (_usePhysicalDevice) {
        return 'http://$_physicalDeviceIP:8000';
      }
      return 'http://10.0.2.2:8000'; // Android Emulator
    }

    // iOS Simulator, Windows, macOS, Linux
    return 'http://127.0.0.1:8000';
  }

  static Future<Map<String, dynamic>> analyzeDocuments(
    Map<String, String> filePaths,
    String userId,
  ) async {
    if (kDebugMode) {
      print('🔵 API Service: Analyzing documents...');
      print('🔵 Backend URL: $baseUrl');
      print('🔵 Files to upload: ${filePaths.keys.join(", ")}');
    }

    final uri = Uri.parse('$baseUrl/analyze');
    var request = http.MultipartRequest('POST', uri);

    // Add user_id header (optional for minimal backend)
    // request.headers['user-id'] = userId;

    // Add files with specific keys
    int filesAdded = 0;
    for (var entry in filePaths.entries) {
      if (kIsWeb) {
        // Handle web files...
      } else {
        final path = entry.value;
        final key = entry.key; // use the key (jamabandi, deed)
        final file = File(path);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (kDebugMode) {
            print('🔵 Adding file: $key -> $path (${(fileSize / 1024).toStringAsFixed(2)} KB)');
          }
          request.files.add(await http.MultipartFile.fromPath(key, path));
          filesAdded++;
        } else {
          if (kDebugMode) {
            print('⚠️ File not found: $path');
          }
        }
      }
    }

    if (filesAdded == 0) {
      throw Exception('No valid files found to upload');
    }

    if (kDebugMode) {
      print('🔵 Total files added: $filesAdded');
      print('🔵 Sending request to backend...');
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 300),
        onTimeout: () {
          throw Exception(
            'Request timeout after 5 minutes. The backend might be processing large files or experiencing issues.',
          );
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('🔵 Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Analysis successful!');
        }
        final jsonResponse = json.decode(response.body);
        if (kDebugMode) {
          print('🔵 Response structure: ${jsonResponse.keys.join(", ")}');
        }
        return jsonResponse;
      } else {
        if (kDebugMode) {
          print('❌ Error response: ${response.body}');
        }
        throw Exception(
          'Backend error (${response.statusCode}): ${_parseErrorMessage(response.body)}',
        );
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Network error: $e');
      }
      throw Exception(
        'Cannot connect to backend at $baseUrl. '
        'Make sure:\n'
        '1. Backend is running (uvicorn main:app --host 0.0.0.0 --port 8000)\n'
        '2. IP address is correct in api_service.dart\n'
        '3. Device is on the same network as backend\n'
        'Error: $e',
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
      rethrow;
    }
  }

  /// Helper method to parse error messages from backend
  static String _parseErrorMessage(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      return json['detail'] ?? json['error'] ?? responseBody;
    } catch (_) {
      return responseBody;
    }
  }
}
