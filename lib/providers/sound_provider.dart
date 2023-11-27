import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider with ChangeNotifier {
  bool _isSoundTurnedOn = true;
  bool _isMusicTurnedOn = true;
  bool _isQuizMusicPlaying = false;

  AudioProvider() {
    _loadFromPrefs();
  }

  bool get isSoundTurnedOn => _isSoundTurnedOn;
  bool get isMusicTurnedOn => _isMusicTurnedOn;
  bool get isQuizMusicPlaying => _isQuizMusicPlaying;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedSound = prefs.getBool("isSoundPlaying");
    if (storedSound != null) {
      _isSoundTurnedOn = storedSound;
      notifyListeners();
    }
    final storedMusic = prefs.getBool("isMusicTurnedOn");
    if (storedMusic != null) {
      _isMusicTurnedOn = storedMusic;
      notifyListeners();
    }
  }

  void switchIsSounsPlaying() {
    if (_isSoundTurnedOn) {
      _isSoundTurnedOn = false;
    } else {
      _isSoundTurnedOn = true;
    }
    _saveSoundToPrefs();
    notifyListeners();
  }

  void musicPlayingTrue() {
    _isMusicTurnedOn = true;
    _saveMusicToPrefs();
    notifyListeners();
  }

  void musicPlayingFalse() {
    _isMusicTurnedOn = false;
    _saveMusicToPrefs();
    notifyListeners();
  }

  void quizMusicPlayingTrue() {
    _isQuizMusicPlaying = true;
  }

  void quizMusicPlayingFalse() {
    _isQuizMusicPlaying = false;
  }

  Future<void> _saveSoundToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundPlaying', _isSoundTurnedOn);
  }

  Future<void> _saveMusicToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicTurnedOn', _isMusicTurnedOn);
  }

  final musicpPlayer = AudioPlayer();
  final quizMusicPlayer = AudioPlayer();
  final player = AudioPlayer();

  void tap() async {
    await player.stop();
    await player.setVolume(0.8);
    await player.play(AssetSource(
      'audio/tap.wav',
    ));
  }

  void win() async {
    await player.stop();
    await player.setVolume(0.8);
    await player.play(AssetSource(
      'audio/success1.mp3',
    ));
  }

  void wrong() async {
    await player.stop();
    await player.setVolume(0.8);
    await player.play(AssetSource(
      'audio/fail1.mp3',
    ));
  }

  void ans() async {
    await player.stop();
    await player.setVolume(0.8);
    await player.play(AssetSource(
      'audio/show_ans.mp3',
    ));
  }

  Future<void> playMusic() async {
    await musicpPlayer.setVolume(0.8);
    await musicpPlayer.setReleaseMode(ReleaseMode.loop);
    await musicpPlayer.play(AssetSource(
      'audio/music_bg.mp3',
    ));
  }

  Future<void> stopMusic() async {
    musicpPlayer.stop();
  }

  Future<void> playQuizMusic() async {
    await quizMusicPlayer.setVolume(0.8);
    await quizMusicPlayer.setReleaseMode(ReleaseMode.loop);
    await quizMusicPlayer.play(AssetSource(
      'audio/quiz_music.mp3',
    ));
  }

  Future<void> stopQuizMusic() async {
    quizMusicPlayer.stop();
  }
}
