import 'dart:io';
import 'dart:typed_data';

void main() async {
  File file = File('../examples/mozart.wav');
  RandomAccessFile openedFile = file.openSync();
  WavFile wav = WavFile(openedFile);
  wav.debugPrint();
}

class WavFile {
  late final String chunkId;
  late final int chunkSize;
  late final String format;

  WavFile(RandomAccessFile bytes) {
    chunkId = String.fromCharCodes(bytes.readSync(4));
    chunkSize =
        bytes.readSync(4).buffer.asByteData().getInt32(0, Endian.little);
    format = String.fromCharCodes(bytes.readSync(4));
  }

  void debugPrint() {
    print('ChunkID: $chunkId');
    print('ChunkSize: $chunkSize');
    print('Format: $format');
  }
}
