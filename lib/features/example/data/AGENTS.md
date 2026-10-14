# data: rules

- datasources/: ArticleRemoteDataSource (interface) and its Fake. Fake throws NetworkException or ServerException, never returns Failure.
- models/: ArticleModel with fromJson and toJson. Map to Entity in the repository or a mapper.
- repositories/: ArticleRepositoryImpl. Catches data exceptions and returns Failure inside Result: NetworkException -> NetworkFailure, ServerException -> ServerFailure, anything else -> UnexpectedFailure.
- Mapper and repository tests cover every exception type.
- Do not let an exception escape this folder.
