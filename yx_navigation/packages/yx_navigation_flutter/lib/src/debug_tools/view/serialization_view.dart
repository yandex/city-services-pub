import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../utils/theme.dart';

class SerializationView extends StatefulWidget {
  final RouteNodeStateManager stateManager;
  final List<PlatformStateSerialization> customSerializers;

  const SerializationView({
    required this.stateManager,
    this.customSerializers = const [],
    super.key,
  });

  @override
  State<SerializationView> createState() => _SerializationViewState();
}

class _SerializationViewState extends State<SerializationView> {
  PlatformStateSerialization serializer = const PrettyUriStateSerialization();

  List<PlatformStateSerialization> get _availableSerializers =>
      <PlatformStateSerialization>[
        const PrettyUriStateSerialization(),
        const UriStringStateSerialization(),
      ] +
      widget.customSerializers;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _platformPicker(),
            Expanded(
              child: StreamBuilder(
                stream: widget.stateManager.stream,
                initialData: widget.stateManager.state,
                builder: (context, snapshot) => Text(
                  serializer.convert(snapshot.requireData).toString(),
                  style: DebugToolsThemeUtils.monospaceTextStyle,
                ),
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Clipboard.setData(
                  ClipboardData(
                    text: serializer
                        .convert(
                          widget.stateManager.state,
                        )
                        .toString(),
                  ),
                ),
                icon: const Icon(
                  Icons.copy_outlined,
                ),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );

  Widget _platformPicker() {
    switch ((defaultTargetPlatform, kIsWeb)) {
      case (_, true):
      case (TargetPlatform.windows, _):
      case (TargetPlatform.linux, _):
      case (TargetPlatform.macOS, _):
        return _pointerPicker();
      case (TargetPlatform.android, _):
      case (TargetPlatform.iOS, _):
      case (_, _):
        return _touchPicker();
    }
  }

  Widget _pointerPicker() => FittedBox(
        child: DropdownButton<PlatformStateSerialization>(
          value: serializer,
          elevation: 0,
          alignment: Alignment.center,
          focusColor: Colors.transparent,
          underline: const SizedBox.shrink(),
          items: _availableSerializers
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.runtimeType.toString(),
                  ),
                ),
              )
              .toList(),
          onChanged: (newSerializer) => setState(
            () => serializer = newSerializer ?? serializer,
          ),
        ),
      );

  Widget _touchPicker() => ElevatedButton.icon(
        onPressed: () => _showTouchDialog(),
        icon: const Icon(Icons.settings),
        label: Text(serializer.runtimeType.toString()),
      );

  void _showTouchDialog() {
    final serializers = _availableSerializers;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.sizeOf(context).height * 0.3,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
              initialItem: max(
                0,
                serializers.indexOf(serializer),
              ),
            ),
            onSelectedItemChanged: (selectedItem) => setState(
              () => serializer = serializers[selectedItem],
            ),
            children: serializers
                .map(
                  (serializer) => Center(
                    child: Text(
                      serializer.runtimeType.toString(),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
