// coverage:platform-only (VM tests cannot run this platform arm)
// Web HTTP calls. The redirect server lives on the same origin as this app,
// so relative URLs work behind the Tailscale funnel as well as on localhost.
import 'dart:convert';

import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';
import 'package:flutter_web_app/features/short_links/data/datasources/short_link_exceptions.dart';

import 'http_fetch.dart' as http;

/// Binds the generic fetch helper to the redirect-server API.
Future<Map<String, dynamic>> call(
  String path,
  String method,
  Map<String, dynamic>? body,
) async {
  try {
    return await http.fetchJson(
      method,
      path,
      body == null ? null : jsonEncode(body),
      onError: (status, message) {
        final error = message ?? 'error';
        if (status >= 500) {
          throw ServerException();
        }
        if (status == 404) {
          throw NotFoundException();
        }
        if (status == 409) {
          throw const ConflictException();
        }
        throw ValidationException(error);
      },
    );
  } on ServerException {
    rethrow;
  } on NotFoundException {
    rethrow;
  } on ConflictException {
    rethrow;
  } on ValidationException {
    rethrow;
  } catch (_) {
    // Any transport failure (offline, DNS) is a network failure; the repository
    // maps it to NetworkFailure.
    throw const NetworkException();
  }
}
