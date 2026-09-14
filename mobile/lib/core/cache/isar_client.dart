import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'cached_json_entry.dart';

/// Isar instance setup + schema registration, and the shared read-through
/// cache helpers every repository uses. See docs/06_MOBILE_RULES.md §2:
/// "check Isar cache first ... if stale/missing, call Dio ... write through
/// to Isar" - this class is that single pattern's local half.
class IsarClient {
  IsarClient._(this._isar);

  final Isar _isar;

  static Future<IsarClient> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([CachedJsonEntrySchema], directory: dir.path);
    return IsarClient._(isar);
  }

  /// Reads a cached JSON body for [cacheKey], decoded to `dynamic`
  /// (a `Map` or `List` depending on the endpoint). Returns null if missing
  /// or older than [ttlSeconds] (null [ttlSeconds] means "no expiry" -
  /// used for endpoints the backend itself only invalidates on its own
  /// aggregation runs, see `CacheConstants.untilNextAggregationTtlSeconds`).
  Future<dynamic> readCached(String cacheKey, {int? ttlSeconds}) async {
    final entry = await _isar.cachedJsonEntrys.where().cacheKeyEqualTo(cacheKey).findFirst();
    if (entry == null) return null;

    if (ttlSeconds != null) {
      final ageMs = DateTime.now().millisecondsSinceEpoch - entry.fetchedAtEpochMs;
      if (ageMs > ttlSeconds * 1000) return null;
    }
    return jsonDecode(entry.jsonBody);
  }

  /// Writes [value] (already-decoded `Map`/`List`) to the cache under [cacheKey].
  Future<void> writeCached(String cacheKey, dynamic value) async {
    final entry = CachedJsonEntry()
      ..cacheKey = cacheKey
      ..jsonBody = jsonEncode(value)
      ..fetchedAtEpochMs = DateTime.now().millisecondsSinceEpoch;

    await _isar.writeTxn(() async {
      await _isar.cachedJsonEntrys.put(entry);
    });
  }
}
