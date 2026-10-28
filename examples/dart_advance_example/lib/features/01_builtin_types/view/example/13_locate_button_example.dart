part of '../builtin_types_view.dart';

final class _LocateButtonExample {
  TopicExample build() {
    const place = 'Kadıköy';
    String? error;
    try {
      LocateButton().onTapWrong(place);
    } on TypeError catch (e) {
      error = '$e';
    }
    final early = LocateButton()..onTap(place);
    final ready = LocateButton(MapCamera())..onTap(place);
    return TopicExample(
      title: 'Harita hazır değil: ! değil ?..',
      negative: _LocatePreview(error: error),
      positive: Column(
        spacing: BuiltinTypesView._gap,
        children: [
          _LocatePreview(camera: early.camera),
          _LocatePreview(camera: ready.camera),
        ],
      ),
    );
  }
}

final class _LocatePreview extends StatelessWidget {
  const _LocatePreview({this.camera, this.error});

  final MapCamera? camera;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (error case final error?) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.error_outline, color: colors.error),
        title: const Text('Harita ekranı çöktü'),
        subtitle: Text(error),
      );
    }
    final pin = camera?.pin;
    return Container(
      height: BuiltinTypesView._thumb * 1.5,
      color: colors.surfaceContainerHighest,
      padding: const EdgeInsets.all(BuiltinTypesView._gap),
      child: Stack(
        children: [
          Center(
            child: Text(
              camera == null
                  ? 'Harita yükleniyor…'
                  : pin == null
                  ? 'Harita'
                  : '📍 $pin',
            ),
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
