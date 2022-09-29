# album_manager


A Flutter plugin that provides assets abstraction management APIs without UI integration,
you can get assets (image/video/audio) on Android, iOS and macOS.

## Getting Started
## Permission

* ### Android

Add the following statement in `AndroidManifest.xml`:
```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
* ### iOS

Add the following statement in `Info.plist`
```
<key>NSPhotoLibraryUsageDescription</key>
<string>Add the description of the permission you need here.</string>
```

## Usage
See [Example]()

```
// Save to album.
bool success = await AlbumManager.saveToAlbum(savePath, title: name, mimeType: 'image/png', albumName: 'image_sync');
```
