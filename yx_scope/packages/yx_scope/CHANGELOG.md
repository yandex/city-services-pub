## 1.2.0 - 2025.12.18

* Guide documentation completed
* Customizable behavior for Dep and AsyncDep

**1.1.4 - unpublished**
* Added behaviour and dep access to improve deps customization

**1.1.3 - unpublished**
* Added CustomDep/CustomAsyncDep classes for creating custom dependency types

## 1.1.2 - 2025.08.01

* Fix: ScopeListners/DepListeners/AsyncDepListeners usage

## 1.1.1 - 2025.07.08

* Documentation links fixed

## 1.1.0 - 2025.07.07

* Public sealed scope state API added
* Fix: Prohibit DataScope initialization with null data by enforcing non-nullable Data type
* Documentation fixes and updates
* Updated CI with new Flutter version support

#### Deprecated API
Listeners have been renamed into Observers due to conflicts with yx_scope_flutter package.
Consider using Observers instead of Listeners.
Deprecated classes and fields will be highlighted from now on.
In the next major, deprecated API will be completely removed.

## 1.0.2 - 2024.12.18

* Fix: corrected an inheritance of DataScopeContainer class to BaseScopeContainer instead of
  ScopeContainer
* Updated repository link
* Library topics added

## 1.0.1 - 2024.10.23

* Minor fixes in formatting and links

## 1.0.0 - 2024.10.18

* Remove redundant register/unregister listener methods
* Ready to be open-source

## 0.1.4 - 2024.10.10

* yx_scoped -> yx_scope

## 0.1.3 - 2024.09.23

* AsyncDep init/dispose callback now are hidden from API
* @nonVirtual nonVirtual for dep/asyncDep/rawAsyncDep methods

## 0.1.2 - 2024.08.20

* Added optional `name`
  for `ScopeContainer`, `ChildScopeContainer`, `DataScopeContainer`, `ChildDataScopeContainer`

## 0.1.1 - 2024.05.27

* Generic type of container for ScopeHolder's changed for strict link ScopedHolder's with
  ScopeContainer's

## 0.1.0 — 2024.05.08

1. All -Node entities has been renamed to -Container
2. Reorder parent and data args in createContainer methods

## 0.0.4 — 2024.03.09

Core entities has been renamed:

1. ScopeModule -> BaseScopeNode
2. FeatureScopeModule -> ScopeModule
3. RootScopeModule -> ScopeNode
4. DataChildScopeModule -> ChildDataScopeModule

And all their children has been renamed accordingly.

## 0.0.3 — 2024.03.04

* New class available: FeatureScopeModule. It helps to decompose ScopeModule into a number of
  features.
* Unnecessary build.yaml removed

## 0.0.2 — 2024.02.28

* Parent scope can be defined as an abstract interface that implements BaseScope. It helps to unbind
  child from knowing an exact implementation of the parent and depend only on it's interface.

## 0.0.1 — 2024.02.04

* Initial release
