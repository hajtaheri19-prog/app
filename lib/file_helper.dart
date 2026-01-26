// Helper file for file operations
// This file handles file operations differently for web and mobile

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';

// Conditional import
import 'dart:io' if (dart.library.html) 'dart:html' as io;

Future<XFile?> saveImageForShare(Uint8List imageBytes, String fileName) async {
  if (kIsWeb) {
    // در وب نمی‌توانیم فایل ذخیره کنیم، null برمی‌گردانیم
    return null;
  } else {
    // برای موبایل: ذخیره در فایل موقت
    final tempDir = await getTemporaryDirectory();
    final file = io.File('${tempDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);
    return XFile(file.path);
  }
}

