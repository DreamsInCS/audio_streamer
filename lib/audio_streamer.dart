import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/** A [AudioStreamer] object is reponsible for connecting
 * to the native environment and streaming audio from the microphone.**/
const String EVENT_CHANNEL_NAME = 'audio_streamer.eventChannel';

class AudioStreamer {
  static const INT16_MAX = 32767;
  bool _isRecording = false;
  bool debug = false;

  AudioStreamer({this.debug = false});

  int get sampleRate => 22050;

  static const EventChannel _noiseEventChannel =
      EventChannel(EVENT_CHANNEL_NAME);

  // Stream<List<double>> _stream;
  Stream<List<int>> _stream;
  StreamSubscription<List<dynamic>> _subscription;

  void _print(String t) {
    if (debug) print(t);
  }

  // Stream<List<double>> get audioStream {
  Stream<List<int>> get audioStream {
    if (_stream == null) {
      _stream = _noiseEventChannel
          .receiveBroadcastStream()
          .map((buffer) => buffer as List<dynamic>)
          // .map((list) => list.map((e) => double.parse('$e')).toList());
          .map((list) {
        if (Platform.isAndroid) {
          return list.map((e) => int.parse('$e')).toList();
        } else /*if (Platform.isIOS)*/ {
          return list
              .map((e) => (double.parse('$e') * INT16_MAX).toInt())
              .toList();
        }
      });
    }
    return _stream;
  }

  Future<bool> start(Function onData) async {
    _print('AudioStreamer: startRecorder()');

    if (_isRecording) {
      print('AudioStreamer: Already recording!');
      return _isRecording;
    } else {
      try {
        _isRecording = true;
        _subscription = audioStream.listen(onData);
      } catch (err) {
        _print('AudioStreamer: startRecorder() error: $err');
      }
    }
    return _isRecording;
  }

  Future<bool> stop() async {
    _print('AudioStreamer: stopRecorder()');
    try {
      if (_subscription != null) {
        _subscription.cancel();
        _subscription = null;
      }
      _isRecording = false;
    } catch (err) {
      _print('AudioStreamer: stopRecorder() error: $err');
    }
    return _isRecording;
  }
}
