import 'package:isar/isar.dart';

part 'cached_json_entry.g.dart';

/// One cached JSON API response, keyed by a repository-constructed cache key
/// (see `core/constants/cache_constants.dart`). This is the single Isar
/// collection backing every feature's read-through cache - one consistent
/// pattern across all repositories, per docs/06_MOBILE_RULES.md §2.
@collection
class CachedJsonEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String cacheKey;

  /// The raw JSON response body, encoded as a string.
  late String jsonBody;

  late int fetchedAtEpochMs;
}
