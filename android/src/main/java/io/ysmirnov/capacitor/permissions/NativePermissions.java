package io.ysmirnov.capacitor.permissions;

import android.util.Log;

public class NativePermissions {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
