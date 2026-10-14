import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/features/example/data/datasources/data_exceptions.dart';

void main() {
  test('data exceptions are plain exceptions', () {
    expect(NetworkException(), isA<Exception>());
    expect(ServerException(), isA<Exception>());
  });
}
