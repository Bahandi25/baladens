import 'package:just_audio/just_audio.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound(String fileName) async {
    try {
      await _player.setAsset('assets/sounds/$fileName');
      await _player.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }
}
