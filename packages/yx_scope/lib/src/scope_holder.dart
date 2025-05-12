part of 'base_scope_container.dart';

/// Simple holder for creating [BaseScopeHolder].
///
/// Here is an example:
/// ```
/// class SomeScopeHolder extends ScopeHolder<SomeScopeContainer> {}
/// ```
/// You also have to declare SomeScopeContainer, see [BaseScopeContainer].
///
/// Now you have to create an instance of this holder and use it
/// to create/dispose scope and to communicate with it:
/// ```
///   final someScopeHolder = SomeScopeHolder();
///
///   await someScopeHolder.create();
///
///   final scope = someScopeHolder.scope;
///   // Now an instance of a scope is available
///   print(someScopeHolder.scope?.runtimeType); // SomeScopeContainer
///
///   // Access [ScopeContainer] only locally. Do not store it in fields.
///   if(scope != null) {
///     scope.appManager.someMethod();
///   }
///
///   await someScopeHolder.drop();
///   // Now scope is not available, so it's null
///   print(someScopeHolder.scope?.runtimeType); // null
///
///   // You can also subscribe to changes of a scope
///   someScopeHolder.listen((scope) {
///      if(scope != null) {
///         // scope exists and can be used
///      } else {
///         // scope is not available and disposed
///      }
///   }
/// ```
///
/// If you need to differentiate [BaseScopeContainer] and it's abstract interface
/// then you better use [BaseScopeHolder] directly.
abstract class ScopeHolder<Container extends ScopeContainer>
    extends BaseScopeHolder<Container, Container> {
  ScopeHolder({
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          // ignore: deprecated_member_use_from_same_package
          scopeListeners: scopeListeners,
          // ignore: deprecated_member_use_from_same_package
          depListeners: depListeners,
          // ignore: deprecated_member_use_from_same_package
          asyncDepListeners: asyncDepListeners,
        );
}

/// Simple holder for creating [BaseChildScopeHolder].
///
/// Here is an example:
/// ```
/// class DependentScopeHolder
///     extends ChildScopeHolder<DependentScopeContainer, SomeScopeContainer> {
///   DependentScopeHolder(SomeScopeContainer parent) : super(parent);
///
///    @override
///    DependentScopeContainer createContainer(SomeScopeContainer parent) =>
///       DependentScopeContainer(
///         parent: parent,
///       );
/// }
/// ```
/// You also have to declare DependentScopeContainer, see [BaseScopeContainer].
///
/// As long as you [ScopeContainer] has parent, you must declare this holder
/// inside parent [ScopeContainer]. Here is an example:
///
/// class SomeScopeContainer extends ScopeContainer {
///
///   // It must be late final as any [Dep] and you pass current [BaseScopeContainer]
///   // as a parent inside your DependentScopeHolder.
///   late final dependentScopeHolderDep = dep(() => DependentScopeHolder(this));
///
///   // ...
/// }
///
/// If you need to differentiate [BaseScopeContainer] and it's abstract interface
/// then you better use [BaseChildScopeHolder] directly.
abstract class ChildScopeHolder<Container extends ChildScopeContainer<Parent>,
        Parent extends Scope>
    extends BaseChildScopeHolder<Container, Container, Parent> {
  ChildScopeHolder(
    Parent parent, {
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          parent,
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          // ignore: deprecated_member_use_from_same_package
          scopeListeners: scopeListeners,
          // ignore: deprecated_member_use_from_same_package
          depListeners: depListeners,
          // ignore: deprecated_member_use_from_same_package
          asyncDepListeners: asyncDepListeners,
        );
}

/// Simple holder for creating [BaseDataScopeHolder].
///
/// Here is an example:
/// ```
/// class DataScopeHolder extends DataScopeHolder<DataScopeContainer, Data> {
///    @override
///    DataScopeContainer createContainer(Data data) => DataScopeContainer(data: data);
/// }
/// ```
/// You also have to declare DataScopeContainer, see [BaseScopeContainer].
///
/// Working with scope:
/// ```
/// await dataScopeHolder.create(SomeData());
/// // Scope exists here
///
/// await dataScopeHolder.drop();
/// // Scope does not exist here
/// ```
///
/// If you need to differentiate [BaseScopeContainer] and it's abstract interface
/// then you better use [BaseDataScopeHolder] directly.
abstract class DataScopeHolder<Container extends DataScopeContainer<Data>,
        Data extends Object>
    extends BaseDataScopeHolder<Container, Container, Data> {
  DataScopeHolder({
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          // ignore: deprecated_member_use_from_same_package
          scopeListeners: scopeListeners,
          // ignore: deprecated_member_use_from_same_package
          depListeners: depListeners,
          // ignore: deprecated_member_use_from_same_package
          asyncDepListeners: asyncDepListeners,
        );
}

/// Simple holder for creating [BaseChildDataScopeHolder].
///
/// Here is an example:
/// ```
/// class DataDependentScopeHolder
///     extends ChildDataScopeHolder<DataDependentScopeContainer, SomeScopeContainer, SomeData> {
///   DataDependentScopeHolder(SomeScopeContainer parent) : super(parent);
///
///    @override
///    DataDependentScopeContainer createContainer(SomeScopeContainer parent, SomeData data) =>
///       DataDependentScopeContainer(
///         data: data,
///         parent: parent,
///       );
/// }
/// ```
/// You also have to declare DataDependentScopeContainer, see [BaseScopeContainer].
///
/// As long as you [ScopeContainer] has parent, you must declare this holder
/// inside parent [ScopeContainer]. Here is an example:
///
/// class SomeScopeContainer extends ScopeContainer {
///
///   // It must be late final as any [Dep] and you pass current [BaseScopeContainer]
///   // as a parent inside your DependentScopeHolder.
///   late final dataDependentScopeHolderDep = dep(() => DataDependentScopeHolder(this));
///
///   // ...
/// }
///
/// If you need to differentiate [BaseScopeContainer] and it's abstract interface
/// then you better use [BaseChildDataScopeHolder] directly.
abstract class ChildDataScopeHolder<
        Container extends ChildDataScopeContainer<Parent, Data>,
        Parent extends Scope,
        Data extends Object>
    extends BaseChildDataScopeHolder<Container, Container, Parent, Data> {
  ChildDataScopeHolder(
    Parent parent, {
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          parent,
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          // ignore: deprecated_member_use_from_same_package
          scopeListeners: scopeListeners,
          // ignore: deprecated_member_use_from_same_package
          depListeners: depListeners,
          // ignore: deprecated_member_use_from_same_package
          asyncDepListeners: asyncDepListeners,
        );
}

/// Holder contains the state of a [BaseScopeContainer] — null or the scope itself.
/// This is the core entity that provides access to the [BaseScopeContainer].
///
/// This holder allows to keep a [BaseScopeContainer] as an abstract interface [Scope].
/// Your [BaseScopeContainer] have to implement this [Scope] interface.
///
/// You can use [ScopeHolder] if you don't need
/// to differentiate [BaseScopeContainer] and it's interface.
abstract class BaseScopeHolder<Scope, Container extends ScopeContainer>
    extends CoreScopeHolder<Scope, Container> {
  BaseScopeHolder({
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          scopeListeners: scopeListeners,
          depListeners: depListeners,
          asyncDepListeners: asyncDepListeners,
        );

  @protected
  Container createContainer();

  Future<void> create() => init(createContainer());
}

/// Holder contains the state of a [ChildScopeContainer] — null or the scope itself.
/// This is the core entity that provides access to the [ChildScopeContainer].
///
/// In order to create [BaseChildScopeHolder]
/// you have to provider a Parent [BaseScopeContainer].
///
/// This holder allows to keep a [BaseScopeContainer] as an abstract interface [Scope].
/// Your [BaseScopeContainer] have to implement this [Scope] interface.
///
/// You can use [ChildScopeHolder] if you don't need
/// to differentiate [BaseScopeContainer] and it's interface.
abstract class BaseChildScopeHolder<
        ScopeType,
        Container extends ChildScopeContainer<Parent>,
        Parent extends Scope> extends CoreScopeHolder<ScopeType, Container>
    with _BaseChildScopeHolderMixin<ScopeType, Container, Parent> {
  BaseChildScopeHolder(
    Parent parent, {
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          scopeListeners: scopeListeners,
          depListeners: depListeners,
          asyncDepListeners: asyncDepListeners,
        ) {
    this.parent = parent;
  }

  @protected
  Container createContainer(Parent parent);

  Future<void> create() => init(createContainer(parent));
}

/// Holder contains the state of a [DataScopeContainer] — null or the scope itself.
/// This is the core entity that provides access to the [DataScopeContainer].
///
/// This holder allows to keep a [BaseScopeContainer] as an abstract interface [Scope].
/// Your [BaseScopeContainer] have to implement this [Scope] interface.
///
/// You can use [DataScopeHolder] if you don't need
/// to differentiate [BaseScopeContainer] and it's interface.
abstract class BaseDataScopeHolder<
        Scope,
        Container extends DataScopeContainer<Data>,
        Data extends Object> extends CoreScopeHolder<Scope, Container>
    with _BaseDataScopeHolderMixin<Scope, Container, Data> {
  BaseDataScopeHolder({
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          scopeListeners: scopeListeners,
          depListeners: depListeners,
          asyncDepListeners: asyncDepListeners,
        );

  @protected
  Container createContainer(Data data);

  Future<void> create(Data data) => init(createContainer(data));
}

/// Holder contains the state of a [ChildDataScopeContainer] — null or the scope itself.
/// This is the core entity that provides access to the [ChildDataScopeContainer].
///
/// In order to create [BaseChildDataScopeHolder]
/// you have to provider a Parent [BaseScopeContainer].
///
/// This holder allows to keep a [BaseScopeContainer] as an abstract interface [Scope].
/// Your [BaseScopeContainer] have to implement this [Scope] interface.
///
/// You can use [ChildDataScopeHolder] if you don't need
/// to differentiate [BaseScopeContainer] and it's interface.
abstract class BaseChildDataScopeHolder<
        ScopeType,
        Container extends ChildDataScopeContainer<Parent, Data>,
        Parent extends Scope,
        Data extends Object> extends CoreScopeHolder<ScopeType, Container>
    with
        _BaseChildScopeHolderMixin<ScopeType, Container, Parent>,
        _BaseDataScopeHolderMixin<ScopeType, Container, Data> {
  BaseChildDataScopeHolder(
    Parent parent, {
    @Deprecated('Use scopeObservers instead')
    List<ScopeListener>? scopeListeners,
    @Deprecated('Use depObservers instead') List<DepListener>? depListeners,
    @Deprecated('Use asyncDepObservers instead')
    List<AsyncDepListener>? asyncDepListeners,
    List<ScopeObserver>? scopeObservers,
    List<DepObserver>? depObservers,
    List<AsyncDepObserver>? asyncDepObservers,
  }) : super(
          scopeObservers: scopeObservers,
          depObservers: depObservers,
          asyncDepObservers: asyncDepObservers,
          scopeListeners: scopeListeners,
          depListeners: depListeners,
          asyncDepListeners: asyncDepListeners,
        ) {
    this.parent = parent;
  }

  @protected
  Container createContainer(Parent parent, Data data);

  Future<void> create(Data data) => init(createContainer(parent, data));
}

mixin _BaseChildScopeHolderMixin<
    ScopeType,
    Container extends ChildScopeContainerMixin<Parent>,
    Parent extends Scope> on CoreScopeHolder<ScopeType, Container> {
  Parent? _parent;

  /// Must not be used anyone except for the child with this mixin.
  /// Should only be used inside constructor, see [ChildScopeContainer].
  @protected
  set parent(Parent parent) => _parent = parent;

  /// Access parent of the current [BaseScopeContainer].
  Parent get parent {
    final p = _parent;
    if (p == null) {
      throw ScopeException(
        '$runtimeType: You must set parent in your ScopeHolder constructor',
      );
    }
    return p;
  }

  _AsyncVoidCallbackRemove? _parentRemoveListener;

  @protected
  @override
  Future<void> init(Container scope) async {
    await super.init(scope);
    _parentRemoveListener = parent._listenDispose(_onParentDropped);
  }

  @override
  Future<void> drop() async {
    _parentRemoveListener?.call();
    _parentRemoveListener = null;
    await super.drop();
  }

  Future<void> _onParentDropped() async {
    /// When parent is dropped, we are sure
    /// that current child scope won't be (and should no be) used again.
    /// It's not true for dropping only the current scope,
    /// that's why it's not in just drop method.
    _listeners.clear();
    await drop();
  }
}

mixin _BaseDataScopeHolderMixin<
    Scope,
    Container extends DataScopeContainerMixin<Data>,
    Data extends Object> on CoreScopeHolder<Scope, Container> {}
