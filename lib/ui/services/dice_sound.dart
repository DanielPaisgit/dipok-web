import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Audio service for dice rolling, landing, and scoring sounds.
/// Uses real WAV files via audioplayers + haptic feedback on mobile.
class DiceSoundService {
  static final DiceSoundService _instance = DiceSoundService._();
  factory DiceSoundService() => _instance;
  DiceSoundService._();

  final _rollPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
  final _landPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
  final _scorePlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

  /// Play dice rolling rattle.
  Future<void> playRollSound() async {
    HapticFeedback.lightImpact();
    await _rollPlayer.stop();
    await _rollPlayer.play(AssetSource('audio/dice_roll.wav'));
  }

  /// Play landing thud when dice settle.
  Future<void> playLandSound() async {
    HapticFeedback.heavyImpact();
    await _landPlayer.stop();
    await _landPlayer.play(AssetSource('audio/dice_land.wav'));
  }

  /// Play ding when a score is registered.
  Future<void> playScoreSound() async {
    HapticFeedback.mediumImpact();
    await _scorePlayer.stop();
    await _scorePlayer.play(AssetSource('audio/score.wav'));
  }
}
