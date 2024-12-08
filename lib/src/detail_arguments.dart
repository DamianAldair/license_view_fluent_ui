import 'package:flutter/foundation.dart';

/// Represent a package, with its name and entries.
class DetailArguments {
  /// The name of the package.
  final String packageName;

  /// List of its entries.
  final List<LicenseEntry> licenseEntries;

  /// Represent a package, with its name and entries.
  const DetailArguments(this.packageName, this.licenseEntries);

  @override
  bool operator ==(final Object other) {
    if (other is DetailArguments) {
      return other.packageName == packageName;
    }
    return other == this;
  }

  @override
  int get hashCode => Object.hash(packageName, Object.hashAll(licenseEntries));
}
