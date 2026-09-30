# Architecture: layers and entities

The entry point into the canon: the layers of a feature, the dependency flow, and the role of every entity. Data-Domain boundaries and mapping are in [data_domain.md](data_domain.md). The recipe for a new feature and the antipatterns are in [recipes.md](recipes.md).

## Layers and dependency flow

A feature is five layers, and the dependency flow goes one way only:

```
       DI
       |
       v
Presentation -> Domain -> Data -> Shared
```

- **Shared** - data types, pure functions. No external dependencies. Reuse across features.
- **Data** - `Source` (Api/Storage/Service) plus `Repository`. May depend on Shared.
- **Domain** - `StateManager` plus `Interactor`, optionally a `StateProvider`. Depends on Data, may depend on Shared.
- **Presentation** - `ViewModel` plus `Widget`/`View`/`Screen`. Depends on Domain, may depend on Shared. **Does not depend on Data.**
- **DI** - wires the layers together through scopes.

Domain knows about Data (it imports its types). That is a deliberate simplification, not Clean Architecture. If you need them decoupled, take the Hard boundary ([data_domain.md](data_domain.md)).

The DTO-to-model mapping lives in Data and therefore imports the domain model: that single import back into Domain is expected and is what the Hard boundary removes by putting the interfaces in Domain instead.

The call flow: `View -> ViewModel -> Interactor -> StateManager -> Repository -> Source`. A ViewModel reads state through `StateReadable`.

## Folder structure

```
feature_xxx/lib/
|-- shared/            # types, utilities
|-- data/
|   |-- api/           # network sources
|   |-- storage/       # local sources
|   |-- service/       # external SDKs
|   `-- repository/    # repositories
|-- domain/
|   |-- state_manager/
|   |-- interactor/
|   `-- state_provider/
|-- presentation/
|   |-- view_model/
|   |-- widget/
|   `-- screen/
`-- di/                # ScopeContainer / ScopeHolder
```

The five layers are mandatory. Vary the structure inside them as needed.

## Entities and roles

### Data

- **Source** - raw read/write access to data. Subtypes: `Api` (backend), `Storage` (database, files, prefs), `Service` (an external SDK, a platform channel). Knows no business logic, returns DTOs.
- **Repository** - combines several sources OR is shared between state managers. Does the DTO-to-domain mapping (Medium and Hard boundaries). **Does not depend on another Repository.** Introduce one when either (a) a source is used by more than one StateManager, or (b) several sources have to be combined. Otherwise the StateManager accesses the source directly.

### Domain

- **StateManager** - holds **one** business state as `StateManager<T>` and implements `StateReadable<T>`. First-order business logic: it changes only its own state. **Does not depend on another StateManager or on an Interactor.** The API itself is covered by the `yx-state-fundamentals` skill.
- **Interactor** - coordinates several state managers (second-order business logic). Holds no business state, only service state such as flags and subscriptions. Introduce one when a piece of logic has to change the state of several state managers at once.
- **StateProvider** - a read-only `StateReadable<T>` that combines data from several state managers for presentation. Formally an exception to "Domain holds only state managers and interactors" - see [data_domain.md](data_domain.md).

### Presentation

- **ViewModel** - maps business and ephemeral state into a `ViewObject`. **Holds no business state, does not depend on another ViewModel, and is not registered in DI.** It reads through `StateReadable` and sends commands to an Interactor. When the feature has a single state manager and therefore no Interactor (see `recipes.md`, step 4), the ViewModel takes that state manager instead and calls its commands directly - that is the one case where a ViewModel holds something writable. The contract is a plain `implements StateReadable<ViewObject>`, see [view_model/overview.md](../view_model/overview.md).
- **ViewObject** - immutable data for rendering. May carry an `AsyncValue<T>` (loading/data/error).
- **Widget / View / Screen** - a Widget is reusable and carries no business logic; a View is bound to a ViewModel; a Screen assembles the parts and owns framework state. Keep framework state (`ScrollController`, `AnimationController`, `FocusNode`) in a `StatefulWidget`, **not** in a ViewModel.

### Advanced

- **Interceptor** - an interface for heterogeneous state checks, for example "may an order be started". A single Interactor aggregates them through DI. Use it when the business rules are switchable.
