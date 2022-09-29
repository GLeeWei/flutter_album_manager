import '../album_conversions.dart';
import '../album_manager_platform_interface.dart';
import 'asset_meta.dart';

class AlbumAsset {
  final String id;
  final String title;
  final String mimeType;
  final int? creationDate;
  final int? modifiedDate;
  final double? latitude;
  final double? longitude;

  AlbumAsset({
    required this.id,
    required this.title,
    required this.mimeType,
    this.creationDate,
    this.modifiedDate,
    this.latitude,
    this.longitude,
  });

  /// only support image
  Future<AssetMeta?> get metas async => await _getMetas();

  static Future<AlbumAsset?> formId(String assetId) async {
    final Map<dynamic, dynamic>? result = await AlbumManagerPlatform.instance.getAsset(assetId);
    if (null == result) return null;
    return AlbumConversions.convertMapToAlbumAsset(result.cast<String, dynamic>());
  }

  _getMetas() async {
    var re = RegExp(r'image');
    if (null == re.matchAsPrefix(mimeType)) return AssetMeta();
    final Map<dynamic, dynamic>? result = await AlbumManagerPlatform.instance.getAssetMeta(id);
    if (null == result) return null;
    return AlbumConversions.convertMapToAssetMeta(result.cast<String, dynamic>());
  }
}
