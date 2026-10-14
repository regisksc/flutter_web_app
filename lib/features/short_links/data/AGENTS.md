# data: short_links

- datasources/: throw NetworkException or ServerException. Never return Failure.
- models/: fromJson and toJson. Map to entities.
- repositories/: convert every exception to a Failure inside Result.
- Do not let an exception leave this folder.
