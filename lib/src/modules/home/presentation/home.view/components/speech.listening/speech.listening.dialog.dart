import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import 'speech.recognizer.dart';

/// Voice input as a draft: what you say is shown here only, and returned
/// (as the dialog's result) when you tap Insert. Cancel returns null.
///
/// Each tap of the mic records one phrase. Try again discards the phrase in
/// progress, or the last one when stopped, and waits for the mic.
class SpeechListeningDialog extends StatefulWidget {
  const SpeechListeningDialog({super.key, required this.languageCode, this.recognizer});

  /// The source language, e.g. "fr"; matched to a device speech locale.
  final String languageCode;

  /// Test seam; defaults to the speech_to_text plugin.
  final SpeechRecognizer? recognizer;

  @override
  State<SpeechListeningDialog> createState() => _SpeechListeningDialogState();
}

enum _Status { starting, listening, idle, unavailable }

class _SpeechListeningDialogState extends State<SpeechListeningDialog> {
  late final SpeechRecognizer _recognizer = widget.recognizer ?? PluginSpeechRecognizer();

  final List<String> _phrases = [];
  String _partial = '';
  _Status _status = _Status.starting;
  String? _message;
  String? _localeId;

  /// Bumped for every listen and on Try again or close, so results from an
  /// earlier session are ignored.
  int _session = 0;

  /// The session whose phrase is last in [_phrases]. A session adds at most
  /// one phrase: a later final result for it replaces that phrase instead of
  /// adding it again (stop keeps the words heard so far, then the recognizer
  /// usually sends the final result too).
  int? _lastPhraseSession;

  void _keepPhrase(int session, String words) {
    final phrase = words.trim();
    if (session == _lastPhraseSession && _phrases.isNotEmpty) {
      if (phrase.isNotEmpty) _phrases[_phrases.length - 1] = phrase;
      return;
    }
    if (phrase.isEmpty) return;
    _phrases.add(phrase);
    _lastPhraseSession = session;
  }

  String get _draft => [..._phrases, _partial].where((phrase) => phrase.trim().isNotEmpty).join(' ');

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _session++;
    _recognizer.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final available = await _recognizer.initialize(onError: _onError, onStatus: _onStatus);
      if (!mounted) return;
      if (!available) {
        return _setUnavailable("Voice input isn't available. Check that microphone access is allowed in Settings.");
      }
      final localeId = matchSpeechLocale(
        widget.languageCode,
        await _recognizer.localeIds(),
        await _recognizer.systemLocaleId(),
      );
      if (!mounted) return;
      if (localeId == null) {
        return _setUnavailable("Voice input isn't available for this language on this device.");
      }
      _localeId = localeId;
      await _startListening();
    } catch (error, stackTrace) {
      debugPrint('Voice input failed to start: $error\n$stackTrace');
      if (mounted) _setUnavailable("Voice input isn't available right now.");
    }
  }

  void _setUnavailable(String message) {
    setState(() {
      _status = _Status.unavailable;
      _message = message;
    });
  }

  Future<void> _startListening() async {
    final session = ++_session;
    setState(() {
      _partial = '';
      _message = null;
      _status = _Status.listening;
    });
    await _recognizer.listen(
      localeId: _localeId!,
      onResult: (words, isFinal) {
        if (session != _session || !mounted) return;
        setState(() {
          if (isFinal) {
            _keepPhrase(session, words);
            _partial = '';
            _status = _Status.idle;
          } else if (session != _lastPhraseSession) {
            _partial = words;
          }
        });
      },
    );
  }

  /// Ends the phrase in progress, keeping what was heard so far if the
  /// recognizer finishes without a final result.
  void _endPhrase() {
    _keepPhrase(_session, _partial);
    _partial = '';
    _status = _Status.idle;
  }

  void _onStatus(String status) {
    if (!mounted || _status != _Status.listening) return;
    if (status == 'done' || status == 'notListening') setState(_endPhrase);
  }

  void _onError(String errorCode) {
    debugPrint('Voice input error: $errorCode');
    if (!mounted || _status == _Status.unavailable) return;
    setState(() {
      _partial = '';
      _status = _Status.idle;
      _message = speechErrorMessage(errorCode);
    });
  }

  Future<void> _onMicPressed() async {
    if (_status == _Status.listening) {
      await _recognizer.stop();
      if (mounted && _status == _Status.listening) setState(_endPhrase);
      return;
    }
    await _startListening();
  }

  /// Discards the phrase in progress, or the last one when stopped. Doesn't
  /// start listening: the user taps the mic when ready.
  Future<void> _onTryAgain() async {
    if (_status == _Status.listening) {
      _session++; // ignore the rest of this phrase
      await _recognizer.cancel();
      if (!mounted) return;
      setState(() {
        _partial = '';
        _status = _Status.idle;
      });
      return;
    }
    // End the stopped session too, so a late final result can't replace the
    // phrase before the one removed here.
    _session++;
    if (_phrases.isNotEmpty) setState(_phrases.removeLast);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listening = _status == _Status.listening;
    final canRecord = _status == _Status.listening || _status == _Status.idle;
    final draft = _draft;

    final String placeholder = switch (_status) {
      _Status.starting => 'Starting…',
      _Status.listening => 'Listening…',
      _Status.idle => 'Tap the mic and speak.',
      _Status.unavailable => '',
    };

    return AlertDialog(
      title: const Text('Voice input'),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72, maxHeight: 200),
              child: SingleChildScrollView(
                reverse: true,
                child: draft.isEmpty
                    ? Text(placeholder, style: TextStyle(color: theme.hintColor))
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: _phrases.join(' ')),
                            if (_partial.trim().isNotEmpty)
                              TextSpan(
                                text: '${_phrases.isEmpty ? '' : ' '}$_partial',
                                style: TextStyle(color: theme.hintColor),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(_message!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            if (canRecord) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Try again',
                    onPressed: listening || _phrases.isNotEmpty ? _onTryAgain : null,
                    icon: const Icon(Icons.replay),
                  ),
                  const SizedBox(width: 16),
                  AvatarGlow(
                    animate: listening,
                    child: FloatingActionButton(
                      heroTag: null,
                      tooltip: listening ? 'Stop' : 'Speak',
                      onPressed: _onMicPressed,
                      shape: const CircleBorder(),
                      child: Icon(listening ? Icons.stop : Icons.mic_none),
                    ),
                  ),
                  // Balances the Try again button so the mic stays centred.
                  const SizedBox(width: 64),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: draft.isEmpty ? null : () => Navigator.pop(context, draft),
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
