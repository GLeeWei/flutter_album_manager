package com.snail.album_manager;


import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.SparseArray;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.PluginRegistry;

import java.util.ArrayList;
import java.util.List;

public class Permission implements PluginRegistry.RequestPermissionsResultListener {
    private final SparseArray<RequestPermissionCallback> permissionCallbackArray = new SparseArray<>();
    private final Activity activity;


    Permission(Activity act) {
        activity = act;
    }

    /**
     * 申请成功的回调接口
     */
    public interface RequestPermissionCallback {
        void onRequestCallback(boolean success);
    }

    public int generateDynamicRequestCode(Object object) {
        return object.getClass().hashCode() >> 1;
    }


    @RequiresApi(api = Build.VERSION_CODES.M)
    String[] findDeniedPermissions(String... permissions) {
        List<String> permissionList = new ArrayList<>();
        for (String perm : permissions) {
            if (ContextCompat.checkSelfPermission(activity, perm) !=
                    PackageManager.PERMISSION_GRANTED) {
                permissionList.add(perm);
            }
        }
        return permissionList.toArray(new String[permissionList.size()]);
    }

    public void hasPermissions(int requestCode, RequestPermissionCallback callback, String... permissions) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            String[] deniedPermissions = findDeniedPermissions(permissions);
            if (deniedPermissions.length > 0) {
                this.permissionCallbackArray.put(requestCode, callback);
                ActivityCompat.requestPermissions(activity, permissions, requestCode);
            } else {
                if (null != callback)
                    callback.onRequestCallback(true);
            }
        } else {
            if (null != callback)
                callback.onRequestCallback(true);
        }
    }

    private boolean verifyPermissions(int[] grantResults) {
        for (int result : grantResults)
            if (PackageManager.PERMISSION_GRANTED != result)
                return false;
        return true;
    }

    /**
     * 当被用户拒绝授权并且出现不再提示时
     * shouldShowRequestPermissionRationale也会返回false，若实在必须申请权限时可以使用方法检测，
     */
    protected boolean verifyShouldShowRequestPermissions(String[] permissions) {
        for (String permission : permissions) {
            if (!ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)) {
                return false;
            }
        }
        return true;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        boolean grandResult = verifyPermissions(grantResults);
        RequestPermissionCallback callback = this.permissionCallbackArray.get(requestCode);
        if (null != callback) {
            if (grandResult) {
                callback.onRequestCallback(true);
            } else {
                callback.onRequestCallback(this.verifyShouldShowRequestPermissions(permissions));
            }
        }
        return grandResult;
    }
}
