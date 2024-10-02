import 'dart:io';
import 'dart:typed_data';

void main() {
  File file = File('../examples/mozart.wav');
  RandomAccessFile openedFile = file.openSync();
  WavFile wav = WavFile(openedFile);
  print(wav);
}

class RiffChunk {
  late final int offset;
  late final String id;
  late final int size;

  RiffChunk({
    required this.offset,
    required this.id,
    required this.size,
  });
}

class RiffParser {
  RiffParser(this._bytes);

  final RandomAccessFile _bytes;
  int bytesRead = 0;

  int readInt16() {
    bytesRead += 2;
    return _bytes.readSync(2).buffer.asByteData().getInt16(0, Endian.little);
  }

  int readInt32() {
    bytesRead += 4;
    return _bytes.readSync(4).buffer.asByteData().getInt32(0, Endian.little);
  }

  String readString() {
    bytesRead += 4;
    return String.fromCharCodes(_bytes.readSync(4));
  }

  void seekToAfter(RiffChunk chunk) {
    int nextChunkOffset = chunk.offset + chunk.size;
    _bytes.setPositionSync(nextChunkOffset);
  }

  RiffChunk readChunkHeader() {
    int offset = _bytes.positionSync();
    String id = readString();
    int size = readInt32();

    return RiffChunk(
      offset: offset,
      id: id,
      size: size,
    );
  }

  // RiffChunk firstChild() {}
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
    final parser = RiffParser(bytes);
    RiffChunk riffChunkRoot = parser.readChunkHeader();

    chunkId = riffChunkRoot.id;
    chunkSize = riffChunkRoot.size;
    format = parser.readString();

    // Riff is a nested tree structure, we don't seek the end
    // of the chunk here since the remaining chunks are still
    // 'inside' this 'root' chunk

    // Format Chunk
    RiffChunk formatChunk = parser.readChunkHeader();

    subChunk1ID = formatChunk.id;
    subChunk1Size = formatChunk.size;
    audioFormat = parser.readInt16();
    numChannels = parser.readInt16();
    sampleRate = parser.readInt32();
    byteRate = parser.readInt32();
    blockAlign = parser.readInt16();
    bitsPerSample = parser.readInt16();

    parser.seekToAfter(formatChunk);

    if (subChunk1Size == 16) {
      bytes.setPositionSync(36);
      parser.bytesRead = 36;
    } else {
      extraParamSize = parser.readInt16();
      bytes.setPositionSync(34 + 2 + extraParamSize);
      parser.bytesRead = 34 + 2 + extraParamSize;
    }

    subChunk2ID = parser.readString();
    subChunk2Size = parser.readInt32();
  }

  @override
  String toString() {
    return ''
        'format: $format\n'
        'chunkID: $chunkId\n'
        'chunkSize: $chunkSize\n'
        'subChunk1ID: $subChunk1ID\n'
        'subChunk1Size: $subChunk1Size\n'
        'audioFormat: $audioFormat\n'
        'numChannels: $numChannels\n'
        'sampleRate: $sampleRate\n'
        'byteRate: $byteRate\n'
        'blockAlign: $blockAlign\n'
        'bitsPerSample: $bitsPerSample\n'
        'extraParamSize: $extraParamSize\n'
        'subChunk2ID: $subChunk2ID\n'
        'subChunk2Size: $subChunk2Size';
  }
}
