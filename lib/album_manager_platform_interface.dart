import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'album_manager_method_channel.dart';

abstract class AlbumManagerPlatform extends PlatformInterface {
  /// Constructs a AlbumManagerPlatform.
  AlbumManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static AlbumManagerPlatform _instance = MethodChannelAlbumManager();

  /// The default instance of [AlbumManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelAlbumManager].
  static AlbumManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AlbumManagerPlatform] when
  /// they register themselves.
  static set instance(AlbumManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> saveToAlbum(String path, {required String title, required String mimeType, String? albumName})  {
    throw UnimplementedError('saveToAlbum() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> getAsset(String assetId, {bool ?withCache}) {
    throw UnimplementedError('getAsset() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>?> getAssetMeta(String id) {
    throw UnimplementedError('getAssetMeta() has not been implemented.');
  }
}
