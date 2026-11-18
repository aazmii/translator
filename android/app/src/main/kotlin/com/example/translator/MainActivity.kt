package com.example.translator

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.speech.RecognizerIntent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    /// The Dart call waiting for the system speech dialog, if one is open.
    private var pendingSpeech: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "recognize") {
                    recognize(call.argument<String>("language"), result)
                } else {
                    result.notImplemented()
                }
            }
    }

    /// Opens the system (Google) speech dialog. Replies with a map:
    /// {"status": "ok", "text": ...} or {"status": "cancelled" | "unavailable" | "busy" | "error", "code": ...}.
    private fun recognize(language: String?, result: MethodChannel.Result) {
        if (pendingSpeech != null) {
            result.success(mapOf("status" to "busy"))
            return
        }
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            if (!language.isNullOrBlank()) {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, language)
            }
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            // Ask to finish after 2 s of silence. The Google app may ignore these.
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, SILENCE_MILLIS)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, SILENCE_MILLIS)
        }
        if (intent.resolveActivity(packageManager) == null) {
            Log.i(TAG, "No system speech dialog on this device")
            result.success(mapOf("status" to "unavailable"))
            return
        }
        pendingSpeech = result
        try {
            startActivityForResult(intent, SPEECH_REQUEST)
            Log.i(TAG, "System speech dialog opened (language=$language)")
        } catch (e: ActivityNotFoundException) {
            pendingSpeech = null
            Log.i(TAG, "System speech dialog not found", e)
            result.success(mapOf("status" to "unavailable"))
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != SPEECH_REQUEST) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingSpeech ?: return
        pendingSpeech = null
        val reply: Map<String, Any?> = when (resultCode) {
            Activity.RESULT_OK -> {
                val text = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()
                if (text.isNullOrBlank()) mapOf("status" to "error", "code" to "no_match")
                else mapOf("status" to "ok", "text" to text)
            }
            Activity.RESULT_CANCELED -> mapOf("status" to "cancelled")
            RecognizerIntent.RESULT_NO_MATCH -> mapOf("status" to "error", "code" to "no_match")
            RecognizerIntent.RESULT_NETWORK_ERROR -> mapOf("status" to "error", "code" to "network")
            RecognizerIntent.RESULT_SERVER_ERROR -> mapOf("status" to "error", "code" to "server")
            RecognizerIntent.RESULT_AUDIO_ERROR -> mapOf("status" to "error", "code" to "audio")
            RecognizerIntent.RESULT_CLIENT_ERROR -> mapOf("status" to "error", "code" to "client")
            else -> mapOf("status" to "error", "code" to "result_$resultCode")
        }
        Log.i(TAG, "System speech dialog closed: ${reply["status"]} ${reply["code"] ?: ""}")
        result.success(reply)
    }

    private companion object {
        const val TAG = "SystemSpeech"
        const val SPEECH_CHANNEL = "go_translator/system_speech"
        const val SPEECH_REQUEST = 4711
        const val SILENCE_MILLIS = 2000L
    }
}
