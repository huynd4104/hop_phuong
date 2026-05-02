// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentStatusCollection on Isar {
  IsarCollection<PaymentStatus> get paymentStatus => this.collection();
}

const PaymentStatusSchema = CollectionSchema(
  name: r'PaymentStatus',
  id: 796065,
  properties: {
    r'isPaid': PropertySchema(
      id: 0,
      name: r'isPaid',
      type: IsarType.bool,
    ),
    r'roundId': PropertySchema(
      id: 1,
      name: r'roundId',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 2,
      name: r'userId',
      type: IsarType.long,
    )
  },
  estimateSize: _paymentStatusEstimateSize,
  serialize: _paymentStatusSerialize,
  deserialize: _paymentStatusDeserialize,
  deserializeProp: _paymentStatusDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _paymentStatusGetId,
  getLinks: _paymentStatusGetLinks,
  attach: _paymentStatusAttach,
  version: '3.1.0+1',
);

int _paymentStatusEstimateSize(
  PaymentStatus object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _paymentStatusSerialize(
  PaymentStatus object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isPaid);
  writer.writeLong(offsets[1], object.roundId);
  writer.writeLong(offsets[2], object.userId);
}

PaymentStatus _paymentStatusDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentStatus(
    id: id,
    isPaid: reader.readBoolOrNull(offsets[0]) ?? false,
    roundId: reader.readLong(offsets[1]),
    userId: reader.readLong(offsets[2]),
  );
  return object;
}

P _paymentStatusDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paymentStatusGetId(PaymentStatus object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentStatusGetLinks(PaymentStatus object) {
  return [];
}

void _paymentStatusAttach(
    IsarCollection<dynamic> col, Id id, PaymentStatus object) {
  object.id = id;
}

extension PaymentStatusQueryWhereSort
    on QueryBuilder<PaymentStatus, PaymentStatus, QWhere> {
  QueryBuilder<PaymentStatus, PaymentStatus, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PaymentStatusQueryWhere
    on QueryBuilder<PaymentStatus, PaymentStatus, QWhereClause> {
  QueryBuilder<PaymentStatus, PaymentStatus, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterWhereClause> idBetween(
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
}

extension PaymentStatusQueryFilter
    on QueryBuilder<PaymentStatus, PaymentStatus, QFilterCondition> {
  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      isPaidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaid',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      roundIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roundId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      roundIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roundId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      roundIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roundId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      roundIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roundId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      userIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      userIdGreaterThan(
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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      userIdLessThan(
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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      userIdBetween(
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

extension PaymentStatusQueryObject
    on QueryBuilder<PaymentStatus, PaymentStatus, QFilterCondition> {}

extension PaymentStatusQueryLinks
    on QueryBuilder<PaymentStatus, PaymentStatus, QFilterCondition> {}

extension PaymentStatusQuerySortBy
    on QueryBuilder<PaymentStatus, PaymentStatus, QSortBy> {
  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> sortByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> sortByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> sortByRoundId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundId', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> sortByRoundIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundId', Sort.desc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PaymentStatusQuerySortThenBy
    on QueryBuilder<PaymentStatus, PaymentStatus, QSortThenBy> {
  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenByIsPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaid', Sort.desc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenByRoundId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundId', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenByRoundIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundId', Sort.desc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension PaymentStatusQueryWhereDistinct
    on QueryBuilder<PaymentStatus, PaymentStatus, QDistinct> {
  QueryBuilder<PaymentStatus, PaymentStatus, QDistinct> distinctByIsPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaid');
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QDistinct> distinctByRoundId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roundId');
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QDistinct> distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }
}

extension PaymentStatusQueryProperty
    on QueryBuilder<PaymentStatus, PaymentStatus, QQueryProperty> {
  QueryBuilder<PaymentStatus, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentStatus, bool, QQueryOperations> isPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaid');
    });
  }

  QueryBuilder<PaymentStatus, int, QQueryOperations> roundIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roundId');
    });
  }

  QueryBuilder<PaymentStatus, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
