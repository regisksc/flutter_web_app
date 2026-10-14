# The shortener backend runs in-process behind the data-source interface

The kit allows no HTTP package and an interview has no server, so InMemoryShortLinkBackend implements ShortLinkRemoteDataSource and behaves like an API (it throws exceptions that stand for 400, 404 and 409). A real server replaces it by implementing the same interface; nothing above data/ changes.

Status: accepted
