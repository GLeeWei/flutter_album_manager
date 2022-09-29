import 'dart:typed_data';

import 'package:album_manager/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'album_manager_platform_interface.dart';

/// An implementation of [AlbumManagerPlatform] that uses method channels.
class MethodChannelAlbumManager extends AlbumManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('album_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Save media to album.
  /// [path] media file path.
  /// [title] media name, such as a.jpg, b.mp4 and so on.
  /// [mimeType] media mimeType
  /// [albumName] Album name, optional. For Android, default application name. For iOS, default system album.
  /// [overwriteSameNameFile] Only works on Android. If <code>true</code>, overwrite the original file that has same name, default <code>true</code>.
  @override
  Future<bool?> saveToAlbum(String path,
      {required String title, required String mimeType, String? albumName}) async {
    bool? success = false;
    try {
      success = await methodChannel.invokeMethod<bool>(AlbumConstants.mSaveToAlbum,
          {'path': path, 'title': title, 'mimeType': mimeType, 'albumName': albumName});
    } on PlatformException {
      rethrow;
    }
    return success;
  }

  @override
  Future<Map<dynamic, dynamic>?> getAsset(String assetId, {bool? withCache}) async {
    return methodChannel.invokeMethod(AlbumConstants.mGetAsset, {'assetId': assetId, 'withCache': withCache});
  }

  @override
  Future<Map<dynamic, dynamic>?> getAssetMeta(String id) {
    return methodChannel.invokeMethod(AlbumConstants.mGetAssetMeta, {'id': id});
  }
}
