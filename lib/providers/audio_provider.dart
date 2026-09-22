import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProvider = NotifierProvider<AudioNotifier, bool>(() => AudioNotifier());

class AudioNotifier extends Notifier<bool> {
  final AudioPlayer _player = AudioPlayer();
  
  @override
  bool build() {
    _initAudio();
    return true; // true = Playing, false = Muted
  }

  Future<void> _initAudio() async {
    _player.setReleaseMode(ReleaseMode.loop); // বারবার বাজবে
    // একটি অনলাইন রিলাক্সিং সাউন্ড
    await _player.play(UrlSource('https://cdn.pixabay.com/download/audio/2022/02/07/audio_13bdf2d308.mp3'));
  }

  void toggleMute() {
    if (state) {
      _player.pause();
    } else {
      _player.resume();
    }
    state = !state;
  }
}