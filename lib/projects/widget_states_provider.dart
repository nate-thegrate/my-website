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
  static WidgetStates? maybeOf(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);

    return switch (container.read(widgetStatesProvider.notifier)) {
      _NoWidgetStates() => null,
      final widgetStates => widgetStates,
    };
  }

  static ProviderSubscription? maybeListen(
    BuildContext context,
    void Function(Set<WidgetState> states) listener,
  ) {
    if (maybeOf(context) == null) return null;

    void onChanged(Set<WidgetState>? old, Set<WidgetState>? current) => listener(current!);

    final WidgetRef ref = switch (context) {
      ConsumerStatefulElement() => context,
      _ => context.findAncestorStateOfType<ConsumerState>()!.ref,
    };

    return ref.listenManual<Set<WidgetState>?>(widgetStatesProvider, onChanged);
  }

  @override
  Set<WidgetState> build() => {};

  void reset() => state = {};

  bool satisfies(WidgetStatesConstraint constraint) => constraint.isSatisfiedBy(state);

  static Set<WidgetState> _combine(WidgetState item, WidgetState? item2, WidgetState? item3) {
    return {item, if (item2 != null) item2, if (item3 != null) item3};
  }

  void add(WidgetState item, [WidgetState? item2, WidgetState? item3]) {
    state = state.union(_combine(item, item2, item3));
  }

  void remove(WidgetState item, [WidgetState? item2, WidgetState? item3]) {
    state = state.difference(_combine(item, item2, item3));
  }
}
