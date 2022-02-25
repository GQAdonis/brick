?> The GraphQL domain is currently in Alpha. APIs are subject to change.

# Offline First With GraphQL Repository

`OfflineFirstWithGraphqlRepository` streamlines the GraphQL integration with an `OfflineFirstRepository`. A serial queue is included to track GraphQL mutations in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity).

The `OfflineFirstWithGraphql` domain uses all the same configurations and annotations as `OfflineFirst`.

![OfflineFirst#get](https://user-images.githubusercontent.com/865897/72176226-cdd8ca00-3392-11ea-867d-42f5f4620153.jpg)

!> You can change default behavior on a per-request basis using `policy:` (e.g. `get<Person>(policy: OfflineFirstUpsertPolicy.localOnly)`). This is available for `delete`, `get`, `getBatched`, and `upsert`.

## GraphqlOfflineQueueLink

To cache outbound requests, apply `GraphqlOfflineQueueLink` in your GraphqlProvider:

```dart
GraphqlProvider(
  link: Link.from([
    GraphqlOfflineQueueLink(GraphqlRequestSqliteCacheManager('myAppRequestQueue.sqlite')),
    HttpLink(endpoint)
  ]),
);
```

!> Be sure to place the queue above `HttpLink` or `WebSocketLink` or any other outbound `Link`s.