import 'dart:io';

import 'album_manager_platform_interface.dart';

class AlbumManager {
  AlbumManager._();

  static Future<String?> getPlatformVersion() {
    return AlbumManagerPlatform.instance.getPlatformVersion();
  }

  static Future<bool?> saveToAlbum(String path,
      {required String title, required String mimeType, String? albumName}) async {
    final File file = File(path);
    if (!file.existsSync()) {
      assert(false, 'File must exists.');
      return false;
    }
    if (mimeType.startsWith('video')) {
      path = file.absolute.path;
    }
    return await AlbumManagerPlatform.instance
        .saveToAlbum(path, title: title, mimeType: mimeType, albumName: albumName);
  }
}
