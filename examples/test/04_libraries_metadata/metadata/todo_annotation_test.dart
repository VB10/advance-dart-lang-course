import 'package:dartadvance_examples/04_libraries_metadata/metadata/todo_annotation.dart';
import 'package:test/test.dart';

void main() {
  test('a custom annotation is an ordinary const object', () {
    const todo = Todo('Dash', 'Implement this function');
    expect((todo.who, todo.what), ('Dash', 'Implement this function'));
  });
}
