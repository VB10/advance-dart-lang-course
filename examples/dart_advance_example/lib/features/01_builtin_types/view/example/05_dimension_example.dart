part of '../builtin_types_view.dart';

final class _DimensionExample {
  TopicExample build() {
    const typed = ['12,5', '12a'];
    final field = DimensionField();
    String wrongResult(String text) {
      try {
        return 'Kaydedildi: ${field.parseWrong(text)}';
      } on FormatException catch (e) {
        return 'Yakalanmamış hata: ${e.message}';
      }
    }

    return TopicExample(
      title: 'Kullanıcı girdisi: parse değil tryParse',
      negative: _DimensionPreview(
        fields: [
          for (final text in typed)
            (text: text, result: '', error: wrongResult(text)),
        ],
      ),
      positive: _DimensionPreview(
        fields: [
          for (final text in typed)
            (
              text: text,
              result: 'Kaydedildi: ${field.parse(text)}',
              error: field.errorText(text),
            ),
        ],
      ),
    );
  }
}

final class _DimensionPreview extends StatelessWidget {
  const _DimensionPreview({required this.fields});

  /// Each typed text with the value saved, or the error the screen shows.
  final List<({String text, String result, String? error})> fields;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: BuiltinTypesView._gap,
      children: [
        for (final field in fields)
          TextFormField(
            initialValue: field.text,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Genişlik (cm)',
              helperText: field.result,
              errorText: field.error,
            ),
          ),
      ],
    );
  }
}
