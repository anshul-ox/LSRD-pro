# File Upload Feature - Installation Guide

## Overview
This guide shows how to add file picker functionality to your LSR application, allowing users to select documents from their device.

## Step 1: Add Dependencies

Add the `file_picker` package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  file_picker: ^8.0.0  # Add this line
  
  # Your other dependencies...
```

Then run:
```bash
flutter pub get
```

## Step 2: Platform-Specific Setup

### Android Setup

1. **Update `android/app/build.gradle`:**

```gradle
android {
    compileSdkVersion 34  // Make sure this is at least 33
    
    defaultConfig {
        minSdkVersion 21  // File picker requires minimum SDK 21
        targetSdkVersion 34
    }
}
```

2. **Update `android/app/src/main/AndroidManifest.xml`:**

Add these permissions inside the `<manifest>` tag (before `<application>`):

```xml
<!-- Required for accessing storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- For Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
```

### iOS Setup

1. **Update `ios/Podfile`:**

Make sure you have this at the top:

```ruby
platform :ios, '12.0'  # File picker requires iOS 12.0+
```

2. **Update `ios/Runner/Info.plist`:**

Add these keys inside the `<dict>` tag:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload documents</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to capture documents</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for video recording</string>
```

Then run:
```bash
cd ios
pod install
cd ..
```

### Web Setup

No additional setup required for web! File picker works out of the box.

## Step 3: Update Your Code

Replace your `lsr_create_screen.dart` with the new file that includes file picker functionality.

### Key Changes:

1. **Import statement added:**
```dart
import 'package:file_picker/file_picker.dart';
import 'dart:io';
```

2. **New DocumentUpload model:**
```dart
class DocumentUpload {
  final bool isUploaded;
  final String fileName;
  final String filePath;
  final int fileSize;

  DocumentUpload({
    this.isUploaded = false,
    this.fileName = '',
    this.filePath = '',
    this.fileSize = 0,
  });
}
```

3. **Updated document tracking:**
```dart
Map<String, DocumentUpload> _uploadedDocuments = {
  'Jamabandi': DocumentUpload(),
  'Sale Deed': DocumentUpload(),
  'Patta/Mother Title': DocumentUpload(),
  'Mutation Record': DocumentUpload(),
};
```

4. **File picker method:**
```dart
Future<void> _pickDocument(String documentType) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _uploadedDocuments[documentType] = DocumentUpload(
          isUploaded: true,
          fileName: result.files.single.name,
          filePath: result.files.single.path!,
          fileSize: result.files.single.size,
        );
      });
    }
  } catch (e) {
    // Handle error
  }
}
```

## Features Included

### 1. File Selection
- Click "Upload" button to open file picker
- Select from PDF, JPG, JPEG, PNG files
- Shows file name and size after upload

### 2. File Management
- **Replace**: Upload a different file
- **Remove**: Delete uploaded file (X button)
- Visual feedback with success/error messages

### 3. Upload Summary
- Shows count of uploaded documents
- Color-coded status (green when all uploaded, yellow when incomplete)
- Requires minimum 2 documents to proceed

### 4. File Information Display
- File name with ellipsis for long names
- File size formatted (B, KB, MB)
- Visual indicators (check mark for uploaded files)

## Supported File Types

- **PDF**: `.pdf`
- **Images**: `.jpg`, `.jpeg`, `.png`

Maximum file size: 10MB per file (enforced at validation level)

## Usage Example

```dart
// When user clicks upload button
_pickDocument('Jamabandi');

// Access uploaded file data
String filePath = _uploadedDocuments['Jamabandi']?.filePath ?? '';
String fileName = _uploadedDocuments['Jamabandi']?.fileName ?? '';
int fileSize = _uploadedDocuments['Jamabandi']?.fileSize ?? 0;
```

## Integration with AI Processing

When you're ready to process the documents with AI, you can access all uploaded files:

```dart
void _processDocumentsWithAI() async {
  List<File> documentsToProcess = [];
  
  _uploadedDocuments.forEach((key, upload) {
    if (upload.isUploaded) {
      documentsToProcess.add(File(upload.filePath));
    }
  });
  
  // Send to your AI service
  final result = await yourAIService.analyzeDocuments(documentsToProcess);
}
```

## Validation

The app requires at least 2 documents to be uploaded before proceeding to the next step:

```dart
bool _canProceed() {
  switch (_currentStep) {
    case 1: // Upload Documents step
      return _uploadedDocuments.values
          .where((doc) => doc.isUploaded)
          .length >= 2;
    // ...
  }
}
```

## Troubleshooting

### Issue: "Permission denied" on Android
**Solution**: Make sure you've added all required permissions in `AndroidManifest.xml`

### Issue: File picker doesn't open on iOS
**Solution**: 
1. Check that `Info.plist` has the required keys
2. Run `pod install` in the ios folder
3. Clean and rebuild: `flutter clean && flutter pub get`

### Issue: "Platform not supported"
**Solution**: Update file_picker to the latest version: `flutter pub upgrade file_picker`

### Issue: Large files cause app to crash
**Solution**: Add file size validation before upload:

```dart
if (result.files.single.size > 10 * 1024 * 1024) { // 10MB
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('File too large. Maximum 10MB allowed')),
  );
  return;
}
```

## Testing Checklist

- [ ] File picker opens when clicking Upload button
- [ ] Can select PDF files
- [ ] Can select image files (JPG, PNG)
- [ ] File name displays correctly
- [ ] File size shows in readable format
- [ ] Replace button works
- [ ] Remove button works
- [ ] Upload summary updates correctly
- [ ] Cannot proceed without minimum 2 files
- [ ] Success message shows after upload
- [ ] Error message shows on failure

## Next Steps

After implementing file upload:
1. Connect to your backend/AI service to process documents
2. Add file size validation (max 10MB)
3. Add image compression for large images
4. Implement cloud storage upload if needed
5. Add progress indicator for large file uploads

## Additional Features (Optional)

### Multiple File Selection
To allow selecting multiple files at once:

```dart
FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  allowMultiple: true,  // Changed to true
);

if (result != null) {
  for (var file in result.files) {
    // Process each file
  }
}
```

### Camera Capture
To allow direct camera capture:

```dart
// You'll need image_picker package for this
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();
final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
```

### File Preview
Add ability to preview uploaded documents before processing.

## Support

For more information about file_picker package:
- Documentation: https://pub.dev/packages/file_picker
- GitHub Issues: https://github.com/miguelpruivo/flutter_file_picker/issues
