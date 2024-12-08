import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

String defaultAppName(BuildContext context) {
  // This doesn't handle the case of the application's title dynamically
  // changing. In theory, we should make Title expose the current application
  // title using an InheritedWidget, and so forth. However, in practice, if
  // someone really wants their application title to change dynamically, they
  // can provide an explicit applicationName to the widgets defined in this
  // file, instead of relying on the default.
  final Title? ancestorTitle = context.findAncestorWidgetOfExactType<Title>();
  return ancestorTitle?.title ??
      Platform.resolvedExecutable.split(Platform.pathSeparator).last;
}

const int _materialGutterThreshold = 720;
const double _wideGutterSize = 24.0;
const double _narrowGutterSize = 12.0;

double getGutterSize(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= _materialGutterThreshold
        ? _wideGutterSize
        : _narrowGutterSize;

/// App bar height.
const double appBarHeight = 80.0;

/// Default title for LicenseView.
String get licensesViewTitle => 'Licenses';

/// Default subtitle for PackageLicense.
String packageLicenseSubtitle(int length) => '$length licenses';
