import 'dart:io';

import 'package:sound_equalizer/wav.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Basic WAV Header',
    () {
      File file = File('../examples/mozart.wav');
      RandomAccessFile openedFile = file.openSync();
      WavFile wav = WavFile(openedFile);

      expect(wav.chunkId, equals('RIFF'));
      expect(wav.chunkSize, equals(148170310));
      expect(wav.format, equals('WAVE'));
      expect(wav.subChunk1ID, equals('fmt '));
      expect(wav.subChunk1Size, equals(16));
      expect(wav.audioFormat, equals(1));
      expect(wav.numChannels, equals(2));
      expect(wav.sampleRate, equals(44100));
      expect(wav.byteRate, equals(176400));
      expect(wav.blockAlign, equals(4));
      expect(wav.bitsPerSample, equals(16));
      expect(wav.extraParamSize, equals(0));
      expect(wav.subChunk2ID, equals('LIST'));
      expect(wav.subChunk2Size, equals(26));
    },
  );
}
