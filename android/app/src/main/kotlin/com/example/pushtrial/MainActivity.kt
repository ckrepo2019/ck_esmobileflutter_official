package com.ckessentiel.pushtrial

import io.flutter.embedding.android.FlutterActivity
import android.util.Log

class MainActivity : FlutterActivity() {
    
    companion object {
        // Load the native library for 16 KB page size support
        init {
            try {
                System.loadLibrary("pushtrial")
                Log.i("MainActivity", "Native library loaded successfully for 16 KB page support")
            } catch (e: UnsatisfiedLinkError) {
                Log.w("MainActivity", "Native library not found, continuing without 16 KB specific optimizations")
            }
        }
    }
    
    // Native method declarations
    external fun stringFromJNI(): String
    external fun supports16KBPages(): Boolean
}
