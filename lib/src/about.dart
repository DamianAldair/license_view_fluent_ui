import 'package:fluent_ui/fluent_ui.dart';
import 'package:license_view_fluent_ui/src/helpers.dart';

class AboutProgram extends StatelessWidget {
  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String name;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name.
  ///
  /// Defaults to the empty string.
  final String version;

  /// The icon to show below the application name.
  ///
  /// By default no icon is shown.
  ///
  /// Typically this will be an [ImageIcon] widget. It should honor the
  /// [IconTheme]'s [IconThemeData.size].
  final Widget? icon;

  /// A string to show in small print.
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String? legalese;

  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  const AboutProgram({
    super.key,
    required this.name,
    required this.version,
    this.icon,
    this.legalese,
  });

  @override
  Widget build(BuildContext context) {
    const textVerticalSeparation = 18.0;
    final theme = FluentTheme.of(context);
    final typography = theme.typography;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getGutterSize(context),
        vertical: 24.0,
      ),
      child: Column(
        children: <Widget>[
          Text(
            name,
            style: typography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (icon != null)
            IconTheme(
              data: theme.iconTheme,
              child: icon!,
            ),
          if (version.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: textVerticalSeparation),
              child: Text(
                version,
                style: typography.body,
                textAlign: TextAlign.center,
              ),
            ),
          if (legalese != null && legalese!.trim().isNotEmpty)
            Text(
              legalese!,
              style: typography.caption,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: textVerticalSeparation),
          Text(
            'Powered by Flutter',
            style: typography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
