import 'package:fluent_ui/fluent_ui.dart';

/// Pre-built back button
class BackButton extends StatelessWidget {
  /// If it is provided, the default behavior will be overridden (pop).
  final void Function()? overriddenOnPressed;

  /// Pre-built back button
  const BackButton({
    super.key,
    this.overriddenOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: FluentLocalizations.of(context).backButtonTooltip,
      child: IconButton(
        icon: const Icon(FluentIcons.back),
        onPressed: overriddenOnPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}
