// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_json_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedJsonEntryCollection on Isar {
  IsarCollection<CachedJsonEntry> get cachedJsonEntrys => this.collection();
}

const CachedJsonEntrySchema = CollectionSchema(
  name: r'CachedJsonEntry',
  id: 8727785205168720900,
  properties: {
    r'cacheKey': PropertySchema(
      id: 0,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'fetchedAtEpochMs': PropertySchema(
      id: 1,
      name: r'fetchedAtEpochMs',
      type: IsarType.long,
    ),
    r'jsonBody': PropertySchema(
      id: 2,
      name: r'jsonBody',
      type: IsarType.string,
    )
  },
  estimateSize: _cachedJsonEntryEstimateSize,
  serialize: _cachedJsonEntrySerialize,
  deserialize: _cachedJsonEntryDeserialize,
  deserializeProp: _cachedJsonEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'cacheKey': IndexSchema(
      id: 5885332021012296610,
      name: r'cacheKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'cacheKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedJsonEntryGetId,
  getLinks: _cachedJsonEntryGetLinks,
  attach: _cachedJsonEntryAttach,
  version: '3.1.0+1',
);

int _cachedJsonEntryEstimateSize(
  CachedJsonEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cacheKey.length * 3;
  bytesCount += 3 + object.jsonBody.length * 3;
  return bytesCount;
}

void _cachedJsonEntrySerialize(
  CachedJsonEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cacheKey);
  writer.writeLong(offsets[1], object.fetchedAtEpochMs);
  writer.writeString(offsets[2], object.jsonBody);
}

CachedJsonEntry _cachedJsonEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedJsonEntry();
  object.cacheKey = reader.readString(offsets[0]);
  object.fetchedAtEpochMs = reader.readLong(offsets[1]);
  object.id = id;
  object.jsonBody = reader.readString(offsets[2]);
  return object;
}

P _cachedJsonEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedJsonEntryGetId(CachedJsonEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedJsonEntryGetLinks(CachedJsonEntry object) {
  return [];
}

void _cachedJsonEntryAttach(
    IsarCollection<dynamic> col, Id id, CachedJsonEntry object) {
  object.id = id;
}

extension CachedJsonEntryByIndex on IsarCollection<CachedJsonEntry> {
  Future<CachedJsonEntry?> getByCacheKey(String cacheKey) {
    return getByIndex(r'cacheKey', [cacheKey]);
  }

  CachedJsonEntry? getByCacheKeySync(String cacheKey) {
    return getByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<bool> deleteByCacheKey(String cacheKey) {
    return deleteByIndex(r'cacheKey', [cacheKey]);
  }

  bool deleteByCacheKeySync(String cacheKey) {
    return deleteByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<List<CachedJsonEntry?>> getAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'cacheKey', values);
  }

  List<CachedJsonEntry?> getAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cacheKey', values);
  }

  Future<int> deleteAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cacheKey', values);
  }

  int deleteAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cacheKey', values);
  }

  Future<Id> putByCacheKey(CachedJsonEntry object) {
    return putByIndex(r'cacheKey', object);
  }

  Id putByCacheKeySync(CachedJsonEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'cacheKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCacheKey(List<CachedJsonEntry> objects) {
    return putAllByIndex(r'cacheKey', objects);
  }

  List<Id> putAllByCacheKeySync(List<CachedJsonEntry> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'cacheKey', objects, saveLinks: saveLinks);
  }
}

extension CachedJsonEntryQueryWhereSort
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QWhere> {
  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedJsonEntryQueryWhere
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QWhereClause> {
  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhereClause>
      cacheKeyEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cacheKey',
        value: [cacheKey],
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterWhereClause>
      cacheKeyNotEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CachedJsonEntryQueryFilter
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QFilterCondition> {
  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cacheKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      fetchedAtEpochMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fetchedAtEpochMs',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      fetchedAtEpochMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fetchedAtEpochMs',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      fetchedAtEpochMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fetchedAtEpochMs',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      fetchedAtEpochMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fetchedAtEpochMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jsonBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jsonBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jsonBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jsonBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jsonBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jsonBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jsonBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonBody',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterFilterCondition>
      jsonBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jsonBody',
        value: '',
      ));
    });
  }
}

extension CachedJsonEntryQueryObject
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QFilterCondition> {}

extension CachedJsonEntryQueryLinks
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QFilterCondition> {}

extension CachedJsonEntryQuerySortBy
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QSortBy> {
  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      sortByFetchedAtEpochMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAtEpochMs', Sort.asc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      sortByFetchedAtEpochMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAtEpochMs', Sort.desc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      sortByJsonBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonBody', Sort.asc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      sortByJsonBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonBody', Sort.desc);
    });
  }
}

extension CachedJsonEntryQuerySortThenBy
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QSortThenBy> {
  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      thenByFetchedAtEpochMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAtEpochMs', Sort.asc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      thenByFetchedAtEpochMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fetchedAtEpochMs', Sort.desc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      thenByJsonBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonBody', Sort.asc);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QAfterSortBy>
      thenByJsonBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonBody', Sort.desc);
    });
  }
}

extension CachedJsonEntryQueryWhereDistinct
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QDistinct> {
  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QDistinct> distinctByCacheKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QDistinct>
      distinctByFetchedAtEpochMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fetchedAtEpochMs');
    });
  }

  QueryBuilder<CachedJsonEntry, CachedJsonEntry, QDistinct> distinctByJsonBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jsonBody', caseSensitive: caseSensitive);
    });
  }
}

extension CachedJsonEntryQueryProperty
    on QueryBuilder<CachedJsonEntry, CachedJsonEntry, QQueryProperty> {
  QueryBuilder<CachedJsonEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedJsonEntry, String, QQueryOperations> cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<CachedJsonEntry, int, QQueryOperations>
      fetchedAtEpochMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fetchedAtEpochMs');
    });
  }

  QueryBuilder<CachedJsonEntry, String, QQueryOperations> jsonBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jsonBody');
    });
  }
}
