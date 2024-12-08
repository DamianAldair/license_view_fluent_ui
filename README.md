# License View for Fluent UI

by [Damian Aldair](https://damianaldair.github.io).

---

Inspired by Flutter's **LicensePage**.

The easiest way to shows licenses for software used by tour application.


## Getting Started

Add following dependency to your `pubspec.yaml`.

```yaml
dependencies:
  fluent_ui: <latest_version>
  license_view_fluent_ui: <latest_version>
```

Import the package.
```dart
import 'package:fluent_ui/fluent_ui.dart';
import 'package:license_view_fluent_ui/license_view_fluent_ui.dart';
```

Now, you can use the view.
```dart
Navigator.push(
  context,
  FluentPageRoute(builder: (_) => LicenseView()),
);
```