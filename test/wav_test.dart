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
      expect(wav.chunkSize.runtimeType, equals(int));
      expect(wav.format, equals('WAVE'));
    },
  );
}
