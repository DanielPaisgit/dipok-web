// ignore_for_file: avoid_print
/// Generates WAV sound assets for Dipok.
/// Run with: dart run tool/generate_sounds.dart

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final dir = Directory('assets/audio');
  dir.createSync(recursive: true);

  _generateDiceRoll('assets/audio/dice_roll.wav');
  _generateDiceLand('assets/audio/dice_land.wav');
  _generateScore('assets/audio/score.wav');

  print('All sound files generated in assets/audio/');
}

// ---------------------------------------------------------------------------
// WAV encoder
// ---------------------------------------------------------------------------

Uint8List _makeWav(List<double> samples, int sampleRate) {
  final numSamples = samples.length;
  final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
  final fileSize = 44 + dataSize;

  final buffer = ByteData(fileSize);

  // RIFF header
  _writeAscii(buffer, 0, 'RIFF');
  buffer.setUint32(4, fileSize - 8, Endian.little);
  _writeAscii(buffer, 8, 'WAVE');

  // fmt chunk
  _writeAscii(buffer, 12, 'fmt ');
  buffer.setUint32(16, 16, Endian.little); // chunk size
  buffer.setUint16(20, 1, Endian.little); // PCM format
  buffer.setUint16(22, 1, Endian.little); // mono
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  buffer.setUint16(32, 2, Endian.little); // block align
  buffer.setUint16(34, 16, Endian.little); // bits per sample

  // data chunk
  _writeAscii(buffer, 36, 'data');
  buffer.setUint32(40, dataSize, Endian.little);

  // PCM samples
  for (var i = 0; i < numSamples; i++) {
    final sample = (samples[i].clamp(-1.0, 1.0) * 32767).toInt();
    buffer.setInt16(44 + i * 2, sample, Endian.little);
  }

  return buffer.buffer.asUint8List();
}

void _writeAscii(ByteData buffer, int offset, String text) {
  for (var i = 0; i < text.length; i++) {
    buffer.setUint8(offset + i, text.codeUnitAt(i));
  }
}

// ---------------------------------------------------------------------------
// Sound generators
// ---------------------------------------------------------------------------

/// Dice rattling on a table — noise burst with amplitude modulation.
void _generateDiceRoll(String path) {
  const sampleRate = 22050;
  const duration = 0.5;
  final numSamples = (sampleRate * duration).toInt();
  final rng = Random(42);
  final samples = List<double>.filled(numSamples, 0);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    // Exponential decay envelope
    final envelope = exp(-t * 6) * 0.7;
    // Amplitude modulation at ~15Hz simulates rattling
    final rattle = 0.5 + 0.5 * sin(2 * pi * 15 * t);
    // Mix white noise (dice surfaces) with tonal hits (table resonance)
    final noise = rng.nextDouble() * 2 - 1;
    final tone = sin(2 * pi * 200 * t) * 0.3 + sin(2 * pi * 400 * t) * 0.1;
    samples[i] = (noise * 0.7 + tone) * envelope * rattle;
  }

  File(path).writeAsBytesSync(_makeWav(samples, sampleRate));
  print('  dice_roll.wav  (${(numSamples * 2 / 1024).toStringAsFixed(1)} KB)');
}

/// Short thud when dice land — low frequency impact.
void _generateDiceLand(String path) {
  const sampleRate = 22050;
  const duration = 0.15;
  final numSamples = (sampleRate * duration).toInt();
  final rng = Random(7);
  final samples = List<double>.filled(numSamples, 0);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final envelope = exp(-t * 30);
    // Low thud (80Hz) + brief click (noise)
    final thud = sin(2 * pi * 80 * t) * 0.6;
    final click = (rng.nextDouble() * 2 - 1) * exp(-t * 50) * 0.4;
    samples[i] = (thud + click) * envelope;
  }

  File(path).writeAsBytesSync(_makeWav(samples, sampleRate));
  print('  dice_land.wav  (${(numSamples * 2 / 1024).toStringAsFixed(1)} KB)');
}

/// Pleasant ascending ding when scoring.
void _generateScore(String path) {
  const sampleRate = 22050;
  const duration = 0.4;
  final numSamples = (sampleRate * duration).toInt();
  final samples = List<double>.filled(numSamples, 0);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    // Two-tone ascending ding (A5 → C#6)
    const freq1 = 880.0;
    const freq2 = 1108.7;
    final env1 = t < 0.2 ? exp(-t * 8) : 0.0;
    final env2 = t >= 0.08 ? exp(-(t - 0.08) * 8) : 0.0;
    samples[i] =
        sin(2 * pi * freq1 * t) * env1 * 0.5 +
        sin(2 * pi * freq2 * t) * env2 * 0.5;
  }

  File(path).writeAsBytesSync(_makeWav(samples, sampleRate));
  print('  score.wav      (${(numSamples * 2 / 1024).toStringAsFixed(1)} KB)');
}
