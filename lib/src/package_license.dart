import 'dart:developer' as dev;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:license_view_fluent_ui/src/back_button.dart';
import 'package:license_view_fluent_ui/src/detail_arguments.dart';
import 'package:license_view_fluent_ui/src/helpers.dart';

/// Widget that loads the entries of a package.
class PackageLicense extends StatefulWidget {
  /// Package arguments.
  final DetailArguments args;

  /// Whether the back button is showed.
  final bool showBackButton;

  /// If it is provided, the default behavior will be overridden (pop).
  final void Function()? onPressedBackButton;

  /// Subtitle for display the amount of licenses of the package.
  final String Function(int)? subtitle;

  /// Widget that loads the entries of a package.
  const PackageLicense({
    super.key,
    required this.args,
    required this.showBackButton,
    this.onPressedBackButton,
    this.subtitle,
  });

  @override
  State<PackageLicense> createState() => _PackageLicenseState();
}

class _PackageLicenseState extends State<PackageLicense> {
  @override
  void initState() {
    super.initState();
    _initLicenses();
  }

  final List<Widget> _licenses = <Widget>[];
  bool _loaded = false;

  Future<void> _initLicenses() async {
    int debugFlowId = -1;
    assert(() {
      final flow = dev.Flow.begin();
      dev.Timeline.timeSync('_initLicenses()', () {}, flow: flow);
      debugFlowId = flow.id;
      return true;
    }());
    for (final LicenseEntry license in widget.args.licenseEntries) {
      if (!mounted) return;

      assert(() {
        dev.Timeline.timeSync('_initLicenses()', () {},
            flow: dev.Flow.step(debugFlowId));
        return true;
      }());
      final List<LicenseParagraph> paragraphs =
          await SchedulerBinding.instance.scheduleTask<List<LicenseParagraph>>(
        license.paragraphs.toList,
        Priority.animation,
        debugLabel: 'License',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _licenses.add(const Padding(
          padding: EdgeInsets.all(18.0),
          child: Divider(),
        ));
        for (final LicenseParagraph paragraph in paragraphs) {
          if (paragraph.indent == LicenseParagraph.centeredIndent) {
            _licenses.add(Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                paragraph.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ));
          } else {
            assert(paragraph.indent >= 0);
            _licenses.add(Padding(
              padding: EdgeInsetsDirectional.only(
                  top: 8.0, start: 16.0 * paragraph.indent),
              child: Text(paragraph.text),
            ));
          }
        }
      });
    }
    setState(() => _loaded = true);

    assert(() {
      dev.Timeline.timeSync('Build scheduled', () {},
          flow: dev.Flow.end(debugFlowId));
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;
    final double pad = getGutterSize(context);
    final EdgeInsets padding =
        EdgeInsets.only(left: pad, right: pad, bottom: pad);
    final List<Widget> listWidgets = <Widget>[
      ..._licenses,
      if (!_loaded)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: ProgressRing(),
          ),
        ),
    ];

    final length = widget.args.licenseEntries.length;

    return NavigationView(
      appBar: NavigationAppBar(
          height: appBarHeight,
          automaticallyImplyLeading: false,
          leading: !widget.showBackButton
              ? null
              : BackButton(overriddenOnPressed: widget.onPressedBackButton),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.args.packageName,
                style: typography.bodyLarge,
              ),
              Text(
                widget.subtitle?.call(length) ??
                    packageLicenseSubtitle.call(length),
                style: typography.body,
              ),
            ],
          )),
      content: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: Scrollbar(
          child: ListView(
            primary: true,
            padding: padding,
            children: listWidgets,
          ),
        ),
      ),
    );
  }
}
