package com.jzoom.flutterjpush;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

public class Logger {

    public static boolean SHUTDOWNLOG = true;
    public static boolean SHUTDOWNTOAST = true;

    public static void i(String tag, String msg) {
        if (!SHUTDOWNLOG) {
            Log.i(tag, msg);
        }
    }

    public static void d(String tag, String msg) {
        if (!SHUTDOWNLOG) {
            Log.d(tag, msg);
        }
    }

    public static void toast(Context context, String msg) {
        if (!SHUTDOWNTOAST) {
            Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
        }
    }
}
