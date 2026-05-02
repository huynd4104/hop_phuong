// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoundCollection on Isar {
  IsarCollection<Round> get rounds => this.collection();
}

const RoundSchema = CollectionSchema(
  name: r'RoundCol',
  id: 3443326441915538432,
  properties: {
    r'bidAmount': PropertySchema(
      id: 0,
      name: r'bidAmount',
      type: IsarType.long,
    ),
    r'contributionAmount': PropertySchema(
      id: 1,
      name: r'contributionAmount',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'netReceiveAmount': PropertySchema(
      id: 3,
      name: r'netReceiveAmount',
      type: IsarType.long,
    ),
    r'payoutAmount': PropertySchema(
      id: 4,
      name: r'payoutAmount',
      type: IsarType.long,
    ),
    r'poolId': PropertySchema(
      id: 5,
      name: r'poolId',
      type: IsarType.long,
    ),
    r'roundNumber': PropertySchema(
      id: 6,
      name: r'roundNumber',
      type: IsarType.long,
    ),
    r'winnerId': PropertySchema(
      id: 7,
      name: r'winnerId',
      type: IsarType.long,
    )
  },
  estimateSize: _roundEstimateSize,
  serialize: _roundSerialize,
  deserialize: _roundDeserialize,
  deserializeProp: _roundDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _roundGetId,
  getLinks: _roundGetLinks,
  attach: _roundAttach,
  version: '3.1.0+1',
);

int _roundEstimateSize(
  Round object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _roundSerialize(
  Round object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bidAmount);
  writer.writeLong(offsets[1], object.contributionAmount);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeLong(offsets[3], object.netReceiveAmount);
  writer.writeLong(offsets[4], object.payoutAmount);
  writer.writeLong(offsets[5], object.poolId);
  writer.writeLong(offsets[6], object.roundNumber);
  writer.writeLong(offsets[7], object.winnerId);
}

Round _roundDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Round(
    bidAmount: reader.readLongOrNull(offsets[0]) ?? 0,
    contributionAmount: reader.readLongOrNull(offsets[1]) ?? 0,
    date: reader.readDateTime(offsets[2]),
    id: id,
    netReceiveAmount: reader.readLongOrNull(offsets[3]) ?? 0,
    payoutAmount: reader.readLongOrNull(offsets[4]) ?? 0,
    poolId: reader.readLong(offsets[5]),
    roundNumber: reader.readLong(offsets[6]),
    winnerId: reader.readLongOrNull(offsets[7]),
  );
  return object;
}

P _roundDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _roundGetId(Round object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _roundGetLinks(Round object) {
  return [];
}

void _roundAttach(IsarCollection<dynamic> col, Id id, Round object) {
  object.id = id;
}

extension RoundQueryWhereSort on QueryBuilder<Round, Round, QWhere> {
  QueryBuilder<Round, Round, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Round, Round, QAfterWhere> anyPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'poolId'),
      );
    });
  }
}

extension RoundQueryWhere on QueryBuilder<Round, Round, QWhereClause> {
  QueryBuilder<Round, Round, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Round, Round, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Round, Round, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Round, Round, QAfterWhereClause> idBetween(
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

  QueryBuilder<Round, Round, QAfterWhereClause> poolIdEqualTo(int poolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'poolId',
        value: [poolId],
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterWhereClause> poolIdNotEqualTo(int poolId) {
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

  QueryBuilder<Round, Round, QAfterWhereClause> poolIdGreaterThan(
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

  QueryBuilder<Round, Round, QAfterWhereClause> poolIdLessThan(
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

  QueryBuilder<Round, Round, QAfterWhereClause> poolIdBetween(
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
}

extension RoundQueryFilter on QueryBuilder<Round, Round, QFilterCondition> {
  QueryBuilder<Round, Round, QAfterFilterCondition> bidAmountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bidAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bidAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bidAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bidAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bidAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bidAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bidAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> contributionAmountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contributionAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition>
      contributionAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contributionAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> contributionAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contributionAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> contributionAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contributionAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Round, Round, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Round, Round, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Round, Round, QAfterFilterCondition> netReceiveAmountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netReceiveAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> netReceiveAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'netReceiveAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> netReceiveAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'netReceiveAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> netReceiveAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'netReceiveAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> payoutAmountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payoutAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> payoutAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payoutAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> payoutAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payoutAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> payoutAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payoutAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> poolIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'poolId',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> poolIdGreaterThan(
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

  QueryBuilder<Round, Round, QAfterFilterCondition> poolIdLessThan(
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

  QueryBuilder<Round, Round, QAfterFilterCondition> poolIdBetween(
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

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roundNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roundNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roundNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roundNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> winnerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'winnerId',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> winnerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'winnerId',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> winnerIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'winnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> winnerIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'winnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> winnerIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'winnerId',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> winnerIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'winnerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoundQueryObject on QueryBuilder<Round, Round, QFilterCondition> {}

extension RoundQueryLinks on QueryBuilder<Round, Round, QFilterCondition> {}

extension RoundQuerySortBy on QueryBuilder<Round, Round, QSortBy> {
  QueryBuilder<Round, Round, QAfterSortBy> sortByBidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bidAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByBidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bidAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByContributionAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contributionAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByContributionAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contributionAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByNetReceiveAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netReceiveAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByNetReceiveAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netReceiveAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByPayoutAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payoutAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByPayoutAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payoutAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByPoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByRoundNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByRoundNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByWinnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerId', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByWinnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerId', Sort.desc);
    });
  }
}

extension RoundQuerySortThenBy on QueryBuilder<Round, Round, QSortThenBy> {
  QueryBuilder<Round, Round, QAfterSortBy> thenByBidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bidAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByBidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bidAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByContributionAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contributionAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByContributionAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contributionAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByNetReceiveAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netReceiveAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByNetReceiveAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netReceiveAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByPayoutAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payoutAmount', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByPayoutAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payoutAmount', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByPoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poolId', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByRoundNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByRoundNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByWinnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerId', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByWinnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerId', Sort.desc);
    });
  }
}

extension RoundQueryWhereDistinct on QueryBuilder<Round, Round, QDistinct> {
  QueryBuilder<Round, Round, QDistinct> distinctByBidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bidAmount');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByContributionAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contributionAmount');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByNetReceiveAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'netReceiveAmount');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByPayoutAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payoutAmount');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByPoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'poolId');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByRoundNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roundNumber');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByWinnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'winnerId');
    });
  }
}

extension RoundQueryProperty on QueryBuilder<Round, Round, QQueryProperty> {
  QueryBuilder<Round, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Round, int, QQueryOperations> bidAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bidAmount');
    });
  }

  QueryBuilder<Round, int, QQueryOperations> contributionAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contributionAmount');
    });
  }

  QueryBuilder<Round, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<Round, int, QQueryOperations> netReceiveAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'netReceiveAmount');
    });
  }

  QueryBuilder<Round, int, QQueryOperations> payoutAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payoutAmount');
    });
  }

  QueryBuilder<Round, int, QQueryOperations> poolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'poolId');
    });
  }

  QueryBuilder<Round, int, QQueryOperations> roundNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roundNumber');
    });
  }

  QueryBuilder<Round, int?, QQueryOperations> winnerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'winnerId');
    });
  }
}
