import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImageBytes() async {
  try {
    // WEB + DESKTOP
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // MUST for byte data
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.bytes!;
      }
      return null;
    }

    // MOBILE (Android/iOS)
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      return await picked.readAsBytes();
    }
    return null;
  } catch (e) {
    print("Image pick error: $e");
    return null;
  }
}
