package com.snail.album_manager;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.util.Log;

import org.jetbrains.annotations.Nullable;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import static android.app.Activity.RESULT_OK;
import static android.os.Environment.DIRECTORY_PICTURES;

class AlbumMgr {
    public interface PhotoBrowserResultListener {
        void onResult(byte[] fileBytes);
    }

    private final Activity activity;
    private final static int FILE_CHOOSER_RESULT_CODE = 10;
    private PhotoBrowserResultListener mPhotoBrowserResultListener;

    Activity getActivity() {
        return activity;
    }

    AlbumMgr(Activity a) {
        activity = a;
    }

    interface AssetResult {
        void onResult(@Nullable String error, AlbumAsset asset);
    }

    public void saveToAlbum(String path, String title, String mimeType, String albumName, AssetResult block) {
        Log.d(Constants.TAG, path + title);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContentResolver resolver = activity.getContentResolver();
            Uri contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
            ContentValues contentValues = new ContentValues();
            contentValues.put(MediaStore.Images.Media.DISPLAY_NAME, title);
            contentValues.put(MediaStore.Images.Media.MIME_TYPE, mimeType);
            contentValues.put(MediaStore.Images.Media.RELATIVE_PATH, DIRECTORY_PICTURES + "/" + albumName);
            Uri uri = resolver.insert(contentUri, contentValues);
            if (uri == null) {
                block.onResult("File not found, the file '" + title + "' saves failed", null);
                return;
            }
            try {
                OutputStream os = resolver.openOutputStream(uri);
                os.write(getFileBytes(path));
                os.flush();
                os.close();
                block.onResult(null, new AlbumAsset());
            } catch (IOException e) {
                block.onResult("The file '" + title + "' saves failed" + e.getMessage(), null);
            }
            MediaScannerConnection.scanFile(activity, new String[]{contentUri.getPath()}, new String[]{"images/*"}, null);
        } else {
            try {
                File parentDir = new File(Environment.getExternalStoragePublicDirectory(DIRECTORY_PICTURES), albumName);
                if (!parentDir.exists()) {
                    parentDir.mkdir();
                }
                File file = new File(parentDir, title);
                FileOutputStream fos = new FileOutputStream(file);
                fos.write(getFileBytes(path));
                fos.close();
                activity.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file.getAbsoluteFile())));
                block.onResult(null, new AlbumAsset());
            } catch (IOException e) {
                block.onResult("The file '" + title + "' saves failed" + e.getMessage(), null);
            }
        }
    }

    /**
     * Get a file path from a Uri. This will get the the path for Storage Access
     * Framework Documents, as well as the _data field for the MediaStore and
     * other file-based ContentProviders.
     *
     * @param context The context.
     * @param uri     The Uri to query.
     * @author paulburke
     */
    public String getDocumentFilePath(final Context context, final Uri uri) {
        if (Build.VERSION_CODES.KITKAT <= Build.VERSION.SDK_INT) {
            if (DocumentsContract.isDocumentUri(context, uri)) {
                // ExternalStorageProvider
                if (isExternalStorageDocument(uri)) {
                    final String docId = DocumentsContract.getDocumentId(uri);
                    final String[] split = docId.split(":");
                    final String type = split[0];

                    if ("primary".equalsIgnoreCase(type)) {
                        return Environment.getExternalStorageDirectory() + "/" + split[1];
                    }

                    // TODO handle non-primary volumes
                }
                // DownloadsProvider
                else if (isDownloadsDocument(uri)) {

                    final String id = DocumentsContract.getDocumentId(uri);
                    final Uri contentUri = ContentUris.withAppendedId(
                            Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));

                    return getDataColumn(context, contentUri, null, null);
                }
                // MediaProvider
                else if (isMediaDocument(uri)) {
                    final String docId = DocumentsContract.getDocumentId(uri);
                    final String[] split = docId.split(":");
                    final String type = split[0];

                    Uri contentUri = null;
                    if ("image".equals(type)) {
                        contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                    } else if ("video".equals(type)) {
                        contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                    } else if ("audio".equals(type)) {
                        contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                    }

                    final String selection = "_id=?";
                    final String[] selectionArgs = new String[]{
                            split[1]
                    };

                    return getDataColumn(context, contentUri, selection, selectionArgs);
                }
            }
            // MediaStore (and general)
            else if ("content".equalsIgnoreCase(uri.getScheme())) {
                return getDataColumn(context, uri, null, null);
            }
            // File
            else if ("file".equalsIgnoreCase(uri.getScheme())) {
                return uri.getPath();
            }
        }

        return getDataColumn(this.getActivity(), uri, null, null);
    }

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context       The context.
     * @param uri           The Uri to query.
     * @param selection     (Optional) Filter used in the query.
     * @param selectionArgs (Optional) Selection arguments used in the query.
     * @return The value of the _data column, which is typically a file path.
     */
    public String getDataColumn(Context context, Uri uri, String selection,
                                String[] selectionArgs) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {
                column
        };

        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                    null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }


    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public boolean isExternalStorageDocument(Uri uri) {
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public boolean isDownloadsDocument(Uri uri) {
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @param uri The Uri to check.
     * @return Whether the Uri authority is MediaProvider.
     */
    public boolean isMediaDocument(Uri uri) {
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }

    public byte[] getFileBytes(String imgFilePath) {
        Log.i(Constants.TAG, "imagePath =>" + imgFilePath);
        InputStream inputStream;
        Bitmap bitmap = null;
        try {
            inputStream = new FileInputStream(imgFilePath);
            bitmap = BitmapFactory.decodeStream(inputStream);
            inputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        ByteArrayOutputStream bStream = new ByteArrayOutputStream();
        try {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, bStream);
            bStream.flush();
            bStream.close();
            return bStream.toByteArray();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void openPhotoBrowser(PhotoBrowserResultListener pPhotoBrowserResultListener) {
        this.mPhotoBrowserResultListener = pPhotoBrowserResultListener;
        Intent i = new Intent(Intent.ACTION_GET_CONTENT);
        i.addCategory(Intent.CATEGORY_OPENABLE);
        i.setType("image/*");
        this.getActivity().startActivityForResult(
                Intent.createChooser(i, "File Browser"),
                FILE_CHOOSER_RESULT_CODE);
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(Constants.TAG, "onActivityResult-> " + data.getData());
        if (requestCode == FILE_CHOOSER_RESULT_CODE) {
            if (resultCode == RESULT_OK) {
                String imagePath = getDocumentFilePath(this.getActivity(), data.getData());
                if (null != imagePath) {
                    byte[] fileBytes = getFileBytes(imagePath);
                    if (null != this.mPhotoBrowserResultListener)
                        this.mPhotoBrowserResultListener.onResult(fileBytes);
                }
            }
        }
    }
}
