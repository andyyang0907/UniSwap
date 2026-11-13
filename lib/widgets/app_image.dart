import 'dart:io';

import 'package:flutter/widgets.dart';

/// Unified image source resolver.
/// - `assets/...` → bundled asset
/// - `http(s)://...` → network image
/// - otherwise → local file path (picked by image_picker)
ImageProvider appImageProvider(String path) {
  if (path.startsWith('assets/')) return AssetImage(path);
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}
