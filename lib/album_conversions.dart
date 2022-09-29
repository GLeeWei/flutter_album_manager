import 'package:album_manager/types/album_asset.dart';
import 'package:album_manager/types/asset_meta.dart';

class AlbumConversions {
  static AlbumAsset convertMapToAlbumAsset(Map<String, dynamic> data) {
    return AlbumAsset(
      id: data['id'] as String,
      title: data['title'] as String,
      mimeType: data['mimeType'] as String,
      creationDate: data['creationDate'] as int?,
      modifiedDate: data['modifiedDate'] as int?,
      latitude: data['lat'] as double?,
      longitude: data['lng'] as double?,
    );
  }

  static AssetMeta convertMapToAssetMeta(Map<String, dynamic> data) {
    return AssetMeta(
      colorModel: data['ColorModel'] as String,
      dpiWidth: data['DPIWidth'] as double,
      dpiHeight: data['DPIHeight'] as double,
      depth: data['Depth'] as int,
      pixelHeight: data['PixelHeight'] as int,
      pixelWidth: data['PixelWidth'] as int,
      profileName: data['ProfileName'] as String,
    );
  }
}
