class AssetMeta {
  final String colorModel;
  final double dpiHeight;
  final double dpiWidth;
  final int? depth;
  final int pixelHeight;
  final int pixelWidth;
  final String profileName;

  AssetMeta(
      {this.colorModel = '',
      this.dpiHeight = 0,
      this.dpiWidth = 0,
      this.depth = 0,
      this.pixelHeight = 0,
      this.pixelWidth = 0,
      this.profileName = ''});
}
