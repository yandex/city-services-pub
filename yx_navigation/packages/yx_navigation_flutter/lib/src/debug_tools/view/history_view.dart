import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yx_navigation/yx_navigation.dart';

import '../../router/yx_router_delegate.dart';
import '../domain/log_types.dart';
import '../domain/debug_observer_readable.dart';
import '../utils/theme.dart';
import 'state_tree_view.dart';

class HistoryView extends StatelessWidget {
  final DebugObserverReadable? observerReadable;

  const HistoryView({
    required this.observerReadable,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final observer = observerReadable;

    if (observer == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No observer passed to $YxRouterDelegate',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _HistorySubView(
      observer: observer,
    );
  }
}

enum _LogType {
  stateManagerCreate,
  stateManagerMutation,
  stateManagerError,
  stateManagerClose,
  guardStart,
  guard,
  guardNext,
  guardCancel,
  guardRedirect,
  guardError,
  guardSync,
  deeplinkReceived,
  deeplinkNavigate,
  deeplinkHandled,
  deeplinkSkipped,
  deeplinkError,
}

class _HistorySubView extends StatefulWidget {
  final DebugObserverReadable observer;

  const _HistorySubView({
    required this.observer,
  });

  @override
  State<_HistorySubView> createState() => _HistorySubViewState();
}

class _HistorySubViewState extends State<_HistorySubView> {
  late Set<_LogType> _selectedTypes = _LogType.values.toSet();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: widget.observer,
            builder: (context, _) {
              final items = _filteredLogs;
              return Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => _LogItemWidget(
                    log: items[index],
                  ),
                  itemCount: items.length,
                ),
              );
            },
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showFilterTypeDialog(context),
              icon: const Icon(Icons.filter_alt),
              label: const Text('Filter log types'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );

  void _showFilterTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LogTypeFilterDialog(
          initialLogTypes: _selectedTypes,
          onLogTypesChanged: (logTypes) {
            setState(() {
              _selectedTypes = logTypes;
            });
          }),
    );
  }

  List<DebugLog> get _filteredLogs {
    final stateManagerLogs = widget.observer.stateManagerLogs.where(
      (element) => switch (element) {
        OnCreatedLog() => _selectedTypes.contains(_LogType.stateManagerCreate),
        MutationLog() => _selectedTypes.contains(_LogType.stateManagerMutation),
        ErrorLog() => _selectedTypes.contains(_LogType.stateManagerError),
        OnCloseLog() => _selectedTypes.contains(_LogType.stateManagerClose),
      },
    );

    final guardLogs = widget.observer.guardLogs.where(
      (element) => switch (element) {
        OnStartLog() => _selectedTypes.contains(_LogType.guardStart),
        OnGuardLog() => _selectedTypes.contains(_LogType.guard),
        OnNextLog() => _selectedTypes.contains(_LogType.guardNext),
        OnCancelLog() => _selectedTypes.contains(_LogType.guardCancel),
        OnRedirectLog() => _selectedTypes.contains(_LogType.guardRedirect),
        OnGuardErrorLog() => _selectedTypes.contains(_LogType.guardError),
        OnGuardSyncLog() => _selectedTypes.contains(_LogType.guardSync),
      },
    );

    final deeplinkLogs = widget.observer.deeplinkLogs.where(
      (element) => switch (element) {
        DeeplinkReceivedLog() =>
          _selectedTypes.contains(_LogType.deeplinkReceived),
        DeeplinkNavigateLog() =>
          _selectedTypes.contains(_LogType.deeplinkNavigate),
        DeeplinkHandledLog() =>
          _selectedTypes.contains(_LogType.deeplinkHandled),
        DeeplinkSkippedLog() =>
          _selectedTypes.contains(_LogType.deeplinkSkipped),
        DeeplinkErrorLog() => _selectedTypes.contains(_LogType.deeplinkError),
      },
    );

    final allLogs = <DebugLog>[
      ...stateManagerLogs,
      ...guardLogs,
      ...deeplinkLogs,
    ]..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      );

    return allLogs;
  }
}

class _LogItemWidget extends StatelessWidget {
  final DebugLog log;

  const _LogItemWidget({
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = _subtitle;
    final fromState = _fromState;
    final toState = _toState;
    final redirect = _redirect;
    final errorData = _errorData;

    return ListTile(
      title: Text(_title),
      tileColor: _backgroundColor,
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 2,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (errorData != null)
            IconButton(
              onPressed: () => _pushErrorDialog(context, errorData),
              icon: const Icon(Icons.error_outline_rounded),
            ),
          if (redirect != null)
            IconButton(
              onPressed: () => _pushStateDialog(context, redirect, null),
              icon: const Icon(Icons.subdirectory_arrow_right_rounded),
            ),
          if (fromState != null && toState != null)
            IconButton(
              onPressed: () => _pushStateDialog(
                context,
                fromState,
                toState,
              ),
              icon: const Icon(Icons.remove_red_eye_rounded),
            ),
        ],
      ),
    );
  }

  void _pushStateDialog(
    BuildContext context,
    RouteNode state,
    RouteNode? nextState,
  ) {
    showDialog(
      context: context,
      builder: (_) => _StateView(
        state: state,
        nextState: nextState,
      ),
    );
  }

  void _pushErrorDialog(
    BuildContext context,
    (Object error, StackTrace stackTrace, DateTime timestamp) errorData,
  ) {
    showDialog(
      context: context,
      builder: (_) => _ErrorView(
        error: errorData.$1,
        stackTrace: errorData.$2,
        timestamp: errorData.$3,
      ),
    );
  }

  RouteNode? get _fromState => switch (log) {
        OnCreatedLog() => null,
        MutationLog(:final Mutation mutation) => mutation.originalState,
        ErrorLog() => null,
        OnCloseLog() => null,
        OnStartLog(:final RouteNode origin) => origin,
        OnGuardLog(:final RouteNode origin) => origin,
        OnNextLog(:final RouteNode origin) => origin,
        OnCancelLog(:final RouteNode origin) => origin,
        OnRedirectLog(:final RouteNode origin) => origin,
        OnGuardErrorLog(:final RouteNode origin) => origin,
        OnGuardSyncLog() => null,
        DeeplinkReceivedLog(:final RouteNode currentState) => currentState,
        DeeplinkNavigateLog(:final RouteNode currentState) => currentState,
        DeeplinkHandledLog(:final RouteNode currentState) => currentState,
        DeeplinkSkippedLog(:final RouteNode currentState) => currentState,
        DeeplinkErrorLog(:final RouteNode currentState) => currentState,
      };

  RouteNode? get _toState => switch (log) {
        OnCreatedLog() => null,
        MutationLog(:final Mutation mutation) => mutation.targetState,
        ErrorLog() => null,
        OnCloseLog() => null,
        OnStartLog(:final RouteNode target) => target,
        OnGuardLog(:final RouteNode target) => target,
        OnNextLog(:final RouteNode target) => target,
        OnCancelLog(:final RouteNode target) => target,
        OnRedirectLog(:final RouteNode target) => target,
        OnGuardErrorLog(:final RouteNode target) => target,
        OnGuardSyncLog() => null,
        DeeplinkReceivedLog() => null,
        DeeplinkNavigateLog(:final RouteNode targetState) => targetState,
        DeeplinkHandledLog() => null,
        DeeplinkSkippedLog() => null,
        DeeplinkErrorLog() => null,
      };

  RouteNode? get _redirect => switch (log) {
        OnRedirectLog(:final RouteNode redirect) => redirect,
        _ => null,
      };

  String get _title => switch (log) {
        OnCreatedLog() => 'State Manager created',
        MutationLog() => 'Mutation',
        ErrorLog() => 'SM Error',
        OnCloseLog() => 'State Manager closed',
        OnStartLog() => 'Guard start',
        OnGuardLog() => 'Guard',
        OnNextLog() => 'Guard next',
        OnCancelLog() => 'Guard cancel',
        OnRedirectLog() => 'Guard redirect',
        OnGuardErrorLog() => 'Guard error',
        OnGuardSyncLog() => 'Guard sync',
        DeeplinkReceivedLog() => 'Deeplink received',
        DeeplinkNavigateLog() => 'Deeplink navigate',
        DeeplinkHandledLog() => 'Deeplink handled',
        DeeplinkSkippedLog() => 'Deeplink skipped',
        DeeplinkErrorLog() => 'Deeplink error',
      };

  String? get _subtitle => switch (log) {
        OnCreatedLog() => null,
        MutationLog() => null,
        ErrorLog(:final Object error) => '$error',
        OnCloseLog() => null,
        OnStartLog() => 'started iterating guards',
        OnGuardLog(
          :final RouteNodeGuard guard,
        ) =>
          'processing guard ${guard.runtimeType}',
        OnNextLog(
          :final RouteNodeGuard? guard,
        ) =>
          '${guard != null ? '[${guard.runtimeType}] ' : ''}allowed mutation',
        OnCancelLog(
          :final RouteNodeGuard guard,
        ) =>
          '${guard.runtimeType} forbid mutation',
        OnRedirectLog(
          :final RouteNodeGuard? guard,
          :final RouteNode redirect,
        ) =>
          '${guard != null ? '[${guard.runtimeType}] ' : ''} '
              '->${redirect.route.id}',
        OnGuardErrorLog(
          :final Object error,
          :final RouteNodeGuard guard,
        ) =>
          '${guard.runtimeType}: $error',
        OnGuardSyncLog(
          :final GuardSyncReason reason,
        ) =>
          reason.message,
        DeeplinkReceivedLog(:final Uri uri) => uri.toString(),
        DeeplinkNavigateLog(:final Uri uri, :final RouteNode targetState) =>
          '$uri → $targetState',
        DeeplinkHandledLog(:final Uri uri) => '$uri (no navigation)',
        DeeplinkSkippedLog(:final Uri uri) => '$uri (passed to parser)',
        DeeplinkErrorLog(:final Uri uri, :final Object error) => '$uri: $error',
      };

  (Object error, StackTrace stackTrace, DateTime timestamp)? get _errorData =>
      switch (log) {
        OnGuardErrorLog(
          :final Object error,
          :final StackTrace stackTrace,
          :final DateTime timestamp,
        ) =>
          (error, stackTrace, timestamp),
        ErrorLog(
          :final Object error,
          :final StackTrace stackTrace,
          :final DateTime timestamp,
        ) =>
          (error, stackTrace, timestamp),
        DeeplinkErrorLog(
          :final Object error,
          :final StackTrace stackTrace,
          :final DateTime timestamp,
        ) =>
          (error, stackTrace, timestamp),
        _ => null,
      };

  Color? get _backgroundColor => switch (log) {
        ErrorLog() => DebugToolsThemeUtils.errorLogColor,
        OnGuardErrorLog() => DebugToolsThemeUtils.errorLogColor,
        DeeplinkErrorLog() => DebugToolsThemeUtils.errorLogColor,
        _ => null,
      };
}

class _StateView extends StatelessWidget {
  final RouteNode state;
  final RouteNode? nextState;

  const _StateView({
    required this.state,
    required this.nextState,
  });

  @override
  Widget build(BuildContext context) {
    final next = nextState;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: StateTreeLayout(
                      node: state,
                    ),
                  ),
                  if (next != null) ...[
                    const VerticalDivider(),
                    Expanded(
                      child: StateTreeLayout(
                        node: next,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Close'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final DateTime timestamp;

  const _ErrorView({
    required this.error,
    required this.stackTrace,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DebugToolsThemeUtils.formatTimestamp(timestamp),
                        style: DebugToolsThemeUtils.monospaceTextStyle,
                      ),
                      const Divider(
                        height: 8,
                      ),
                      Text(
                        stackTrace.toString(),
                        style: DebugToolsThemeUtils.monospaceTextStyle,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: stackTrace.toString()),
                        );
                        Navigator.of(context).maybePop();
                      },
                      child: const Text('Copy StackTrace'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _LogTypeFilterDialog extends StatefulWidget {
  final Set<_LogType> initialLogTypes;
  final ValueSetter<Set<_LogType>> onLogTypesChanged;

  const _LogTypeFilterDialog({
    required this.initialLogTypes,
    required this.onLogTypesChanged,
  });

  @override
  State<_LogTypeFilterDialog> createState() => __LogTypeFilterDialogState();
}

class __LogTypeFilterDialogState extends State<_LogTypeFilterDialog> {
  late Set<_LogType> _logTypes = Set.from(widget.initialLogTypes);

  @override
  Widget build(BuildContext context) {
    const types = _LogType.values;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) => ListTile(
                  title: Text(types[index].name),
                  trailing: Checkbox(
                    value: _logTypes.contains(types[index]),
                    onChanged: (value) => setState(() {
                      if (value ?? false) {
                        _logTypes.add(types[index]);
                      } else {
                        _logTypes.remove(types[index]);
                      }
                    }),
                  ),
                  onTap: () => setState(() {
                    if (_logTypes.contains(types[index])) {
                      _logTypes.remove(types[index]);
                    } else {
                      _logTypes.add(types[index]);
                    }
                  }),
                ),
                itemCount: types.length,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _logTypes = Set.from(types);
                  }),
                  child: const Text('Select all'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _logTypes = <_LogType>{};
                  }),
                  child: const Text('Select none'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                widget.onLogTypesChanged(_logTypes);
                Navigator.of(context).maybePop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
