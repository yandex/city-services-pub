import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/config/navigation_config_provider.dart';
import 'package:yx_navigation_flutter/src/config/navigation_defaults.dart';
import 'package:yx_navigation_flutter/src/widgets/navigator_overrides.dart';

import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('NavigationConfigProvider', () {
    testWidgets('navigatorOverridesOf returns provided overrides',
        (tester) async {
      // arrange
      NavigatorOverrides? actualOverrides;

      await tester.pumpWidget(
        NavigationConfigProvider(
          child: Builder(
            builder: (context) {
              actualOverrides =
                  NavigationConfigProvider.navigatorOverridesOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualOverrides, isA<NavigatorOverrides>());
    });

    testWidgets('defaultsOf returns provided defaults', (tester) async {
      // arrange
      NavigationDefaults? actualDefaults;

      await tester.pumpWidget(
        NavigationConfigProvider(
          child: Builder(
            builder: (context) {
              actualDefaults = NavigationConfigProvider.defaultsOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualDefaults, isA<NavigationDefaults>());
    });

    testWidgets('maybeOf returns null when provider is absent', (tester) async {
      // arrange
      NavigationConfigProvider? actualProvider;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            actualProvider = NavigationConfigProvider.maybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(actualProvider, isNull);
    });

    testWidgets('maybeOf returns the provider when one is present',
        (tester) async {
      // arrange
      NavigationConfigProvider? actualProvider;
      await tester.pumpWidget(
        NavigationConfigProvider(
          child: Builder(
            builder: (context) {
              actualProvider = NavigationConfigProvider.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualProvider, isNotNull);
    });

    test('updateShouldNotify returns false for aspect-based model', () {
      // arrange
      const actualProvider = NavigationConfigProvider(child: SizedBox.shrink());
      const otherProvider = NavigationConfigProvider(child: SizedBox.shrink());

      // assert
      expect(actualProvider.updateShouldNotify(otherProvider), isFalse);
    });

    testWidgets(
        'updateShouldNotify=false shields every dependent from rebuilds '
        'regardless of which aspect mutated', (tester) async {
      // arrange: reset shared test state.
      _DefaultsReader.buildCount = 0;
      _OverridesReader.buildCount = 0;

      // arrange: _AspectReaderApp holds two StatefulWidget readers as
      // permanent elements and swaps only `defaults` via setState.
      final appKey = GlobalKey<_AspectReaderAppState>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: _AspectReaderApp(key: appKey),
        ),
      );
      final defaultsAfterFirst = _DefaultsReader.buildCount;
      final overridesAfterFirst = _OverridesReader.buildCount;

      // act: swap defaults with an instance whose == returns false, so any
      // notification path would propagate. The umbrella `updateShouldNotify`
      // must still gate the framework from ever invoking
      // `updateShouldNotifyDependent`.
      appKey.currentState!.update(const _AltDefaults());
      await tester.pump();

      // assert: contract — because the prod `updateShouldNotify` returns
      // false unconditionally, no dependent is rebuilt, not the defaults
      // subscriber (aspect-match) nor the overrides subscriber (aspect-miss).
      expect(
        _DefaultsReader.buildCount,
        equals(defaultsAfterFirst),
        reason: 'aspect-match subscriber is not rebuilt when '
            'updateShouldNotify=false',
      );
      expect(
        _OverridesReader.buildCount,
        equals(overridesAfterFirst),
        reason: 'aspect-miss subscriber is not rebuilt when '
            'updateShouldNotify=false',
      );
    });
  });
}

// internal test widget, not exported
class _AspectReaderApp extends StatefulWidget {
  const _AspectReaderApp({super.key});

  @override
  State<_AspectReaderApp> createState() => _AspectReaderAppState();
}

class _AspectReaderAppState extends State<_AspectReaderApp> {
  NavigationDefaults _defaults = const NavigationDefaults();

  void update(NavigationDefaults defaults) {
    setState(() => _defaults = defaults);
  }

  @override
  Widget build(BuildContext context) => NavigationConfigProvider(
        defaults: _defaults,
        child: const Row(
          children: [
            _DefaultsReader(),
            _OverridesReader(),
          ],
        ),
      );
}

// internal test widget, not exported
class _DefaultsReader extends StatefulWidget {
  const _DefaultsReader();

  static int buildCount = 0;

  @override
  State<_DefaultsReader> createState() => _DefaultsReaderState();
}

class _DefaultsReaderState extends State<_DefaultsReader> {
  @override
  Widget build(BuildContext context) {
    _DefaultsReader.buildCount++;
    NavigationConfigProvider.defaultsOf(context);
    return const SizedBox.shrink();
  }
}

// internal test widget, not exported
class _OverridesReader extends StatefulWidget {
  const _OverridesReader();

  static int buildCount = 0;

  @override
  State<_OverridesReader> createState() => _OverridesReaderState();
}

class _OverridesReaderState extends State<_OverridesReader> {
  @override
  Widget build(BuildContext context) {
    _OverridesReader.buildCount++;
    NavigationConfigProvider.navigatorOverridesOf(context);
    return const SizedBox.shrink();
  }
}

// internal test double, not exported
class _AltDefaults extends NavigationDefaults {
  const _AltDefaults();

  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => identityHashCode(this);
}
