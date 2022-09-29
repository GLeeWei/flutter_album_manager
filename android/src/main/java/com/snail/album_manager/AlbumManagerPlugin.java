package com.snail.album_manager;

import android.Manifest;
import android.app.Activity;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AlbumManagerPlugin
 */
public class AlbumManagerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Handler mainThreadHandler;
    ;
    private Permission permission;
    private AlbumMgr albumMgr;
    private static final int writePermission = 100;
    private ActivityPluginBinding activityPluginBinding;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "album_manager");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("saveToAlbum")) {
            Log.d(Constants.TAG, "saveToAlbum");
            permission.hasPermissions(writePermission, success -> {
                Log.d(Constants.TAG, "onRequestCallback" + success);
                if (success) {
                    runOnMainThread(new Runnable() {
                        @Override
                        public void run() {
                            saveToAlbum(call, result);
                        }
                    });
                } else {
                    result.error(String.valueOf(ErrorCode.PermissionDenied), "Write permission denied", null);
                }
            }, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        } else {
            result.notImplemented();
        }
    }

    private void saveToAlbum(@NonNull MethodCall call, @NonNull Result result) {
        String path = call.argument("path");
        String title = call.argument("title");
        String mimeType = call.argument("mimeType");
        String albumName = call.argument("albumName");
        albumMgr.saveToAlbum(path, title, mimeType, albumName, new AlbumMgr.AssetResult() {
            @Override
            public void onResult(@Nullable String error, AlbumAsset asset) {
                if (null != error) result.error("0", error, null);
                else result.success(true);
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    void runOnMainThread(Runnable r) {
        mainThreadHandler.post(r);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityPluginBinding = binding;
        final Activity activity = binding.getActivity();
        mainThreadHandler = new Handler(activity.getMainLooper());
        permission = new Permission(activity);
        binding.addRequestPermissionsResultListener(permission);
        albumMgr = new AlbumMgr(activity);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        activityPluginBinding.removeRequestPermissionsResultListener(permission);
        activityPluginBinding = null;
        permission = null;
        albumMgr = null;
    }

}
