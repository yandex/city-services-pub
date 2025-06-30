import 'package:flutter/material.dart';

import 'map.dart';

class MapWidget extends StatefulWidget {
  final void Function(MapController map) onMapCreated;

  const MapWidget({
    super.key,
    required this.onMapCreated,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late final Future<MapController> _future;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // Simulate [MapWidget] loading process
    _future = Future<MapController>.delayed(
            const Duration(seconds: 1), () => MapController(_scrollController))
        .then((controller) {
      if (mounted) {
        widget.onMapCreated(controller);
      }
      return controller;
    });

    _future.then((controller) => controller.addListener(_onControllerUpdate));
  }

  @override
  void dispose() {
    _future
        .then((controller) => controller.removeListener(_onControllerUpdate));
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final controller = snap.requireData;
          final list = controller.items.values.toList(growable: false);
          return ListView.builder(
            controller: _scrollController,
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Theme(
                data: Theme.of(context).copyWith(
                  listTileTheme: Theme.of(context).listTileTheme.copyWith(
                      selectedTileColor:
                          Theme.of(context).secondaryHeaderColor),
                ),
                child: SizedBox(
                  height: MapController.itemHeight,
                  child: ListTile(
                    selected: item.selected,
                    title: Text(item.name),
                    onTap: () {
                      controller.selectPosition(
                        item.position,
                        selected: !item.selected,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      );
}
