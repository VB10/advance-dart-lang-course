part of '../builtin_types_view.dart';

final class _StoreMapExample {
  TopicExample build() {
    final json = jsonDecode(
      '{"latitude": 41, "longitude": 29.0}',
    ) as Map<String, dynamic>;
    String? error;
    try {
      StoreLocation.fromJsonWrong(json);
    } on TypeError catch (e) {
      error = '$e';
    }
    return TopicExample(
      title: 'JSON sayısı: as double değil num',
      negative: _StoreMapPreview(error: error),
      positive: _StoreMapPreview(location: StoreLocation.fromJson(json)),
    );
  }
}

final class _StoreMapPreview extends StatelessWidget {
  const _StoreMapPreview({this.location, this.error});

  final StoreLocation? location;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (location case final location?) {
      return ListTile(
        leading: Icon(Icons.location_on, color: colors.primary),
        title: const Text('Kadıköy Mağazası'),
        subtitle: Text('${location.latitude}, ${location.longitude}'),
        trailing: const Text('Yol tarifi'),
      );
    }
    return ListTile(
      leading: Icon(Icons.location_off, color: colors.error),
      title: const Text('Mağazalar yüklenemedi'),
      subtitle: Text(error ?? ''),
    );
  }
}
