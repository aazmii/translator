import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechListeningDialog extends StatefulWidget {
  const SpeechListeningDialog({super.key, this.initialText, this.localeId, this.onTextChanged});

  final String? initialText;
  final String? localeId;
  final ValueChanged<String>? onTextChanged;

  @override
  State<SpeechListeningDialog> createState() => _SpeechListeningDialogState();
}

class _SpeechListeningDialogState extends State<SpeechListeningDialog> {
  final SpeechToText _speech = SpeechToText();
  final SpeechListenOptions _listenOptions = SpeechListenOptions(
    listenMode: ListenMode.dictation,
    onDevice: false,
    cancelOnError: true,
    partialResults: true,
    autoPunctuation: true,
    enableHapticFeedback: true,
  );

  bool _speechEnabled = false;
  bool _isListening = false;
  String _recognizedWords = '';
  String _lastError = '';

  @override
  void initState() {
    super.initState();
    _recognizedWords = widget.initialText ?? '';
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final hasSpeech = await _speech.initialize(onError: _onError, onStatus: _onStatus);
      if (!mounted) return;
      setState(() {
        _speechEnabled = hasSpeech;
      });
      if (hasSpeech) {
        await _startListening();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _speechEnabled = false;
        _lastError = e.toString();
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_recognizedWords.isNotEmpty) setState(() => _recognizedWords = '');
    if (!_speechEnabled) return;

    if (_speech.isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      return;
    }

    await _startListening();
  }

  Future<void> _startListening() async {
    setState(() {
      _lastError = '';
    });

    await _speech.listen(
      onResult: _onResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 8),
      localeId: widget.localeId,
      listenOptions: _listenOptions,
    );

    if (!mounted) return;
    setState(() {
      _isListening = true;
    });
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted || result.recognizedWords.isEmpty) return;
    setState(() {
      _recognizedWords = result.recognizedWords;
    });
    widget.onTextChanged?.call(_recognizedWords);
  }

  void _onError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() {
      _lastError = error.errorMsg;
      _isListening = false;
    });
  }

  void _onStatus(String status) {
    if (!mounted) return;
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Voice input'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: SizedBox(
          width: 280,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 88),
                  child: Text(
                    _recognizedWords.isEmpty
                        ? (_speechEnabled ? 'Tap mic and start speaking...' : 'Speech is unavailable')
                        : _recognizedWords,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: AvatarGlow(
                    animate: _isListening,
                    child: FloatingActionButton(
                      onPressed: _toggleListening,
                      shape: const CircleBorder(),
                      child: Icon(_isListening ? Icons.stop : Icons.mic_none),
                    ),
                  ),
                ),
              ),
              if (_lastError.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 72,
                  child: Text(_lastError, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
