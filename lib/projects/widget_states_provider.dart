import 'package:nate_thegrate/the_good_stuff.dart';

final widgetStatesProvider = WidgetStatesProvider(_NoWidgetStates.new);

typedef _StatesProvider = NotifierProvider<WidgetStates, Set<WidgetState>>;

extension type WidgetStatesProvider._(_StatesProvider _provider) implements _StatesProvider {
  WidgetStatesProvider(ValueGetter<WidgetStates> create) : _provider = _StatesProvider(create);

  ProviderListenable<bool> satisfies(WidgetStatesConstraint constraint) {
    return _provider.select((states) => constraint.isSatisfiedBy(states));
  }
}

class _NoWidgetStates extends Notifier<Set<WidgetState>> implements WidgetStates {
  @override
  Set<WidgetState> build() => {};

  @override
  Never noSuchMethod(Invocation invocation) => throw UnsupportedError('no widget states');
}

class WidgetStates extends Notifier<Set<WidgetState>> {
  static ProviderSubscription<Set<WidgetState>>? maybeListen(
    Object ref,
    void Function(Set<WidgetState> states) listener,
  ) {
    final WidgetRef widgetRef;
    switch (ref) {
      case ConsumerState(:final ref) || final WidgetRef ref:
        widgetRef = ref;

      case State(:final BuildContext context) || final BuildContext context:
        widgetRef = context.findAncestorStateOfType<ConsumerState>()!.ref;

      default:
        throw ArgumentError('Invalid ref: $ref');
    }

    if (widgetRef.read(widgetStatesProvider.notifier) is _NoWidgetStates) return null;

    return widgetRef.listenManual<Set<WidgetState>>(
      widgetStatesProvider,
      (Set<WidgetState>? old, Set<WidgetState> current) => listener(current),
    );
  }

  @override
  Set<WidgetState> build() => {};

  void reset() => state = {};

  bool satisfies(WidgetStatesConstraint constraint) => constraint.isSatisfiedBy(state);

  static Set<WidgetState> _combine(WidgetState item, WidgetState? item2) {
    return {item, if (item2 != null) item2};
  }

  void add(WidgetState item, [WidgetState? item2]) {
    state = state.union(_combine(item, item2));
  }

  void remove(WidgetState item, [WidgetState? item2]) {
    state = state.difference(_combine(item, item2));
  }
}
