import 'dart:io';
import 'dart:typed_data';

void main() {
  File file = File('../examples/mozart.wav');
  RandomAccessFile openedFile = file.openSync();
  WavFile wav = WavFile(openedFile);
  print('$wav\n');
  var samples = Uint8List(8);
  int sampleCount = wav.readSamples(samples.buffer.asUint16List());
  print('sampleCount: $sampleCount');
  print('sample[0]: ${samples[0]}');
  print('sample[1]: ${samples[1]}');
  print('sample[2]: ${samples[2]}');
  print('sample[3]: ${samples[3]}');
  print('sample[4]: ${samples[4]}');
  print('sample[5]: ${samples[5]}');
  print('sample[6]: ${samples[6]}');
  print('sample[7]: ${samples[7]}');
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

  void seekToAfter(RiffChunk chunk) {
    int nextChunkOffset = chunk.offset + chunk.size;
    _bytes.setPositionSync(nextChunkOffset);
  }

  // Returns the number of samples.
  int readInto(Uint16List samples) {
    double bytesRead = _bytes.readIntoSync(samples.buffer.asUint8List()) / 2;
    return bytesRead ~/ 2;
  }
}

class WavFile {
  // The mighty parser
  late final RiffParser parser;

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
    parser = RiffParser(bytes);

    // Root Chunk
    RiffChunk riffChunkRoot = parser.readChunkHeader();

    chunkId = riffChunkRoot.id;
    chunkSize = riffChunkRoot.size;
    format = parser.readString();

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

    assert(bitsPerSample == 16);
    parser.seekToAfter(formatChunk);

    // Data Chunk
    RiffChunk dataChunk = parser.readChunkHeader();
    subChunk2ID = dataChunk.id;
    subChunk2Size = dataChunk.size;
  }

  int readSamples(Uint16List samples) {
    return parser.readInto(samples);
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
