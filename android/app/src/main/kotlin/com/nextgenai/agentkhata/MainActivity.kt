package com.nextgenai.agentkhata

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth (BiometricPrompt).
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Toggles FLAG_SECURE: blocks screenshots and hides the app preview
        // in the recent-apps list.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.nextgenai.agentkhata/secure",
        ).setMethodCallHandler { call, result ->
            if (call.method == "setSecure") {
                val secure = call.arguments as? Boolean ?: true
                if (secure) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
