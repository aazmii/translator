// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translator.setting.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTranslatorSettingCollection on Isar {
  IsarCollection<TranslatorSetting> get translatorSettings => this.collection();
}

const TranslatorSettingSchema = CollectionSchema(
  name: r'TranslatorSetting',
  id: -5159482568713148981,
  properties: {
    r'sourceLangCode': PropertySchema(
      id: 0,
      name: r'sourceLangCode',
      type: IsarType.string,
    ),
    r'targetLangCode': PropertySchema(
      id: 1,
      name: r'targetLangCode',
      type: IsarType.string,
    )
  },
  estimateSize: _translatorSettingEstimateSize,
  serialize: _translatorSettingSerialize,
  deserialize: _translatorSettingDeserialize,
  deserializeProp: _translatorSettingDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _translatorSettingGetId,
  getLinks: _translatorSettingGetLinks,
  attach: _translatorSettingAttach,
  version: '3.3.0-dev.3',
);

int _translatorSettingEstimateSize(
  TranslatorSetting object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.sourceLangCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.targetLangCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _translatorSettingSerialize(
  TranslatorSetting object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.sourceLangCode);
  writer.writeString(offsets[1], object.targetLangCode);
}

TranslatorSetting _translatorSettingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TranslatorSetting();
  object.sourceLangCode = reader.readStringOrNull(offsets[0]);
  object.targetLangCode = reader.readStringOrNull(offsets[1]);
  return object;
}

P _translatorSettingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _translatorSettingGetId(TranslatorSetting object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _translatorSettingGetLinks(
    TranslatorSetting object) {
  return [];
}

void _translatorSettingAttach(
    IsarCollection<dynamic> col, Id id, TranslatorSetting object) {}

extension TranslatorSettingQueryWhereSort
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QWhere> {
  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TranslatorSettingQueryWhere
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QWhereClause> {
  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterWhereClause>
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

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterWhereClause>
      idBetween(
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

extension TranslatorSettingQueryFilter
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QFilterCondition> {
  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
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

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
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

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
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

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceLangCode',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceLangCode',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceLangCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceLangCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceLangCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceLangCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetLangCode',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetLangCode',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetLangCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetLangCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetLangCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetLangCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetLangCode',
        value: '',
      ));
    });
  }
}

extension TranslatorSettingQueryObject
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QFilterCondition> {}

extension TranslatorSettingQueryLinks
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QFilterCondition> {}

extension TranslatorSettingQuerySortBy
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QSortBy> {
  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      sortBySourceLangCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLangCode', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      sortBySourceLangCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLangCode', Sort.desc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      sortByTargetLangCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLangCode', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      sortByTargetLangCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLangCode', Sort.desc);
    });
  }
}

extension TranslatorSettingQuerySortThenBy
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QSortThenBy> {
  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenBySourceLangCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLangCode', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenBySourceLangCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLangCode', Sort.desc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenByTargetLangCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLangCode', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenByTargetLangCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLangCode', Sort.desc);
    });
  }
}

extension TranslatorSettingQueryWhereDistinct
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QDistinct> {
  QueryBuilder<TranslatorSetting, TranslatorSetting, QDistinct>
      distinctBySourceLangCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceLangCode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QDistinct>
      distinctByTargetLangCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetLangCode',
          caseSensitive: caseSensitive);
    });
  }
}

extension TranslatorSettingQueryProperty
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QQueryProperty> {
  QueryBuilder<TranslatorSetting, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TranslatorSetting, String?, QQueryOperations>
      sourceLangCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceLangCode');
    });
  }

  QueryBuilder<TranslatorSetting, String?, QQueryOperations>
      targetLangCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetLangCode');
    });
  }
}
