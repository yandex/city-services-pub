import 'package:test/test.dart';
import 'package:yx_scope/yx_scope.dart';

void main() {
  group('ScopeStateHolder.toString()', () {
    test('contains a scope identity and its state', () async {
      final holder = _TestScopeHolder();

      final none = holder.toString();
      expect(none, contains('state:'));
      expect(none, contains(holder.state.toString()));

      await holder.create();

      final available = holder.toString();
      expect(available, contains('state:'));
      expect(available, contains(holder.state.toString()));

      await holder.drop();
    });

    test(
        'uses the container debugName when available, so it survives '
        'release minification', () async {
      final holder = _NamedScopeHolder();

      await holder.create();
      expect(holder.toString(), contains('MyNamedScope'));

      await holder.drop();
    });
  });
}

class _TestScopeHolder extends ScopeHolder<_TestScopeContainer> {
  @override
  _TestScopeContainer createContainer() => _TestScopeContainer();
}

class _TestScopeContainer extends ScopeContainer {}

class _NamedScopeHolder extends ScopeHolder<_NamedScopeContainer> {
  @override
  _NamedScopeContainer createContainer() => _NamedScopeContainer();
}

class _NamedScopeContainer extends ScopeContainer {
  _NamedScopeContainer() : super(name: 'MyNamedScope');
}
