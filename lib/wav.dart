import 'dart:io';
import 'dart:typed_data';

void main() async {
  File file = File('../examples/mozart.wav');
  RandomAccessFile openedFile = file.openSync();
  WavFile wav = WavFile(openedFile);
  print('format: ${wav.format}');
  print('chunkID: ${wav.chunkId}');
  print('chunkSize: ${wav.chunkSize}');
  print('subChunk1: ${wav.subChunk1ID}');
  print('subChunk1: ${wav.subChunk1Size}');
  print('audioFormat: ${wav.audioFormat}');
  print('numChannels: ${wav.numChannels}');
  print('sampleRate: ${wav.sampleRate}');
  print('byteRate: ${wav.byteRate}');
  print('blockAlign: ${wav.blockAlign}');
  print('bitsPer: ${wav.bitsPerSample}');
  print('extraParam: ${wav.extraParamSize}');
  print('subChunk2: ${wav.subChunk2ID}');
  print('subChunk2: ${wav.subChunk2Size}');
}

class WavFile {
  // Wav Header
  late String chunkId;
  late int chunkSize;
  late String format;

  // Format Chunk
  late String subChunk1ID;
  late int subChunk1Size;
  late int audioFormat;
  late int numChannels;
  late int sampleRate;
  late int byteRate;
  late int blockAlign;
  late int bitsPerSample;
  late int extraParamSize = 0;

  // Data Chunk
  late String subChunk2ID;
  late int subChunk2Size;
  late dynamic data;

  WavFile(RandomAccessFile bytes) {
    chunkId = String.fromCharCodes(bytes.readSync(4));
    chunkSize =
        bytes.readSync(4).buffer.asByteData().getInt32(0, Endian.little);
    format = String.fromCharCodes(bytes.readSync(4));
    bytes.setPosition(16);
    subChunk1ID = String.fromCharCodes(bytes.readSync(4));
    subChunk1Size = bytes.readSync(4).buffer.asByteData().getInt32(0);
    audioFormat = bytes.readSync(2).buffer.asByteData().getInt32(0);
    numChannels = bytes.readSync(2).buffer.asByteData().getInt32(0);
    sampleRate = bytes.readSync(4).buffer.asByteData().getInt32(0);
    byteRate = bytes.readSync(4).buffer.asByteData().getInt32(0);
    blockAlign = bytes.readSync(2).buffer.asByteData().getInt32(0);
    bitsPerSample = bytes.readSync(2).buffer.asByteData().getInt32(0);

    if (subChunk1Size == 16) {
      bytes.setPosition(36);
    } else {
      extraParamSize = bytes.readSync(2).buffer.asByteData().getInt32(0);
      bytes.setPosition(16 + extraParamSize);
    }

    subChunk1ID = String.fromCharCodes(bytes.readSync(4));
    subChunk1Size = bytes.readSync(4).buffer.asByteData().getInt32(0);
  }
}
