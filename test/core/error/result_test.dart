import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/core/error/result.dart';

void main() {
  test('when runs ok branch for Ok', () {
    const Result<int> result = Ok(3);
    expect(result.when(ok: (v) => 'ok $v', err: (f) => f.message), 'ok 3');
  });

  test('when runs err branch for Err', () {
    const Result<int> result = Err(NetworkFailure());
    expect(
      result.when(ok: (v) => 'ok $v', err: (f) => f.message),
      'No internet connection',
    );
  });

  test('equal values are equal and different values are not', () {
    expect(const Ok(1), const Ok(1));
    expect(const Ok(1), isNot(const Ok(2)));
    expect(const Err<int>(ServerFailure()), const Err<int>(ServerFailure()));
  });

  test('failures have default messages', () {
    expect(const ServerFailure().message, 'Server error');
    expect(const UnexpectedFailure().message, 'Something went wrong');
  });

  test('short link failures have default messages', () {
    expect(const ValidationFailure().message, 'Invalid input');
    expect(const ConflictFailure().message, 'Already taken');
    expect(const NotFoundFailure().message, 'Not found');
  });
}
