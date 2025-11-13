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
    r'sourceLang': PropertySchema(
      id: 0,
      name: r'sourceLang',
      type: IsarType.string,
    ),
    r'targetLang': PropertySchema(
      id: 1,
      name: r'targetLang',
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
    final value = object.sourceLang;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.targetLang;
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
  writer.writeString(offsets[0], object.sourceLang);
  writer.writeString(offsets[1], object.targetLang);
}

TranslatorSetting _translatorSettingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TranslatorSetting();
  object.id = id;
  object.sourceLang = reader.readStringOrNull(offsets[0]);
  object.targetLang = reader.readStringOrNull(offsets[1]);
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
    IsarCollection<dynamic> col, Id id, TranslatorSetting object) {
  object.id = id;
}

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
      sourceLangIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceLang',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceLang',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceLang',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceLang',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceLang',
        value: '',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      sourceLangIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceLang',
        value: '',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetLang',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetLang',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetLang',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetLang',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetLang',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetLang',
        value: '',
      ));
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterFilterCondition>
      targetLangIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetLang',
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
      sortBySourceLang() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLang', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      sortBySourceLangDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLang', Sort.desc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      sortByTargetLang() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLang', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      sortByTargetLangDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLang', Sort.desc);
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
      thenBySourceLang() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLang', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenBySourceLangDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceLang', Sort.desc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenByTargetLang() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLang', Sort.asc);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QAfterSortBy>
      thenByTargetLangDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetLang', Sort.desc);
    });
  }
}

extension TranslatorSettingQueryWhereDistinct
    on QueryBuilder<TranslatorSetting, TranslatorSetting, QDistinct> {
  QueryBuilder<TranslatorSetting, TranslatorSetting, QDistinct>
      distinctBySourceLang({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceLang', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TranslatorSetting, TranslatorSetting, QDistinct>
      distinctByTargetLang({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetLang', caseSensitive: caseSensitive);
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
      sourceLangProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceLang');
    });
  }

  QueryBuilder<TranslatorSetting, String?, QQueryOperations>
      targetLangProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetLang');
    });
  }
}
