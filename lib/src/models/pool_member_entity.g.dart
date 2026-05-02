// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pool_member_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPoolMemberCollection on Isar {
  IsarCollection<PoolMember> get poolMembers => this.collection();
}

const PoolMemberSchema = CollectionSchema(
  name: r'PoolMemberModel',
  id: 8088951819342267392,
  properties: {
    r'poolId': PropertySchema(
      id: 0,
      name: r'poolId',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 1,
      name: r'userId',
      type: IsarType.long,
    )
  },
  estimateSize: _poolMemberEstimateSize,
  serialize: _poolMemberSerialize,
  deserialize: _poolMemberDeserialize,
  deserializeProp: _poolMemberDeserializeProp,
  idName: r'id',
  indexes: {
    r'poolId': IndexSchema(
      id: 3683634265834513408,
      name: r'poolId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'poolId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'user_index': IndexSchema(
      id: 7458788173502522368,
      name: r'user_index',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _poolMemberGetId,
  getLinks: _poolMemberGetLinks,
  attach: _poolMemberAttach,
  version: '3.1.0+1',
);

int _poolMemberEstimateSize(
  PoolMember object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _poolMemberSerialize(
  PoolMember object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.poolId);
  writer.writeLong(offsets[1], object.userId);
}

PoolMember _poolMemberDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PoolMember(
    id: id,
    poolId: reader.readLong(offsets[0]),
    userId: reader.readLong(offsets[1]),
  );
  return object;
}

P _poolMemberDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _poolMemberGetId(PoolMember object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _poolMemberGetLinks(PoolMember object) {
  return [];
}

void _poolMemberAttach(IsarCollection<dynamic> col, Id id, PoolMember object) {
  object.id = id;
}

extension PoolMemberQueryWhereSort
    on QueryBuilder<PoolMember, PoolMember, QWhere> {
  QueryBuilder<PoolMember, PoolMember, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhere> anyPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'poolId'),
      );
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhere> anyUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'user_index'),
      );
    });
  }
}

extension PoolMemberQueryWhere
    on QueryBuilder<PoolMember, PoolMember, QWhereClause> {
  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> idBetween(
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

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> poolIdEqualTo(
      int poolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'poolId',
        value: [poolId],
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> poolIdNotEqualTo(
      int poolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poolId',
              lower: [],
              upper: [poolId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poolId',
              lower: [poolId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poolId',
              lower: [poolId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poolId',
              lower: [],
              upper: [poolId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> poolIdGreaterThan(
    int poolId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'poolId',
        lower: [poolId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> poolIdLessThan(
    int poolId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'poolId',
        lower: [],
        upper: [poolId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> poolIdBetween(
    int lowerPoolId,
    int upperPoolId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'poolId',
        lower: [lowerPoolId],
        includeLower: includeLower,
        upper: [upperPoolId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> userIdEqualTo(
      int userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'user_index',
        value: [userId],
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> userIdNotEqualTo(
      int userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'user_index',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'user_index',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'user_index',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'user_index',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> userIdGreaterThan(
    int userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'user_index',
        lower: [userId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> userIdLessThan(
    int userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'user_index',
        lower: [],
        upper: [userId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterWhereClause> userIdBetween(
    int lowerUserId,
    int upperUserId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'user_index',
        lower: [lowerUserId],
        includeLower: includeLower,
        upper: [upperUserId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PoolMemberQueryFilter
    on QueryBuilder<PoolMember, PoolMember, QFilterCondition> {
  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> poolIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'poolId',
        value: value,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> poolIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'poolId',
        value: value,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> poolIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'poolId',
        value: value,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> poolIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'poolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> userIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> userIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> userIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterFilterCondition> userIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PoolMemberQueryObject
    on QueryBuilder<PoolMember, PoolMember, QFilterCondition> {}

extension PoolMemberQueryLinks
    on QueryBuilder<PoolMember, PoolMember, QFilterCondition> {}

extension PoolMemberQuerySortBy
    on QueryBuilder<PoolMember, PoolMember, QSortBy> {
  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> sortByPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.asc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> sortByPoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.desc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PoolMemberQuerySortThenBy
    on QueryBuilder<PoolMember, PoolMember, QSortThenBy> {
  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> thenByPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.asc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> thenByPoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.desc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PoolMember, PoolMember, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PoolMemberQueryWhereDistinct
    on QueryBuilder<PoolMember, PoolMember, QDistinct> {
  QueryBuilder<PoolMember, PoolMember, QDistinct> distinctByPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'poolId');
    });
  }

  QueryBuilder<PoolMember, PoolMember, QDistinct> distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }
}

extension PoolMemberQueryProperty
    on QueryBuilder<PoolMember, PoolMember, QQueryProperty> {
  QueryBuilder<PoolMember, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PoolMember, int, QQueryOperations> poolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'poolId');
    });
  }

  QueryBuilder<PoolMember, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
