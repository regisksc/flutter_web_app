import 'package:flutter_web_app/core/error/failure.dart';

/// Longest long URL accepted.
const int maxLongUrlLength = 2048;

/// Aliases that would collide with app routes. Checked in lower case, so "API" is reserved too.
const Set<String> reservedAliases = {'api', 'admin', 'links', 'health'};

final RegExp _aliasFormat = RegExp(r'^[A-Za-z0-9_-]{3,20}$');

/// Returns a ValidationFailure when [url] is not a usable http(s) link, otherwise null.
Failure? validateLongUrl(String url) {
  if (url.isEmpty) return const ValidationFailure('Enter a URL');
  if (url.length > maxLongUrlLength) {
    return const ValidationFailure('URL is too long (max 2048 characters)');
  }
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return const ValidationFailure('URL must start with http:// or https://');
  }
  if (uri.host.isEmpty) return const ValidationFailure('URL needs a host');
  return null;
}

/// Returns a ValidationFailure for a bad alias. A null alias means "generate a code".
Failure? validateAlias(String? alias) {
  if (alias == null) return null;
  if (!_aliasFormat.hasMatch(alias)) {
    return const ValidationFailure(
      'Alias must be 3-20 letters, digits, _ or -',
    );
  }
  if (reservedAliases.contains(alias.toLowerCase())) {
    return const ValidationFailure('That alias is reserved');
  }
  return null;
}
