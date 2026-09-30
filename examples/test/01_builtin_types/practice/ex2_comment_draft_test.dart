import 'package:dartadvance_examples/01_builtin_types/practice/ex2_comment_draft.dart';
import 'package:test/test.dart';

void main() {
  test('an emoji family counts as one character', () {
    final draft = CommentDraft(maxLength: 10)..update('Hi 👨‍👩‍👦');
    expect(draft.text.length, 11); // UTF-16 code units
    expect(draft.remaining, 6); // 10 - 4 visible characters
  });

  test('truncation never splits a flag', () {
    final draft = CommentDraft(maxLength: 4)..update('Hi 🇩🇰!');
    expect(draft.text, 'Hi 🇩🇰');
    expect(draft.remaining, 0);
  });

  test('text within the limit is kept as is', () {
    final draft = CommentDraft(maxLength: 5)..update('café');
    expect(draft.text, 'café');
    expect(draft.remaining, 1);
  });
}
