import 'package:dartadvance_examples/07_streams/trim_frames_transformer.dart';
import 'package:test/test.dart';

void main() {
  test('the fromHandlers transformer trims frames and drops blank ones', () async {
    final frames = Stream.fromIterable([' a ', '   ', 'b']).transform(trimFrames);
    await expectLater(frames, emitsInOrder(['a', 'b', emitsDone]));
  });
}
