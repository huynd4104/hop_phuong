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
  name: r'StatusCol',
  id: 99999999,
  properties: {
    r'history': PropertySchema(
      id: 0,
      name: r'history',
      type: IsarType.objectList,
      target: r'PaymentEntry',
    ),
    r'isPaid': PropertySchema(
      id: 1,
      name: r'isPaid',
      type: IsarType.bool,
    ),
    r'roundId': PropertySchema(
      id: 2,
      name: r'roundId',
      type: IsarType.long,
    ),
    r'totalActualAmount': PropertySchema(
      id: 3,
      name: r'totalActualAmount',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 4,
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
  embeddedSchemas: {r'PaymentEntry': PaymentEntrySchema},
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
  {
    final list = object.history;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[PaymentEntry]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              PaymentEntrySchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  return bytesCount;
}

void _paymentStatusSerialize(
  PaymentStatus object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<PaymentEntry>(
    offsets[0],
    allOffsets,
    PaymentEntrySchema.serialize,
    object.history,
  );
  writer.writeBool(offsets[1], object.isPaid);
  writer.writeLong(offsets[2], object.roundId);
  writer.writeLong(offsets[3], object.totalActualAmount);
  writer.writeLong(offsets[4], object.userId);
}

PaymentStatus _paymentStatusDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentStatus(
    history: reader.readObjectList<PaymentEntry>(
      offsets[0],
      PaymentEntrySchema.deserialize,
      allOffsets,
      PaymentEntry(),
    ),
    id: id,
    isPaid: reader.readBoolOrNull(offsets[1]) ?? false,
    roundId: reader.readLong(offsets[2]),
    userId: reader.readLong(offsets[4]),
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
      return (reader.readObjectList<PaymentEntry>(
        offset,
        PaymentEntrySchema.deserialize,
        allOffsets,
        PaymentEntry(),
      )) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
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
  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'history',
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'history',
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'history',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

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
      totalActualAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalActualAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      totalActualAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalActualAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      totalActualAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalActualAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      totalActualAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalActualAmount',
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
    on QueryBuilder<PaymentStatus, PaymentStatus, QFilterCondition> {
  QueryBuilder<PaymentStatus, PaymentStatus, QAfterFilterCondition>
      historyElement(FilterQuery<PaymentEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'history');
    });
  }
}

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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy>
      sortByTotalActualAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalActualAmount', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy>
      sortByTotalActualAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalActualAmount', Sort.desc);
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

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy>
      thenByTotalActualAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalActualAmount', Sort.asc);
    });
  }

  QueryBuilder<PaymentStatus, PaymentStatus, QAfterSortBy>
      thenByTotalActualAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalActualAmount', Sort.desc);
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

  QueryBuilder<PaymentStatus, PaymentStatus, QDistinct>
      distinctByTotalActualAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalActualAmount');
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

  QueryBuilder<PaymentStatus, List<PaymentEntry>?, QQueryOperations>
      historyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'history');
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

  QueryBuilder<PaymentStatus, int, QQueryOperations>
      totalActualAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalActualAmount');
    });
  }

  QueryBuilder<PaymentStatus, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PaymentEntrySchema = Schema(
  name: r'PaymentEntry',
  id: 88888888,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'note': PropertySchema(
      id: 2,
      name: r'note',
      type: IsarType.string,
    )
  },
  estimateSize: _paymentEntryEstimateSize,
  serialize: _paymentEntrySerialize,
  deserialize: _paymentEntryDeserialize,
  deserializeProp: _paymentEntryDeserializeProp,
);

int _paymentEntryEstimateSize(
  PaymentEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _paymentEntrySerialize(
  PaymentEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeString(offsets[2], object.note);
}

PaymentEntry _paymentEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentEntry(
    amount: reader.readLongOrNull(offsets[0]),
    date: reader.readDateTimeOrNull(offsets[1]),
    note: reader.readStringOrNull(offsets[2]),
  );
  return object;
}

P _paymentEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PaymentEntryQueryFilter
    on QueryBuilder<PaymentEntry, PaymentEntry, QFilterCondition> {
  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      amountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      amountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'amount',
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> amountEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      amountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      amountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> amountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> dateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      dateGreaterThan(
    DateTime? value, {
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

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> dateLessThan(
    DateTime? value, {
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

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentEntry, PaymentEntry, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }
}

extension PaymentEntryQueryObject
    on QueryBuilder<PaymentEntry, PaymentEntry, QFilterCondition> {}
