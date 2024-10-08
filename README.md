# Nate – the grate

This website is made with Flutter! [flutter.dev](https://flutter.dev/)

<br>

## Framework

This site uses [a specific branch](https://github.com/nate-thegrate/flutter/tree/nate-thegrate.com) of the Flutter framework, to allow for a few things:

- Allowing `RenderObjectWidget`s to subscribe to `Listenable`s, so that components can be re-rendered directly without rebuilding a widget subtree.
  - This applies to both [implicit](https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget-class.html) and [explicit](https://api.flutter.dev/flutter/animation/AnimationController-class.html) animations!
- Adding a `SplashBox` API, so that [custom button widgets](./lib/projects/dx/dx_button.dart) can act similarly to Material design buttons, with better performance.

<br>

## State Management

The business logic of this web app is handled by native Flutter APIs (including [stateful](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) and [inherited](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html) widgets), along with a few additional dependencies:

- [go_router](https://pub.dev/packages/go_router), a routing API that supports deep links & URL patterns.
- [collection_notifiers](https://pub.dev/packages/collection_notifiers), since it's much more fun to work with than the native [`WidgetStatesController`](https://api.flutter.dev/flutter/widgets/WidgetStatesController-class.html).
- [flutter_hooks](https://pub.dev/packages/flutter_hooks), a powerful API that allows for composable, shared business logic between widgets.

<br>

## Code Generation

By using a [GraphQL query](./update_pull_requests/pr_query.gql) and an [executable Dart file](./update_pull_requests/update_pull_requests.dart), the [contribution stats](https://nate-thegrate.com/#/stats) are automatically updated each time the website is deployed!
