import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:license_view_fluent_ui/src/about.dart';
import 'package:license_view_fluent_ui/src/back_button.dart';
import 'package:license_view_fluent_ui/src/detail_arguments.dart';
import 'package:license_view_fluent_ui/src/helpers.dart';
import 'package:license_view_fluent_ui/src/license_data.dart';
import 'package:license_view_fluent_ui/src/package_license.dart';

/// A page that shows licenses for software used by the application.
///
/// The licenses shown on the [LicenseView] are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
class LicenseView extends StatefulWidget {
  ///Title for the [LicenseView].
  final Widget? title;

  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String? applicationName;

  /// The icon to show below the application name.
  ///
  /// By default no icon is shown.
  ///
  /// Typically this will be an [ImageIcon] widget. It should honor the
  /// [IconTheme]'s [IconThemeData.size].
  final Widget? applicationIcon;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name.
  ///
  /// Defaults to the empty string.
  final String? applicationVersion;

  /// A string to show in small print.
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String? applicationLegalese;

  ///Subtitle for the package license details.
  final String Function(int)? packageLicenseSubtitle;

  /// Creates a view that shows licenses for software used by the application.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version and legalese values
  /// default to the empty string.
  ///
  /// The licenses shown on the [LicenseView] are those returned by the
  /// [LicenseRegistry] API, which can be used to add more licenses to the list.
  const LicenseView({
    super.key,
    this.title,
    this.applicationName,
    this.applicationIcon,
    this.applicationVersion,
    this.applicationLegalese,
    this.packageLicenseSubtitle,
  });

  @override
  State<LicenseView> createState() => _LicenseViewState();
}

class _LicenseViewState extends State<LicenseView> {
  late ScrollController scrollController;
  bool showingPackages = true;
  LicenseData? licenseData;
  int selectedPackage = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final licenses = LicenseRegistry.licenses
        .fold<LicenseData>(
          LicenseData(),
          (LicenseData prev, LicenseEntry license) => prev..addLicense(license),
        )
        .then((LicenseData ld) => ld..sortPackages());

    return FutureBuilder(
      future: licenses,
      builder: (BuildContext context, AsyncSnapshot<LicenseData> snapshot) {
        return LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            final split = constraints.maxWidth > 800.0;

            final appBar = split || showingPackages
                ? NavigationAppBar(
                    height: appBarHeight,
                    leading: const BackButton(),
                    title: DefaultTextStyle.merge(
                      style: FluentTheme.of(context).typography.bodyLarge,
                      child: widget.title ?? Text(defaultLicensesViewTitle),
                    ),
                  )
                : null;

            final about = AboutProgram(
              name: widget.applicationName ?? defaultAppName(context),
              icon: widget.applicationIcon,
              version: widget.applicationVersion ?? '',
              legalese: widget.applicationLegalese,
            );

            if (licenseData == null) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _buildNavigationViewPlaceholder(
                  appBar: appBar,
                  about: about,
                  content: const Center(
                    child: ProgressRing(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildNavigationViewPlaceholder(
                  appBar: appBar,
                  about: about,
                  content: Center(
                    child: Text(snapshot.error.toString()),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return _buildNavigationViewPlaceholder(
                  appBar: appBar,
                  about: about,
                  content: const Center(
                    child: Text('NO DATA'),
                  ),
                );
              }

              licenseData = snapshot.data;
            }

            return NavigationView(
              appBar: appBar,
              content: split
                  ? null
                  : showingPackages
                      ? _buildPackageList(about)
                      : _buildPackageLicense(),
              pane: !split ? null : _buildSplitPane(about),
            );
          },
        );
      },
    );
  }

  Widget _buildNavigationViewPlaceholder({
    NavigationAppBar? appBar,
    required Widget about,
    required Widget content,
  }) {
    return NavigationView(
      appBar: appBar,
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            about,
            const SizedBox.square(dimension: 50.0),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPackageList(Widget about) {
    return ListView.builder(
      controller: scrollController,
      itemCount: licenseData!.packages.length + 1,
      itemBuilder: (_, int i) {
        if (i == 0) return about;

        final name = licenseData!.packages[i - 1];
        final bindings = licenseData!.packageLicenseBindings[name]!;
        final subtitle = widget.packageLicenseSubtitle?.call(bindings.length) ??
            defaultPackageLicenseSubtitle(bindings.length);
        return ListTile(
          leading: const Icon(FluentIcons.library),
          title: Text(name),
          subtitle: Text(subtitle),
          onPressed: () => setState(() {
            showingPackages = false;
            selectedPackage = i - 1;
          }),
        );
      },
    );
  }

  Widget _buildPackageLicense() {
    final name = licenseData!.packages[selectedPackage];
    final bindings = licenseData!.packageLicenseBindings[name]!;

    return PackageLicense(
      args: DetailArguments(
        name,
        bindings.map((i) => licenseData!.licenses[i]).toList(growable: false),
      ),
      showBackButton: true,
      onPressedBackButton: () => setState(() => showingPackages = true),
      subtitle: widget.packageLicenseSubtitle ?? defaultPackageLicenseSubtitle,
    );
  }

  NavigationPane _buildSplitPane(Widget about) {
    return NavigationPane(
      scrollController: scrollController,
      displayMode: PaneDisplayMode.open,
      selected: selectedPackage,
      onChanged: (i) => setState(() {
        showingPackages = false;
        selectedPackage = i;
      }),
      items: [
        PaneItemWidgetAdapter(child: about),
        ...licenseData!.packages.map(
          (String name) {
            final bindings = licenseData!.packageLicenseBindings[name]!;
            return PaneItem(
              icon: const Icon(FluentIcons.library),
              title: Text(name),
              infoBadge: Text(bindings.length.toString()),
              body: PackageLicense(
                args: DetailArguments(
                  name,
                  bindings
                      .map((i) => licenseData!.licenses[i])
                      .toList(growable: false),
                ),
                showBackButton: false,
                subtitle: widget.packageLicenseSubtitle ??
                    defaultPackageLicenseSubtitle,
              ),
            );
          },
        ),
      ],
    );
  }
}
