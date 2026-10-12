// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingPaisaMeta = const VerificationMeta(
    'openingPaisa',
  );
  @override
  late final GeneratedColumn<int> openingPaisa = GeneratedColumn<int>(
    'opening_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lowAlertPaisaMeta = const VerificationMeta(
    'lowAlertPaisa',
  );
  @override
  late final GeneratedColumn<int> lowAlertPaisa = GeneratedColumn<int>(
    'low_alert_paisa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    provider,
    label,
    number,
    openingPaisa,
    lowAlertPaisa,
    isActive,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('opening_paisa')) {
      context.handle(
        _openingPaisaMeta,
        openingPaisa.isAcceptableOrUnknown(
          data['opening_paisa']!,
          _openingPaisaMeta,
        ),
      );
    }
    if (data.containsKey('low_alert_paisa')) {
      context.handle(
        _lowAlertPaisaMeta,
        lowAlertPaisa.isAcceptableOrUnknown(
          data['low_alert_paisa']!,
          _lowAlertPaisaMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      ),
      openingPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_paisa'],
      )!,
      lowAlertPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_alert_paisa'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String kind;
  final String? provider;
  final String label;
  final String? number;
  final int openingPaisa;
  final int? lowAlertPaisa;
  final bool isActive;
  final int sortOrder;
  final int createdAt;
  const AccountRow({
    required this.id,
    required this.kind,
    this.provider,
    required this.label,
    this.number,
    required this.openingPaisa,
    this.lowAlertPaisa,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    map['opening_paisa'] = Variable<int>(openingPaisa);
    if (!nullToAbsent || lowAlertPaisa != null) {
      map['low_alert_paisa'] = Variable<int>(lowAlertPaisa);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      kind: Value(kind),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      label: Value(label),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      openingPaisa: Value(openingPaisa),
      lowAlertPaisa: lowAlertPaisa == null && nullToAbsent
          ? const Value.absent()
          : Value(lowAlertPaisa),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      provider: serializer.fromJson<String?>(json['provider']),
      label: serializer.fromJson<String>(json['label']),
      number: serializer.fromJson<String?>(json['number']),
      openingPaisa: serializer.fromJson<int>(json['openingPaisa']),
      lowAlertPaisa: serializer.fromJson<int?>(json['lowAlertPaisa']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'provider': serializer.toJson<String?>(provider),
      'label': serializer.toJson<String>(label),
      'number': serializer.toJson<String?>(number),
      'openingPaisa': serializer.toJson<int>(openingPaisa),
      'lowAlertPaisa': serializer.toJson<int?>(lowAlertPaisa),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AccountRow copyWith({
    String? id,
    String? kind,
    Value<String?> provider = const Value.absent(),
    String? label,
    Value<String?> number = const Value.absent(),
    int? openingPaisa,
    Value<int?> lowAlertPaisa = const Value.absent(),
    bool? isActive,
    int? sortOrder,
    int? createdAt,
  }) => AccountRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    provider: provider.present ? provider.value : this.provider,
    label: label ?? this.label,
    number: number.present ? number.value : this.number,
    openingPaisa: openingPaisa ?? this.openingPaisa,
    lowAlertPaisa: lowAlertPaisa.present
        ? lowAlertPaisa.value
        : this.lowAlertPaisa,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      provider: data.provider.present ? data.provider.value : this.provider,
      label: data.label.present ? data.label.value : this.label,
      number: data.number.present ? data.number.value : this.number,
      openingPaisa: data.openingPaisa.present
          ? data.openingPaisa.value
          : this.openingPaisa,
      lowAlertPaisa: data.lowAlertPaisa.present
          ? data.lowAlertPaisa.value
          : this.lowAlertPaisa,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('provider: $provider, ')
          ..write('label: $label, ')
          ..write('number: $number, ')
          ..write('openingPaisa: $openingPaisa, ')
          ..write('lowAlertPaisa: $lowAlertPaisa, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    provider,
    label,
    number,
    openingPaisa,
    lowAlertPaisa,
    isActive,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.provider == this.provider &&
          other.label == this.label &&
          other.number == this.number &&
          other.openingPaisa == this.openingPaisa &&
          other.lowAlertPaisa == this.lowAlertPaisa &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String?> provider;
  final Value<String> label;
  final Value<String?> number;
  final Value<int> openingPaisa;
  final Value<int?> lowAlertPaisa;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.provider = const Value.absent(),
    this.label = const Value.absent(),
    this.number = const Value.absent(),
    this.openingPaisa = const Value.absent(),
    this.lowAlertPaisa = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String kind,
    this.provider = const Value.absent(),
    required String label,
    this.number = const Value.absent(),
    this.openingPaisa = const Value.absent(),
    this.lowAlertPaisa = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       label = Value(label),
       createdAt = Value(createdAt);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? provider,
    Expression<String>? label,
    Expression<String>? number,
    Expression<int>? openingPaisa,
    Expression<int>? lowAlertPaisa,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (provider != null) 'provider': provider,
      if (label != null) 'label': label,
      if (number != null) 'number': number,
      if (openingPaisa != null) 'opening_paisa': openingPaisa,
      if (lowAlertPaisa != null) 'low_alert_paisa': lowAlertPaisa,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String?>? provider,
    Value<String>? label,
    Value<String?>? number,
    Value<int>? openingPaisa,
    Value<int?>? lowAlertPaisa,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      provider: provider ?? this.provider,
      label: label ?? this.label,
      number: number ?? this.number,
      openingPaisa: openingPaisa ?? this.openingPaisa,
      lowAlertPaisa: lowAlertPaisa ?? this.lowAlertPaisa,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (openingPaisa.present) {
      map['opening_paisa'] = Variable<int>(openingPaisa.value);
    }
    if (lowAlertPaisa.present) {
      map['low_alert_paisa'] = Variable<int>(lowAlertPaisa.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('provider: $provider, ')
          ..write('label: $label, ')
          ..write('number: $number, ')
          ..write('openingPaisa: $openingPaisa, ')
          ..write('lowAlertPaisa: $lowAlertPaisa, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TxnsTable extends Txns with TableInfo<$TxnsTable, TxnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TxnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaisaMeta = const VerificationMeta(
    'amountPaisa',
  );
  @override
  late final GeneratedColumn<int> amountPaisa = GeneratedColumn<int>(
    'amount_paisa',
    aliasedName,
    false,
    check: () => ComparableExpr(amountPaisa).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargePaisaMeta = const VerificationMeta(
    'chargePaisa',
  );
  @override
  late final GeneratedColumn<int> chargePaisa = GeneratedColumn<int>(
    'charge_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _commissionPaisaMeta = const VerificationMeta(
    'commissionPaisa',
  );
  @override
  late final GeneratedColumn<int> commissionPaisa = GeneratedColumn<int>(
    'commission_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _commissionRuleIdMeta = const VerificationMeta(
    'commissionRuleId',
  );
  @override
  late final GeneratedColumn<String> commissionRuleId = GeneratedColumn<String>(
    'commission_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissionOverriddenMeta =
      const VerificationMeta('commissionOverridden');
  @override
  late final GeneratedColumn<bool> commissionOverridden = GeneratedColumn<bool>(
    'commission_overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("commission_overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerNumberMeta = const VerificationMeta(
    'customerNumber',
  );
  @override
  late final GeneratedColumn<String> customerNumber = GeneratedColumn<String>(
    'customer_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<int> voidedAt = GeneratedColumn<int>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replacesTxnIdMeta = const VerificationMeta(
    'replacesTxnId',
  );
  @override
  late final GeneratedColumn<String> replacesTxnId = GeneratedColumn<String>(
    'replaces_txn_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayCloseIdMeta = const VerificationMeta(
    'dayCloseId',
  );
  @override
  late final GeneratedColumn<String> dayCloseId = GeneratedColumn<String>(
    'day_close_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftIdMeta = const VerificationMeta(
    'shiftId',
  );
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
    'shift_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    occurredAt,
    recordedAt,
    amountPaisa,
    chargePaisa,
    commissionPaisa,
    commissionRuleId,
    commissionOverridden,
    customerId,
    customerNumber,
    reference,
    note,
    status,
    voidReason,
    voidedAt,
    replacesTxnId,
    dayCloseId,
    createdBy,
    shiftId,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'txn';
  @override
  VerificationContext validateIntegrity(
    Insertable<TxnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('amount_paisa')) {
      context.handle(
        _amountPaisaMeta,
        amountPaisa.isAcceptableOrUnknown(
          data['amount_paisa']!,
          _amountPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaisaMeta);
    }
    if (data.containsKey('charge_paisa')) {
      context.handle(
        _chargePaisaMeta,
        chargePaisa.isAcceptableOrUnknown(
          data['charge_paisa']!,
          _chargePaisaMeta,
        ),
      );
    }
    if (data.containsKey('commission_paisa')) {
      context.handle(
        _commissionPaisaMeta,
        commissionPaisa.isAcceptableOrUnknown(
          data['commission_paisa']!,
          _commissionPaisaMeta,
        ),
      );
    }
    if (data.containsKey('commission_rule_id')) {
      context.handle(
        _commissionRuleIdMeta,
        commissionRuleId.isAcceptableOrUnknown(
          data['commission_rule_id']!,
          _commissionRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('commission_overridden')) {
      context.handle(
        _commissionOverriddenMeta,
        commissionOverridden.isAcceptableOrUnknown(
          data['commission_overridden']!,
          _commissionOverriddenMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('customer_number')) {
      context.handle(
        _customerNumberMeta,
        customerNumber.isAcceptableOrUnknown(
          data['customer_number']!,
          _customerNumberMeta,
        ),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('replaces_txn_id')) {
      context.handle(
        _replacesTxnIdMeta,
        replacesTxnId.isAcceptableOrUnknown(
          data['replaces_txn_id']!,
          _replacesTxnIdMeta,
        ),
      );
    }
    if (data.containsKey('day_close_id')) {
      context.handle(
        _dayCloseIdMeta,
        dayCloseId.isAcceptableOrUnknown(
          data['day_close_id']!,
          _dayCloseIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(
        _shiftIdMeta,
        shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TxnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TxnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
      amountPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paisa'],
      )!,
      chargePaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charge_paisa'],
      )!,
      commissionPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commission_paisa'],
      )!,
      commissionRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commission_rule_id'],
      ),
      commissionOverridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}commission_overridden'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      customerNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_number'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voided_at'],
      ),
      replacesTxnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replaces_txn_id'],
      ),
      dayCloseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_close_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      shiftId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_id'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $TxnsTable createAlias(String alias) {
    return $TxnsTable(attachedDatabase, alias);
  }
}

class TxnRow extends DataClass implements Insertable<TxnRow> {
  final String id;
  final String type;
  final int occurredAt;
  final int recordedAt;
  final int amountPaisa;
  final int chargePaisa;
  final int commissionPaisa;
  final String? commissionRuleId;
  final bool commissionOverridden;
  final String? customerId;
  final String? customerNumber;
  final String? reference;
  final String? note;
  final String status;
  final String? voidReason;
  final int? voidedAt;
  final String? replacesTxnId;
  final String? dayCloseId;
  final String createdBy;
  final String? shiftId;
  final String deviceId;
  const TxnRow({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.recordedAt,
    required this.amountPaisa,
    required this.chargePaisa,
    required this.commissionPaisa,
    this.commissionRuleId,
    required this.commissionOverridden,
    this.customerId,
    this.customerNumber,
    this.reference,
    this.note,
    required this.status,
    this.voidReason,
    this.voidedAt,
    this.replacesTxnId,
    this.dayCloseId,
    required this.createdBy,
    this.shiftId,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['recorded_at'] = Variable<int>(recordedAt);
    map['amount_paisa'] = Variable<int>(amountPaisa);
    map['charge_paisa'] = Variable<int>(chargePaisa);
    map['commission_paisa'] = Variable<int>(commissionPaisa);
    if (!nullToAbsent || commissionRuleId != null) {
      map['commission_rule_id'] = Variable<String>(commissionRuleId);
    }
    map['commission_overridden'] = Variable<bool>(commissionOverridden);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || customerNumber != null) {
      map['customer_number'] = Variable<String>(customerNumber);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<int>(voidedAt);
    }
    if (!nullToAbsent || replacesTxnId != null) {
      map['replaces_txn_id'] = Variable<String>(replacesTxnId);
    }
    if (!nullToAbsent || dayCloseId != null) {
      map['day_close_id'] = Variable<String>(dayCloseId);
    }
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  TxnsCompanion toCompanion(bool nullToAbsent) {
    return TxnsCompanion(
      id: Value(id),
      type: Value(type),
      occurredAt: Value(occurredAt),
      recordedAt: Value(recordedAt),
      amountPaisa: Value(amountPaisa),
      chargePaisa: Value(chargePaisa),
      commissionPaisa: Value(commissionPaisa),
      commissionRuleId: commissionRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(commissionRuleId),
      commissionOverridden: Value(commissionOverridden),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      customerNumber: customerNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(customerNumber),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      replacesTxnId: replacesTxnId == null && nullToAbsent
          ? const Value.absent()
          : Value(replacesTxnId),
      dayCloseId: dayCloseId == null && nullToAbsent
          ? const Value.absent()
          : Value(dayCloseId),
      createdBy: Value(createdBy),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      deviceId: Value(deviceId),
    );
  }

  factory TxnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TxnRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
      amountPaisa: serializer.fromJson<int>(json['amountPaisa']),
      chargePaisa: serializer.fromJson<int>(json['chargePaisa']),
      commissionPaisa: serializer.fromJson<int>(json['commissionPaisa']),
      commissionRuleId: serializer.fromJson<String?>(json['commissionRuleId']),
      commissionOverridden: serializer.fromJson<bool>(
        json['commissionOverridden'],
      ),
      customerId: serializer.fromJson<String?>(json['customerId']),
      customerNumber: serializer.fromJson<String?>(json['customerNumber']),
      reference: serializer.fromJson<String?>(json['reference']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      voidedAt: serializer.fromJson<int?>(json['voidedAt']),
      replacesTxnId: serializer.fromJson<String?>(json['replacesTxnId']),
      dayCloseId: serializer.fromJson<String?>(json['dayCloseId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'recordedAt': serializer.toJson<int>(recordedAt),
      'amountPaisa': serializer.toJson<int>(amountPaisa),
      'chargePaisa': serializer.toJson<int>(chargePaisa),
      'commissionPaisa': serializer.toJson<int>(commissionPaisa),
      'commissionRuleId': serializer.toJson<String?>(commissionRuleId),
      'commissionOverridden': serializer.toJson<bool>(commissionOverridden),
      'customerId': serializer.toJson<String?>(customerId),
      'customerNumber': serializer.toJson<String?>(customerNumber),
      'reference': serializer.toJson<String?>(reference),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'voidReason': serializer.toJson<String?>(voidReason),
      'voidedAt': serializer.toJson<int?>(voidedAt),
      'replacesTxnId': serializer.toJson<String?>(replacesTxnId),
      'dayCloseId': serializer.toJson<String?>(dayCloseId),
      'createdBy': serializer.toJson<String>(createdBy),
      'shiftId': serializer.toJson<String?>(shiftId),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  TxnRow copyWith({
    String? id,
    String? type,
    int? occurredAt,
    int? recordedAt,
    int? amountPaisa,
    int? chargePaisa,
    int? commissionPaisa,
    Value<String?> commissionRuleId = const Value.absent(),
    bool? commissionOverridden,
    Value<String?> customerId = const Value.absent(),
    Value<String?> customerNumber = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? status,
    Value<String?> voidReason = const Value.absent(),
    Value<int?> voidedAt = const Value.absent(),
    Value<String?> replacesTxnId = const Value.absent(),
    Value<String?> dayCloseId = const Value.absent(),
    String? createdBy,
    Value<String?> shiftId = const Value.absent(),
    String? deviceId,
  }) => TxnRow(
    id: id ?? this.id,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    recordedAt: recordedAt ?? this.recordedAt,
    amountPaisa: amountPaisa ?? this.amountPaisa,
    chargePaisa: chargePaisa ?? this.chargePaisa,
    commissionPaisa: commissionPaisa ?? this.commissionPaisa,
    commissionRuleId: commissionRuleId.present
        ? commissionRuleId.value
        : this.commissionRuleId,
    commissionOverridden: commissionOverridden ?? this.commissionOverridden,
    customerId: customerId.present ? customerId.value : this.customerId,
    customerNumber: customerNumber.present
        ? customerNumber.value
        : this.customerNumber,
    reference: reference.present ? reference.value : this.reference,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    replacesTxnId: replacesTxnId.present
        ? replacesTxnId.value
        : this.replacesTxnId,
    dayCloseId: dayCloseId.present ? dayCloseId.value : this.dayCloseId,
    createdBy: createdBy ?? this.createdBy,
    shiftId: shiftId.present ? shiftId.value : this.shiftId,
    deviceId: deviceId ?? this.deviceId,
  );
  TxnRow copyWithCompanion(TxnsCompanion data) {
    return TxnRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      amountPaisa: data.amountPaisa.present
          ? data.amountPaisa.value
          : this.amountPaisa,
      chargePaisa: data.chargePaisa.present
          ? data.chargePaisa.value
          : this.chargePaisa,
      commissionPaisa: data.commissionPaisa.present
          ? data.commissionPaisa.value
          : this.commissionPaisa,
      commissionRuleId: data.commissionRuleId.present
          ? data.commissionRuleId.value
          : this.commissionRuleId,
      commissionOverridden: data.commissionOverridden.present
          ? data.commissionOverridden.value
          : this.commissionOverridden,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      customerNumber: data.customerNumber.present
          ? data.customerNumber.value
          : this.customerNumber,
      reference: data.reference.present ? data.reference.value : this.reference,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      replacesTxnId: data.replacesTxnId.present
          ? data.replacesTxnId.value
          : this.replacesTxnId,
      dayCloseId: data.dayCloseId.present
          ? data.dayCloseId.value
          : this.dayCloseId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TxnRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('amountPaisa: $amountPaisa, ')
          ..write('chargePaisa: $chargePaisa, ')
          ..write('commissionPaisa: $commissionPaisa, ')
          ..write('commissionRuleId: $commissionRuleId, ')
          ..write('commissionOverridden: $commissionOverridden, ')
          ..write('customerId: $customerId, ')
          ..write('customerNumber: $customerNumber, ')
          ..write('reference: $reference, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('voidReason: $voidReason, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('replacesTxnId: $replacesTxnId, ')
          ..write('dayCloseId: $dayCloseId, ')
          ..write('createdBy: $createdBy, ')
          ..write('shiftId: $shiftId, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    type,
    occurredAt,
    recordedAt,
    amountPaisa,
    chargePaisa,
    commissionPaisa,
    commissionRuleId,
    commissionOverridden,
    customerId,
    customerNumber,
    reference,
    note,
    status,
    voidReason,
    voidedAt,
    replacesTxnId,
    dayCloseId,
    createdBy,
    shiftId,
    deviceId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TxnRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.recordedAt == this.recordedAt &&
          other.amountPaisa == this.amountPaisa &&
          other.chargePaisa == this.chargePaisa &&
          other.commissionPaisa == this.commissionPaisa &&
          other.commissionRuleId == this.commissionRuleId &&
          other.commissionOverridden == this.commissionOverridden &&
          other.customerId == this.customerId &&
          other.customerNumber == this.customerNumber &&
          other.reference == this.reference &&
          other.note == this.note &&
          other.status == this.status &&
          other.voidReason == this.voidReason &&
          other.voidedAt == this.voidedAt &&
          other.replacesTxnId == this.replacesTxnId &&
          other.dayCloseId == this.dayCloseId &&
          other.createdBy == this.createdBy &&
          other.shiftId == this.shiftId &&
          other.deviceId == this.deviceId);
}

class TxnsCompanion extends UpdateCompanion<TxnRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> occurredAt;
  final Value<int> recordedAt;
  final Value<int> amountPaisa;
  final Value<int> chargePaisa;
  final Value<int> commissionPaisa;
  final Value<String?> commissionRuleId;
  final Value<bool> commissionOverridden;
  final Value<String?> customerId;
  final Value<String?> customerNumber;
  final Value<String?> reference;
  final Value<String?> note;
  final Value<String> status;
  final Value<String?> voidReason;
  final Value<int?> voidedAt;
  final Value<String?> replacesTxnId;
  final Value<String?> dayCloseId;
  final Value<String> createdBy;
  final Value<String?> shiftId;
  final Value<String> deviceId;
  final Value<int> rowid;
  const TxnsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.amountPaisa = const Value.absent(),
    this.chargePaisa = const Value.absent(),
    this.commissionPaisa = const Value.absent(),
    this.commissionRuleId = const Value.absent(),
    this.commissionOverridden = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerNumber = const Value.absent(),
    this.reference = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.replacesTxnId = const Value.absent(),
    this.dayCloseId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TxnsCompanion.insert({
    required String id,
    required String type,
    required int occurredAt,
    required int recordedAt,
    required int amountPaisa,
    this.chargePaisa = const Value.absent(),
    this.commissionPaisa = const Value.absent(),
    this.commissionRuleId = const Value.absent(),
    this.commissionOverridden = const Value.absent(),
    this.customerId = const Value.absent(),
    this.customerNumber = const Value.absent(),
    this.reference = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.replacesTxnId = const Value.absent(),
    this.dayCloseId = const Value.absent(),
    required String createdBy,
    this.shiftId = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       occurredAt = Value(occurredAt),
       recordedAt = Value(recordedAt),
       amountPaisa = Value(amountPaisa),
       createdBy = Value(createdBy),
       deviceId = Value(deviceId);
  static Insertable<TxnRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? occurredAt,
    Expression<int>? recordedAt,
    Expression<int>? amountPaisa,
    Expression<int>? chargePaisa,
    Expression<int>? commissionPaisa,
    Expression<String>? commissionRuleId,
    Expression<bool>? commissionOverridden,
    Expression<String>? customerId,
    Expression<String>? customerNumber,
    Expression<String>? reference,
    Expression<String>? note,
    Expression<String>? status,
    Expression<String>? voidReason,
    Expression<int>? voidedAt,
    Expression<String>? replacesTxnId,
    Expression<String>? dayCloseId,
    Expression<String>? createdBy,
    Expression<String>? shiftId,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (amountPaisa != null) 'amount_paisa': amountPaisa,
      if (chargePaisa != null) 'charge_paisa': chargePaisa,
      if (commissionPaisa != null) 'commission_paisa': commissionPaisa,
      if (commissionRuleId != null) 'commission_rule_id': commissionRuleId,
      if (commissionOverridden != null)
        'commission_overridden': commissionOverridden,
      if (customerId != null) 'customer_id': customerId,
      if (customerNumber != null) 'customer_number': customerNumber,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (voidReason != null) 'void_reason': voidReason,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (replacesTxnId != null) 'replaces_txn_id': replacesTxnId,
      if (dayCloseId != null) 'day_close_id': dayCloseId,
      if (createdBy != null) 'created_by': createdBy,
      if (shiftId != null) 'shift_id': shiftId,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TxnsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<int>? occurredAt,
    Value<int>? recordedAt,
    Value<int>? amountPaisa,
    Value<int>? chargePaisa,
    Value<int>? commissionPaisa,
    Value<String?>? commissionRuleId,
    Value<bool>? commissionOverridden,
    Value<String?>? customerId,
    Value<String?>? customerNumber,
    Value<String?>? reference,
    Value<String?>? note,
    Value<String>? status,
    Value<String?>? voidReason,
    Value<int?>? voidedAt,
    Value<String?>? replacesTxnId,
    Value<String?>? dayCloseId,
    Value<String>? createdBy,
    Value<String?>? shiftId,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return TxnsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      recordedAt: recordedAt ?? this.recordedAt,
      amountPaisa: amountPaisa ?? this.amountPaisa,
      chargePaisa: chargePaisa ?? this.chargePaisa,
      commissionPaisa: commissionPaisa ?? this.commissionPaisa,
      commissionRuleId: commissionRuleId ?? this.commissionRuleId,
      commissionOverridden: commissionOverridden ?? this.commissionOverridden,
      customerId: customerId ?? this.customerId,
      customerNumber: customerNumber ?? this.customerNumber,
      reference: reference ?? this.reference,
      note: note ?? this.note,
      status: status ?? this.status,
      voidReason: voidReason ?? this.voidReason,
      voidedAt: voidedAt ?? this.voidedAt,
      replacesTxnId: replacesTxnId ?? this.replacesTxnId,
      dayCloseId: dayCloseId ?? this.dayCloseId,
      createdBy: createdBy ?? this.createdBy,
      shiftId: shiftId ?? this.shiftId,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    if (amountPaisa.present) {
      map['amount_paisa'] = Variable<int>(amountPaisa.value);
    }
    if (chargePaisa.present) {
      map['charge_paisa'] = Variable<int>(chargePaisa.value);
    }
    if (commissionPaisa.present) {
      map['commission_paisa'] = Variable<int>(commissionPaisa.value);
    }
    if (commissionRuleId.present) {
      map['commission_rule_id'] = Variable<String>(commissionRuleId.value);
    }
    if (commissionOverridden.present) {
      map['commission_overridden'] = Variable<bool>(commissionOverridden.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (customerNumber.present) {
      map['customer_number'] = Variable<String>(customerNumber.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<int>(voidedAt.value);
    }
    if (replacesTxnId.present) {
      map['replaces_txn_id'] = Variable<String>(replacesTxnId.value);
    }
    if (dayCloseId.present) {
      map['day_close_id'] = Variable<String>(dayCloseId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TxnsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('amountPaisa: $amountPaisa, ')
          ..write('chargePaisa: $chargePaisa, ')
          ..write('commissionPaisa: $commissionPaisa, ')
          ..write('commissionRuleId: $commissionRuleId, ')
          ..write('commissionOverridden: $commissionOverridden, ')
          ..write('customerId: $customerId, ')
          ..write('customerNumber: $customerNumber, ')
          ..write('reference: $reference, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('voidReason: $voidReason, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('replacesTxnId: $replacesTxnId, ')
          ..write('dayCloseId: $dayCloseId, ')
          ..write('createdBy: $createdBy, ')
          ..write('shiftId: $shiftId, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txnIdMeta = const VerificationMeta('txnId');
  @override
  late final GeneratedColumn<String> txnId = GeneratedColumn<String>(
    'txn_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES txn (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account (id)',
    ),
  );
  static const VerificationMeta _deltaPaisaMeta = const VerificationMeta(
    'deltaPaisa',
  );
  @override
  late final GeneratedColumn<int> deltaPaisa = GeneratedColumn<int>(
    'delta_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
    'line_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    txnId,
    accountId,
    deltaPaisa,
    lineNo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entry';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('txn_id')) {
      context.handle(
        _txnIdMeta,
        txnId.isAcceptableOrUnknown(data['txn_id']!, _txnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_txnIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('delta_paisa')) {
      context.handle(
        _deltaPaisaMeta,
        deltaPaisa.isAcceptableOrUnknown(data['delta_paisa']!, _deltaPaisaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaPaisaMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(
        _lineNoMeta,
        lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      txnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}txn_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      deltaPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta_paisa'],
      )!,
      lineNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_no'],
      )!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntryRow extends DataClass implements Insertable<LedgerEntryRow> {
  final String id;
  final String txnId;
  final String accountId;
  final int deltaPaisa;
  final int lineNo;
  const LedgerEntryRow({
    required this.id,
    required this.txnId,
    required this.accountId,
    required this.deltaPaisa,
    required this.lineNo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['txn_id'] = Variable<String>(txnId);
    map['account_id'] = Variable<String>(accountId);
    map['delta_paisa'] = Variable<int>(deltaPaisa);
    map['line_no'] = Variable<int>(lineNo);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      txnId: Value(txnId),
      accountId: Value(accountId),
      deltaPaisa: Value(deltaPaisa),
      lineNo: Value(lineNo),
    );
  }

  factory LedgerEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntryRow(
      id: serializer.fromJson<String>(json['id']),
      txnId: serializer.fromJson<String>(json['txnId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      deltaPaisa: serializer.fromJson<int>(json['deltaPaisa']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'txnId': serializer.toJson<String>(txnId),
      'accountId': serializer.toJson<String>(accountId),
      'deltaPaisa': serializer.toJson<int>(deltaPaisa),
      'lineNo': serializer.toJson<int>(lineNo),
    };
  }

  LedgerEntryRow copyWith({
    String? id,
    String? txnId,
    String? accountId,
    int? deltaPaisa,
    int? lineNo,
  }) => LedgerEntryRow(
    id: id ?? this.id,
    txnId: txnId ?? this.txnId,
    accountId: accountId ?? this.accountId,
    deltaPaisa: deltaPaisa ?? this.deltaPaisa,
    lineNo: lineNo ?? this.lineNo,
  );
  LedgerEntryRow copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntryRow(
      id: data.id.present ? data.id.value : this.id,
      txnId: data.txnId.present ? data.txnId.value : this.txnId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      deltaPaisa: data.deltaPaisa.present
          ? data.deltaPaisa.value
          : this.deltaPaisa,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntryRow(')
          ..write('id: $id, ')
          ..write('txnId: $txnId, ')
          ..write('accountId: $accountId, ')
          ..write('deltaPaisa: $deltaPaisa, ')
          ..write('lineNo: $lineNo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, txnId, accountId, deltaPaisa, lineNo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntryRow &&
          other.id == this.id &&
          other.txnId == this.txnId &&
          other.accountId == this.accountId &&
          other.deltaPaisa == this.deltaPaisa &&
          other.lineNo == this.lineNo);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntryRow> {
  final Value<String> id;
  final Value<String> txnId;
  final Value<String> accountId;
  final Value<int> deltaPaisa;
  final Value<int> lineNo;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.txnId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.deltaPaisa = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String txnId,
    required String accountId,
    required int deltaPaisa,
    required int lineNo,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       txnId = Value(txnId),
       accountId = Value(accountId),
       deltaPaisa = Value(deltaPaisa),
       lineNo = Value(lineNo);
  static Insertable<LedgerEntryRow> custom({
    Expression<String>? id,
    Expression<String>? txnId,
    Expression<String>? accountId,
    Expression<int>? deltaPaisa,
    Expression<int>? lineNo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (txnId != null) 'txn_id': txnId,
      if (accountId != null) 'account_id': accountId,
      if (deltaPaisa != null) 'delta_paisa': deltaPaisa,
      if (lineNo != null) 'line_no': lineNo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? txnId,
    Value<String>? accountId,
    Value<int>? deltaPaisa,
    Value<int>? lineNo,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      txnId: txnId ?? this.txnId,
      accountId: accountId ?? this.accountId,
      deltaPaisa: deltaPaisa ?? this.deltaPaisa,
      lineNo: lineNo ?? this.lineNo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (txnId.present) {
      map['txn_id'] = Variable<String>(txnId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (deltaPaisa.present) {
      map['delta_paisa'] = Variable<int>(deltaPaisa.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('txnId: $txnId, ')
          ..write('accountId: $accountId, ')
          ..write('deltaPaisa: $deltaPaisa, ')
          ..write('lineNo: $lineNo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommissionRulesTable extends CommissionRules
    with TableInfo<$CommissionRulesTable, CommissionRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommissionRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txnTypeMeta = const VerificationMeta(
    'txnType',
  );
  @override
  late final GeneratedColumn<String> txnType = GeneratedColumn<String>(
    'txn_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tiersJsonMeta = const VerificationMeta(
    'tiersJson',
  );
  @override
  late final GeneratedColumn<String> tiersJson = GeneratedColumn<String>(
    'tiers_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<int> effectiveFrom = GeneratedColumn<int>(
    'effective_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveToMeta = const VerificationMeta(
    'effectiveTo',
  );
  @override
  late final GeneratedColumn<int> effectiveTo = GeneratedColumn<int>(
    'effective_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    txnType,
    mode,
    value,
    tiersJson,
    effectiveFrom,
    effectiveTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commission_rule';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommissionRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('txn_type')) {
      context.handle(
        _txnTypeMeta,
        txnType.isAcceptableOrUnknown(data['txn_type']!, _txnTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txnTypeMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('tiers_json')) {
      context.handle(
        _tiersJsonMeta,
        tiersJson.isAcceptableOrUnknown(data['tiers_json']!, _tiersJsonMeta),
      );
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('effective_to')) {
      context.handle(
        _effectiveToMeta,
        effectiveTo.isAcceptableOrUnknown(
          data['effective_to']!,
          _effectiveToMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommissionRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommissionRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      txnType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}txn_type'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      tiersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tiers_json'],
      ),
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_from'],
      )!,
      effectiveTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effective_to'],
      ),
    );
  }

  @override
  $CommissionRulesTable createAlias(String alias) {
    return $CommissionRulesTable(attachedDatabase, alias);
  }
}

class CommissionRuleRow extends DataClass
    implements Insertable<CommissionRuleRow> {
  final String id;
  final String provider;
  final String txnType;
  final String mode;
  final int value;
  final String? tiersJson;
  final int effectiveFrom;
  final int? effectiveTo;
  const CommissionRuleRow({
    required this.id,
    required this.provider,
    required this.txnType,
    required this.mode,
    required this.value,
    this.tiersJson,
    required this.effectiveFrom,
    this.effectiveTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider'] = Variable<String>(provider);
    map['txn_type'] = Variable<String>(txnType);
    map['mode'] = Variable<String>(mode);
    map['value'] = Variable<int>(value);
    if (!nullToAbsent || tiersJson != null) {
      map['tiers_json'] = Variable<String>(tiersJson);
    }
    map['effective_from'] = Variable<int>(effectiveFrom);
    if (!nullToAbsent || effectiveTo != null) {
      map['effective_to'] = Variable<int>(effectiveTo);
    }
    return map;
  }

  CommissionRulesCompanion toCompanion(bool nullToAbsent) {
    return CommissionRulesCompanion(
      id: Value(id),
      provider: Value(provider),
      txnType: Value(txnType),
      mode: Value(mode),
      value: Value(value),
      tiersJson: tiersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tiersJson),
      effectiveFrom: Value(effectiveFrom),
      effectiveTo: effectiveTo == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveTo),
    );
  }

  factory CommissionRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommissionRuleRow(
      id: serializer.fromJson<String>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      txnType: serializer.fromJson<String>(json['txnType']),
      mode: serializer.fromJson<String>(json['mode']),
      value: serializer.fromJson<int>(json['value']),
      tiersJson: serializer.fromJson<String?>(json['tiersJson']),
      effectiveFrom: serializer.fromJson<int>(json['effectiveFrom']),
      effectiveTo: serializer.fromJson<int?>(json['effectiveTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'provider': serializer.toJson<String>(provider),
      'txnType': serializer.toJson<String>(txnType),
      'mode': serializer.toJson<String>(mode),
      'value': serializer.toJson<int>(value),
      'tiersJson': serializer.toJson<String?>(tiersJson),
      'effectiveFrom': serializer.toJson<int>(effectiveFrom),
      'effectiveTo': serializer.toJson<int?>(effectiveTo),
    };
  }

  CommissionRuleRow copyWith({
    String? id,
    String? provider,
    String? txnType,
    String? mode,
    int? value,
    Value<String?> tiersJson = const Value.absent(),
    int? effectiveFrom,
    Value<int?> effectiveTo = const Value.absent(),
  }) => CommissionRuleRow(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    txnType: txnType ?? this.txnType,
    mode: mode ?? this.mode,
    value: value ?? this.value,
    tiersJson: tiersJson.present ? tiersJson.value : this.tiersJson,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    effectiveTo: effectiveTo.present ? effectiveTo.value : this.effectiveTo,
  );
  CommissionRuleRow copyWithCompanion(CommissionRulesCompanion data) {
    return CommissionRuleRow(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      txnType: data.txnType.present ? data.txnType.value : this.txnType,
      mode: data.mode.present ? data.mode.value : this.mode,
      value: data.value.present ? data.value.value : this.value,
      tiersJson: data.tiersJson.present ? data.tiersJson.value : this.tiersJson,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      effectiveTo: data.effectiveTo.present
          ? data.effectiveTo.value
          : this.effectiveTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommissionRuleRow(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('txnType: $txnType, ')
          ..write('mode: $mode, ')
          ..write('value: $value, ')
          ..write('tiersJson: $tiersJson, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    provider,
    txnType,
    mode,
    value,
    tiersJson,
    effectiveFrom,
    effectiveTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommissionRuleRow &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.txnType == this.txnType &&
          other.mode == this.mode &&
          other.value == this.value &&
          other.tiersJson == this.tiersJson &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveTo == this.effectiveTo);
}

class CommissionRulesCompanion extends UpdateCompanion<CommissionRuleRow> {
  final Value<String> id;
  final Value<String> provider;
  final Value<String> txnType;
  final Value<String> mode;
  final Value<int> value;
  final Value<String?> tiersJson;
  final Value<int> effectiveFrom;
  final Value<int?> effectiveTo;
  final Value<int> rowid;
  const CommissionRulesCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.txnType = const Value.absent(),
    this.mode = const Value.absent(),
    this.value = const Value.absent(),
    this.tiersJson = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommissionRulesCompanion.insert({
    required String id,
    required String provider,
    required String txnType,
    required String mode,
    required int value,
    this.tiersJson = const Value.absent(),
    required int effectiveFrom,
    this.effectiveTo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       provider = Value(provider),
       txnType = Value(txnType),
       mode = Value(mode),
       value = Value(value),
       effectiveFrom = Value(effectiveFrom);
  static Insertable<CommissionRuleRow> custom({
    Expression<String>? id,
    Expression<String>? provider,
    Expression<String>? txnType,
    Expression<String>? mode,
    Expression<int>? value,
    Expression<String>? tiersJson,
    Expression<int>? effectiveFrom,
    Expression<int>? effectiveTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (txnType != null) 'txn_type': txnType,
      if (mode != null) 'mode': mode,
      if (value != null) 'value': value,
      if (tiersJson != null) 'tiers_json': tiersJson,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveTo != null) 'effective_to': effectiveTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommissionRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? provider,
    Value<String>? txnType,
    Value<String>? mode,
    Value<int>? value,
    Value<String?>? tiersJson,
    Value<int>? effectiveFrom,
    Value<int?>? effectiveTo,
    Value<int>? rowid,
  }) {
    return CommissionRulesCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      txnType: txnType ?? this.txnType,
      mode: mode ?? this.mode,
      value: value ?? this.value,
      tiersJson: tiersJson ?? this.tiersJson,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (txnType.present) {
      map['txn_type'] = Variable<String>(txnType.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (tiersJson.present) {
      map['tiers_json'] = Variable<String>(tiersJson.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<int>(effectiveFrom.value);
    }
    if (effectiveTo.present) {
      map['effective_to'] = Variable<int>(effectiveTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommissionRulesCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('txnType: $txnType, ')
          ..write('mode: $mode, ')
          ..write('value: $value, ')
          ..write('tiersJson: $tiersJson, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String? name;
  final String? phone;
  final String? note;
  final int createdAt;
  const CustomerRow({
    required this.id,
    this.name,
    this.phone,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'phone': serializer.toJson<String?>(phone),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CustomerRow copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAt,
  }) => CustomerRow(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    phone: phone.present ? phone.value : this.phone,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> phone;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<String?>? phone,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayClosesTable extends DayCloses
    with TableInfo<$DayClosesTable, DayCloseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayClosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByMeta = const VerificationMeta(
    'closedBy',
  );
  @override
  late final GeneratedColumn<String> closedBy = GeneratedColumn<String>(
    'closed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<int> closedAt = GeneratedColumn<int>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reopenedByMeta = const VerificationMeta(
    'reopenedBy',
  );
  @override
  late final GeneratedColumn<String> reopenedBy = GeneratedColumn<String>(
    'reopened_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reopenedAtMeta = const VerificationMeta(
    'reopenedAt',
  );
  @override
  late final GeneratedColumn<int> reopenedAt = GeneratedColumn<int>(
    'reopened_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reopenReasonMeta = const VerificationMeta(
    'reopenReason',
  );
  @override
  late final GeneratedColumn<String> reopenReason = GeneratedColumn<String>(
    'reopen_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessDate,
    status,
    note,
    closedBy,
    closedAt,
    reopenedBy,
    reopenedAt,
    reopenReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_close';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCloseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('closed_by')) {
      context.handle(
        _closedByMeta,
        closedBy.isAcceptableOrUnknown(data['closed_by']!, _closedByMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('reopened_by')) {
      context.handle(
        _reopenedByMeta,
        reopenedBy.isAcceptableOrUnknown(data['reopened_by']!, _reopenedByMeta),
      );
    }
    if (data.containsKey('reopened_at')) {
      context.handle(
        _reopenedAtMeta,
        reopenedAt.isAcceptableOrUnknown(data['reopened_at']!, _reopenedAtMeta),
      );
    }
    if (data.containsKey('reopen_reason')) {
      context.handle(
        _reopenReasonMeta,
        reopenReason.isAcceptableOrUnknown(
          data['reopen_reason']!,
          _reopenReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayCloseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCloseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      closedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_at'],
      ),
      reopenedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reopened_by'],
      ),
      reopenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reopened_at'],
      ),
      reopenReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reopen_reason'],
      ),
    );
  }

  @override
  $DayClosesTable createAlias(String alias) {
    return $DayClosesTable(attachedDatabase, alias);
  }
}

class DayCloseRow extends DataClass implements Insertable<DayCloseRow> {
  final String id;
  final String businessDate;
  final String status;
  final String? note;
  final String? closedBy;
  final int? closedAt;
  final String? reopenedBy;
  final int? reopenedAt;
  final String? reopenReason;
  const DayCloseRow({
    required this.id,
    required this.businessDate,
    required this.status,
    this.note,
    this.closedBy,
    this.closedAt,
    this.reopenedBy,
    this.reopenedAt,
    this.reopenReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_date'] = Variable<String>(businessDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || closedBy != null) {
      map['closed_by'] = Variable<String>(closedBy);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<int>(closedAt);
    }
    if (!nullToAbsent || reopenedBy != null) {
      map['reopened_by'] = Variable<String>(reopenedBy);
    }
    if (!nullToAbsent || reopenedAt != null) {
      map['reopened_at'] = Variable<int>(reopenedAt);
    }
    if (!nullToAbsent || reopenReason != null) {
      map['reopen_reason'] = Variable<String>(reopenReason);
    }
    return map;
  }

  DayClosesCompanion toCompanion(bool nullToAbsent) {
    return DayClosesCompanion(
      id: Value(id),
      businessDate: Value(businessDate),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      closedBy: closedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(closedBy),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      reopenedBy: reopenedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(reopenedBy),
      reopenedAt: reopenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reopenedAt),
      reopenReason: reopenReason == null && nullToAbsent
          ? const Value.absent()
          : Value(reopenReason),
    );
  }

  factory DayCloseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCloseRow(
      id: serializer.fromJson<String>(json['id']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      closedBy: serializer.fromJson<String?>(json['closedBy']),
      closedAt: serializer.fromJson<int?>(json['closedAt']),
      reopenedBy: serializer.fromJson<String?>(json['reopenedBy']),
      reopenedAt: serializer.fromJson<int?>(json['reopenedAt']),
      reopenReason: serializer.fromJson<String?>(json['reopenReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessDate': serializer.toJson<String>(businessDate),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'closedBy': serializer.toJson<String?>(closedBy),
      'closedAt': serializer.toJson<int?>(closedAt),
      'reopenedBy': serializer.toJson<String?>(reopenedBy),
      'reopenedAt': serializer.toJson<int?>(reopenedAt),
      'reopenReason': serializer.toJson<String?>(reopenReason),
    };
  }

  DayCloseRow copyWith({
    String? id,
    String? businessDate,
    String? status,
    Value<String?> note = const Value.absent(),
    Value<String?> closedBy = const Value.absent(),
    Value<int?> closedAt = const Value.absent(),
    Value<String?> reopenedBy = const Value.absent(),
    Value<int?> reopenedAt = const Value.absent(),
    Value<String?> reopenReason = const Value.absent(),
  }) => DayCloseRow(
    id: id ?? this.id,
    businessDate: businessDate ?? this.businessDate,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    closedBy: closedBy.present ? closedBy.value : this.closedBy,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    reopenedBy: reopenedBy.present ? reopenedBy.value : this.reopenedBy,
    reopenedAt: reopenedAt.present ? reopenedAt.value : this.reopenedAt,
    reopenReason: reopenReason.present ? reopenReason.value : this.reopenReason,
  );
  DayCloseRow copyWithCompanion(DayClosesCompanion data) {
    return DayCloseRow(
      id: data.id.present ? data.id.value : this.id,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      closedBy: data.closedBy.present ? data.closedBy.value : this.closedBy,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      reopenedBy: data.reopenedBy.present
          ? data.reopenedBy.value
          : this.reopenedBy,
      reopenedAt: data.reopenedAt.present
          ? data.reopenedAt.value
          : this.reopenedAt,
      reopenReason: data.reopenReason.present
          ? data.reopenReason.value
          : this.reopenReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayCloseRow(')
          ..write('id: $id, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('closedBy: $closedBy, ')
          ..write('closedAt: $closedAt, ')
          ..write('reopenedBy: $reopenedBy, ')
          ..write('reopenedAt: $reopenedAt, ')
          ..write('reopenReason: $reopenReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessDate,
    status,
    note,
    closedBy,
    closedAt,
    reopenedBy,
    reopenedAt,
    reopenReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayCloseRow &&
          other.id == this.id &&
          other.businessDate == this.businessDate &&
          other.status == this.status &&
          other.note == this.note &&
          other.closedBy == this.closedBy &&
          other.closedAt == this.closedAt &&
          other.reopenedBy == this.reopenedBy &&
          other.reopenedAt == this.reopenedAt &&
          other.reopenReason == this.reopenReason);
}

class DayClosesCompanion extends UpdateCompanion<DayCloseRow> {
  final Value<String> id;
  final Value<String> businessDate;
  final Value<String> status;
  final Value<String?> note;
  final Value<String?> closedBy;
  final Value<int?> closedAt;
  final Value<String?> reopenedBy;
  final Value<int?> reopenedAt;
  final Value<String?> reopenReason;
  final Value<int> rowid;
  const DayClosesCompanion({
    this.id = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.reopenedBy = const Value.absent(),
    this.reopenedAt = const Value.absent(),
    this.reopenReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayClosesCompanion.insert({
    required String id,
    required String businessDate,
    required String status,
    this.note = const Value.absent(),
    this.closedBy = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.reopenedBy = const Value.absent(),
    this.reopenedAt = const Value.absent(),
    this.reopenReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       businessDate = Value(businessDate),
       status = Value(status);
  static Insertable<DayCloseRow> custom({
    Expression<String>? id,
    Expression<String>? businessDate,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? closedBy,
    Expression<int>? closedAt,
    Expression<String>? reopenedBy,
    Expression<int>? reopenedAt,
    Expression<String>? reopenReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessDate != null) 'business_date': businessDate,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (closedBy != null) 'closed_by': closedBy,
      if (closedAt != null) 'closed_at': closedAt,
      if (reopenedBy != null) 'reopened_by': reopenedBy,
      if (reopenedAt != null) 'reopened_at': reopenedAt,
      if (reopenReason != null) 'reopen_reason': reopenReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayClosesCompanion copyWith({
    Value<String>? id,
    Value<String>? businessDate,
    Value<String>? status,
    Value<String?>? note,
    Value<String?>? closedBy,
    Value<int?>? closedAt,
    Value<String?>? reopenedBy,
    Value<int?>? reopenedAt,
    Value<String?>? reopenReason,
    Value<int>? rowid,
  }) {
    return DayClosesCompanion(
      id: id ?? this.id,
      businessDate: businessDate ?? this.businessDate,
      status: status ?? this.status,
      note: note ?? this.note,
      closedBy: closedBy ?? this.closedBy,
      closedAt: closedAt ?? this.closedAt,
      reopenedBy: reopenedBy ?? this.reopenedBy,
      reopenedAt: reopenedAt ?? this.reopenedAt,
      reopenReason: reopenReason ?? this.reopenReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (closedBy.present) {
      map['closed_by'] = Variable<String>(closedBy.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<int>(closedAt.value);
    }
    if (reopenedBy.present) {
      map['reopened_by'] = Variable<String>(reopenedBy.value);
    }
    if (reopenedAt.present) {
      map['reopened_at'] = Variable<int>(reopenedAt.value);
    }
    if (reopenReason.present) {
      map['reopen_reason'] = Variable<String>(reopenReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayClosesCompanion(')
          ..write('id: $id, ')
          ..write('businessDate: $businessDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('closedBy: $closedBy, ')
          ..write('closedAt: $closedAt, ')
          ..write('reopenedBy: $reopenedBy, ')
          ..write('reopenedAt: $reopenedAt, ')
          ..write('reopenReason: $reopenReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayCloseLinesTable extends DayCloseLines
    with TableInfo<$DayCloseLinesTable, DayCloseLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayCloseLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayCloseIdMeta = const VerificationMeta(
    'dayCloseId',
  );
  @override
  late final GeneratedColumn<String> dayCloseId = GeneratedColumn<String>(
    'day_close_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES day_close (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account (id)',
    ),
  );
  static const VerificationMeta _expectedPaisaMeta = const VerificationMeta(
    'expectedPaisa',
  );
  @override
  late final GeneratedColumn<int> expectedPaisa = GeneratedColumn<int>(
    'expected_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualPaisaMeta = const VerificationMeta(
    'actualPaisa',
  );
  @override
  late final GeneratedColumn<int> actualPaisa = GeneratedColumn<int>(
    'actual_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variancePaisaMeta = const VerificationMeta(
    'variancePaisa',
  );
  @override
  late final GeneratedColumn<int> variancePaisa = GeneratedColumn<int>(
    'variance_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adjustmentTxnIdMeta = const VerificationMeta(
    'adjustmentTxnId',
  );
  @override
  late final GeneratedColumn<String> adjustmentTxnId = GeneratedColumn<String>(
    'adjustment_txn_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    dayCloseId,
    accountId,
    expectedPaisa,
    actualPaisa,
    variancePaisa,
    adjustmentTxnId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_close_line';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayCloseLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_close_id')) {
      context.handle(
        _dayCloseIdMeta,
        dayCloseId.isAcceptableOrUnknown(
          data['day_close_id']!,
          _dayCloseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayCloseIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('expected_paisa')) {
      context.handle(
        _expectedPaisaMeta,
        expectedPaisa.isAcceptableOrUnknown(
          data['expected_paisa']!,
          _expectedPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedPaisaMeta);
    }
    if (data.containsKey('actual_paisa')) {
      context.handle(
        _actualPaisaMeta,
        actualPaisa.isAcceptableOrUnknown(
          data['actual_paisa']!,
          _actualPaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualPaisaMeta);
    }
    if (data.containsKey('variance_paisa')) {
      context.handle(
        _variancePaisaMeta,
        variancePaisa.isAcceptableOrUnknown(
          data['variance_paisa']!,
          _variancePaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variancePaisaMeta);
    }
    if (data.containsKey('adjustment_txn_id')) {
      context.handle(
        _adjustmentTxnIdMeta,
        adjustmentTxnId.isAcceptableOrUnknown(
          data['adjustment_txn_id']!,
          _adjustmentTxnIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayCloseId, accountId};
  @override
  DayCloseLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayCloseLineRow(
      dayCloseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_close_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      expectedPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_paisa'],
      )!,
      actualPaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_paisa'],
      )!,
      variancePaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}variance_paisa'],
      )!,
      adjustmentTxnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment_txn_id'],
      ),
    );
  }

  @override
  $DayCloseLinesTable createAlias(String alias) {
    return $DayCloseLinesTable(attachedDatabase, alias);
  }
}

class DayCloseLineRow extends DataClass implements Insertable<DayCloseLineRow> {
  final String dayCloseId;
  final String accountId;
  final int expectedPaisa;
  final int actualPaisa;
  final int variancePaisa;
  final String? adjustmentTxnId;
  const DayCloseLineRow({
    required this.dayCloseId,
    required this.accountId,
    required this.expectedPaisa,
    required this.actualPaisa,
    required this.variancePaisa,
    this.adjustmentTxnId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_close_id'] = Variable<String>(dayCloseId);
    map['account_id'] = Variable<String>(accountId);
    map['expected_paisa'] = Variable<int>(expectedPaisa);
    map['actual_paisa'] = Variable<int>(actualPaisa);
    map['variance_paisa'] = Variable<int>(variancePaisa);
    if (!nullToAbsent || adjustmentTxnId != null) {
      map['adjustment_txn_id'] = Variable<String>(adjustmentTxnId);
    }
    return map;
  }

  DayCloseLinesCompanion toCompanion(bool nullToAbsent) {
    return DayCloseLinesCompanion(
      dayCloseId: Value(dayCloseId),
      accountId: Value(accountId),
      expectedPaisa: Value(expectedPaisa),
      actualPaisa: Value(actualPaisa),
      variancePaisa: Value(variancePaisa),
      adjustmentTxnId: adjustmentTxnId == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustmentTxnId),
    );
  }

  factory DayCloseLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayCloseLineRow(
      dayCloseId: serializer.fromJson<String>(json['dayCloseId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      expectedPaisa: serializer.fromJson<int>(json['expectedPaisa']),
      actualPaisa: serializer.fromJson<int>(json['actualPaisa']),
      variancePaisa: serializer.fromJson<int>(json['variancePaisa']),
      adjustmentTxnId: serializer.fromJson<String?>(json['adjustmentTxnId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayCloseId': serializer.toJson<String>(dayCloseId),
      'accountId': serializer.toJson<String>(accountId),
      'expectedPaisa': serializer.toJson<int>(expectedPaisa),
      'actualPaisa': serializer.toJson<int>(actualPaisa),
      'variancePaisa': serializer.toJson<int>(variancePaisa),
      'adjustmentTxnId': serializer.toJson<String?>(adjustmentTxnId),
    };
  }

  DayCloseLineRow copyWith({
    String? dayCloseId,
    String? accountId,
    int? expectedPaisa,
    int? actualPaisa,
    int? variancePaisa,
    Value<String?> adjustmentTxnId = const Value.absent(),
  }) => DayCloseLineRow(
    dayCloseId: dayCloseId ?? this.dayCloseId,
    accountId: accountId ?? this.accountId,
    expectedPaisa: expectedPaisa ?? this.expectedPaisa,
    actualPaisa: actualPaisa ?? this.actualPaisa,
    variancePaisa: variancePaisa ?? this.variancePaisa,
    adjustmentTxnId: adjustmentTxnId.present
        ? adjustmentTxnId.value
        : this.adjustmentTxnId,
  );
  DayCloseLineRow copyWithCompanion(DayCloseLinesCompanion data) {
    return DayCloseLineRow(
      dayCloseId: data.dayCloseId.present
          ? data.dayCloseId.value
          : this.dayCloseId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      expectedPaisa: data.expectedPaisa.present
          ? data.expectedPaisa.value
          : this.expectedPaisa,
      actualPaisa: data.actualPaisa.present
          ? data.actualPaisa.value
          : this.actualPaisa,
      variancePaisa: data.variancePaisa.present
          ? data.variancePaisa.value
          : this.variancePaisa,
      adjustmentTxnId: data.adjustmentTxnId.present
          ? data.adjustmentTxnId.value
          : this.adjustmentTxnId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayCloseLineRow(')
          ..write('dayCloseId: $dayCloseId, ')
          ..write('accountId: $accountId, ')
          ..write('expectedPaisa: $expectedPaisa, ')
          ..write('actualPaisa: $actualPaisa, ')
          ..write('variancePaisa: $variancePaisa, ')
          ..write('adjustmentTxnId: $adjustmentTxnId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    dayCloseId,
    accountId,
    expectedPaisa,
    actualPaisa,
    variancePaisa,
    adjustmentTxnId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayCloseLineRow &&
          other.dayCloseId == this.dayCloseId &&
          other.accountId == this.accountId &&
          other.expectedPaisa == this.expectedPaisa &&
          other.actualPaisa == this.actualPaisa &&
          other.variancePaisa == this.variancePaisa &&
          other.adjustmentTxnId == this.adjustmentTxnId);
}

class DayCloseLinesCompanion extends UpdateCompanion<DayCloseLineRow> {
  final Value<String> dayCloseId;
  final Value<String> accountId;
  final Value<int> expectedPaisa;
  final Value<int> actualPaisa;
  final Value<int> variancePaisa;
  final Value<String?> adjustmentTxnId;
  final Value<int> rowid;
  const DayCloseLinesCompanion({
    this.dayCloseId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.expectedPaisa = const Value.absent(),
    this.actualPaisa = const Value.absent(),
    this.variancePaisa = const Value.absent(),
    this.adjustmentTxnId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayCloseLinesCompanion.insert({
    required String dayCloseId,
    required String accountId,
    required int expectedPaisa,
    required int actualPaisa,
    required int variancePaisa,
    this.adjustmentTxnId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dayCloseId = Value(dayCloseId),
       accountId = Value(accountId),
       expectedPaisa = Value(expectedPaisa),
       actualPaisa = Value(actualPaisa),
       variancePaisa = Value(variancePaisa);
  static Insertable<DayCloseLineRow> custom({
    Expression<String>? dayCloseId,
    Expression<String>? accountId,
    Expression<int>? expectedPaisa,
    Expression<int>? actualPaisa,
    Expression<int>? variancePaisa,
    Expression<String>? adjustmentTxnId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayCloseId != null) 'day_close_id': dayCloseId,
      if (accountId != null) 'account_id': accountId,
      if (expectedPaisa != null) 'expected_paisa': expectedPaisa,
      if (actualPaisa != null) 'actual_paisa': actualPaisa,
      if (variancePaisa != null) 'variance_paisa': variancePaisa,
      if (adjustmentTxnId != null) 'adjustment_txn_id': adjustmentTxnId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayCloseLinesCompanion copyWith({
    Value<String>? dayCloseId,
    Value<String>? accountId,
    Value<int>? expectedPaisa,
    Value<int>? actualPaisa,
    Value<int>? variancePaisa,
    Value<String?>? adjustmentTxnId,
    Value<int>? rowid,
  }) {
    return DayCloseLinesCompanion(
      dayCloseId: dayCloseId ?? this.dayCloseId,
      accountId: accountId ?? this.accountId,
      expectedPaisa: expectedPaisa ?? this.expectedPaisa,
      actualPaisa: actualPaisa ?? this.actualPaisa,
      variancePaisa: variancePaisa ?? this.variancePaisa,
      adjustmentTxnId: adjustmentTxnId ?? this.adjustmentTxnId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayCloseId.present) {
      map['day_close_id'] = Variable<String>(dayCloseId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (expectedPaisa.present) {
      map['expected_paisa'] = Variable<int>(expectedPaisa.value);
    }
    if (actualPaisa.present) {
      map['actual_paisa'] = Variable<int>(actualPaisa.value);
    }
    if (variancePaisa.present) {
      map['variance_paisa'] = Variable<int>(variancePaisa.value);
    }
    if (adjustmentTxnId.present) {
      map['adjustment_txn_id'] = Variable<String>(adjustmentTxnId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayCloseLinesCompanion(')
          ..write('dayCloseId: $dayCloseId, ')
          ..write('accountId: $accountId, ')
          ..write('expectedPaisa: $expectedPaisa, ')
          ..write('actualPaisa: $actualPaisa, ')
          ..write('variancePaisa: $variancePaisa, ')
          ..write('adjustmentTxnId: $adjustmentTxnId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_category';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategoryRow extends DataClass
    implements Insertable<ExpenseCategoryRow> {
  final String id;
  final String name;
  final bool isDefault;
  const ExpenseCategoryRow({
    required this.id,
    required this.name,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      isDefault: Value(isDefault),
    );
  }

  factory ExpenseCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  ExpenseCategoryRow copyWith({String? id, String? name, bool? isDefault}) =>
      ExpenseCategoryRow(
        id: id ?? this.id,
        name: name ?? this.name,
        isDefault: isDefault ?? this.isDefault,
      );
  ExpenseCategoryRow copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    required String id,
    required String name,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ExpenseCategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsersTable extends AppUsers
    with TableInfo<$AppUsersTable, AppUserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canSeeProfitMeta = const VerificationMeta(
    'canSeeProfit',
  );
  @override
  late final GeneratedColumn<bool> canSeeProfit = GeneratedColumn<bool>(
    'can_see_profit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_see_profit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    role,
    pinHash,
    canSeeProfit,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_user';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    }
    if (data.containsKey('can_see_profit')) {
      context.handle(
        _canSeeProfitMeta,
        canSeeProfit.isAcceptableOrUnknown(
          data['can_see_profit']!,
          _canSeeProfitMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      ),
      canSeeProfit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_see_profit'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUserRow extends DataClass implements Insertable<AppUserRow> {
  final String id;
  final String name;
  final String role;
  final String? pinHash;
  final bool canSeeProfit;
  final bool isActive;
  const AppUserRow({
    required this.id,
    required this.name,
    required this.role,
    this.pinHash,
    required this.canSeeProfit,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['can_see_profit'] = Variable<bool>(canSeeProfit);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      name: Value(name),
      role: Value(role),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      canSeeProfit: Value(canSeeProfit),
      isActive: Value(isActive),
    );
  }

  factory AppUserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUserRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      canSeeProfit: serializer.fromJson<bool>(json['canSeeProfit']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'pinHash': serializer.toJson<String?>(pinHash),
      'canSeeProfit': serializer.toJson<bool>(canSeeProfit),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  AppUserRow copyWith({
    String? id,
    String? name,
    String? role,
    Value<String?> pinHash = const Value.absent(),
    bool? canSeeProfit,
    bool? isActive,
  }) => AppUserRow(
    id: id ?? this.id,
    name: name ?? this.name,
    role: role ?? this.role,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    canSeeProfit: canSeeProfit ?? this.canSeeProfit,
    isActive: isActive ?? this.isActive,
  );
  AppUserRow copyWithCompanion(AppUsersCompanion data) {
    return AppUserRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      canSeeProfit: data.canSeeProfit.present
          ? data.canSeeProfit.value
          : this.canSeeProfit,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUserRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('canSeeProfit: $canSeeProfit, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, role, pinHash, canSeeProfit, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUserRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.pinHash == this.pinHash &&
          other.canSeeProfit == this.canSeeProfit &&
          other.isActive == this.isActive);
}

class AppUsersCompanion extends UpdateCompanion<AppUserRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> pinHash;
  final Value<bool> canSeeProfit;
  final Value<bool> isActive;
  final Value<int> rowid;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.canSeeProfit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsersCompanion.insert({
    required String id,
    required String name,
    required String role,
    this.pinHash = const Value.absent(),
    this.canSeeProfit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       role = Value(role);
  static Insertable<AppUserRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? pinHash,
    Expression<bool>? canSeeProfit,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (pinHash != null) 'pin_hash': pinHash,
      if (canSeeProfit != null) 'can_see_profit': canSeeProfit,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? role,
    Value<String?>? pinHash,
    Value<bool>? canSeeProfit,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return AppUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      pinHash: pinHash ?? this.pinHash,
      canSeeProfit: canSeeProfit ?? this.canSeeProfit,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (canSeeProfit.present) {
      map['can_see_profit'] = Variable<bool>(canSeeProfit.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('pinHash: $pinHash, ')
          ..write('canSeeProfit: $canSeeProfit, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beforeJsonMeta = const VerificationMeta(
    'beforeJson',
  );
  @override
  late final GeneratedColumn<String> beforeJson = GeneratedColumn<String>(
    'before_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterJsonMeta = const VerificationMeta(
    'afterJson',
  );
  @override
  late final GeneratedColumn<String> afterJson = GeneratedColumn<String>(
    'after_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    at,
    userId,
    action,
    entity,
    entityId,
    beforeJson,
    afterJson,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('before_json')) {
      context.handle(
        _beforeJsonMeta,
        beforeJson.isAcceptableOrUnknown(data['before_json']!, _beforeJsonMeta),
      );
    }
    if (data.containsKey('after_json')) {
      context.handle(
        _afterJsonMeta,
        afterJson.isAcceptableOrUnknown(data['after_json']!, _afterJsonMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      beforeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_json'],
      ),
      afterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_json'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLogRow extends DataClass implements Insertable<AuditLogRow> {
  final String id;
  final int at;
  final String userId;
  final String action;
  final String entity;
  final String? entityId;
  final String? beforeJson;
  final String? afterJson;
  final String? reason;
  const AuditLogRow({
    required this.id,
    required this.at,
    required this.userId,
    required this.action,
    required this.entity,
    this.entityId,
    this.beforeJson,
    this.afterJson,
    this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['at'] = Variable<int>(at);
    map['user_id'] = Variable<String>(userId);
    map['action'] = Variable<String>(action);
    map['entity'] = Variable<String>(entity);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    if (!nullToAbsent || beforeJson != null) {
      map['before_json'] = Variable<String>(beforeJson);
    }
    if (!nullToAbsent || afterJson != null) {
      map['after_json'] = Variable<String>(afterJson);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      at: Value(at),
      userId: Value(userId),
      action: Value(action),
      entity: Value(entity),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      beforeJson: beforeJson == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeJson),
      afterJson: afterJson == null && nullToAbsent
          ? const Value.absent()
          : Value(afterJson),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory AuditLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogRow(
      id: serializer.fromJson<String>(json['id']),
      at: serializer.fromJson<int>(json['at']),
      userId: serializer.fromJson<String>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      beforeJson: serializer.fromJson<String?>(json['beforeJson']),
      afterJson: serializer.fromJson<String?>(json['afterJson']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'at': serializer.toJson<int>(at),
      'userId': serializer.toJson<String>(userId),
      'action': serializer.toJson<String>(action),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String?>(entityId),
      'beforeJson': serializer.toJson<String?>(beforeJson),
      'afterJson': serializer.toJson<String?>(afterJson),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  AuditLogRow copyWith({
    String? id,
    int? at,
    String? userId,
    String? action,
    String? entity,
    Value<String?> entityId = const Value.absent(),
    Value<String?> beforeJson = const Value.absent(),
    Value<String?> afterJson = const Value.absent(),
    Value<String?> reason = const Value.absent(),
  }) => AuditLogRow(
    id: id ?? this.id,
    at: at ?? this.at,
    userId: userId ?? this.userId,
    action: action ?? this.action,
    entity: entity ?? this.entity,
    entityId: entityId.present ? entityId.value : this.entityId,
    beforeJson: beforeJson.present ? beforeJson.value : this.beforeJson,
    afterJson: afterJson.present ? afterJson.value : this.afterJson,
    reason: reason.present ? reason.value : this.reason,
  );
  AuditLogRow copyWithCompanion(AuditLogsCompanion data) {
    return AuditLogRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      beforeJson: data.beforeJson.present
          ? data.beforeJson.value
          : this.beforeJson,
      afterJson: data.afterJson.present ? data.afterJson.value : this.afterJson,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    at,
    userId,
    action,
    entity,
    entityId,
    beforeJson,
    afterJson,
    reason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.beforeJson == this.beforeJson &&
          other.afterJson == this.afterJson &&
          other.reason == this.reason);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLogRow> {
  final Value<String> id;
  final Value<int> at;
  final Value<String> userId;
  final Value<String> action;
  final Value<String> entity;
  final Value<String?> entityId;
  final Value<String?> beforeJson;
  final Value<String?> afterJson;
  final Value<String?> reason;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required int at,
    required String userId,
    required String action,
    required String entity,
    this.entityId = const Value.absent(),
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       userId = Value(userId),
       action = Value(action),
       entity = Value(entity);
  static Insertable<AuditLogRow> custom({
    Expression<String>? id,
    Expression<int>? at,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? beforeJson,
    Expression<String>? afterJson,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (beforeJson != null) 'before_json': beforeJson,
      if (afterJson != null) 'after_json': afterJson,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<int>? at,
    Value<String>? userId,
    Value<String>? action,
    Value<String>? entity,
    Value<String?>? entityId,
    Value<String?>? beforeJson,
    Value<String?>? afterJson,
    Value<String?>? reason,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      beforeJson: beforeJson ?? this.beforeJson,
      afterJson: afterJson ?? this.afterJson,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (beforeJson.present) {
      map['before_json'] = Variable<String>(beforeJson.value);
    }
    if (afterJson.present) {
      map['after_json'] = Variable<String>(afterJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceSnapshotsTable extends BalanceSnapshots
    with TableInfo<$BalanceSnapshotsTable, BalanceSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES account (id)',
    ),
  );
  static const VerificationMeta _businessDateMeta = const VerificationMeta(
    'businessDate',
  );
  @override
  late final GeneratedColumn<String> businessDate = GeneratedColumn<String>(
    'business_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balancePaisaMeta = const VerificationMeta(
    'balancePaisa',
  );
  @override
  late final GeneratedColumn<int> balancePaisa = GeneratedColumn<int>(
    'balance_paisa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxTxnRowidMeta = const VerificationMeta(
    'maxTxnRowid',
  );
  @override
  late final GeneratedColumn<int> maxTxnRowid = GeneratedColumn<int>(
    'max_txn_rowid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    businessDate,
    balancePaisa,
    maxTxnRowid,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_snapshot';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('business_date')) {
      context.handle(
        _businessDateMeta,
        businessDate.isAcceptableOrUnknown(
          data['business_date']!,
          _businessDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessDateMeta);
    }
    if (data.containsKey('balance_paisa')) {
      context.handle(
        _balancePaisaMeta,
        balancePaisa.isAcceptableOrUnknown(
          data['balance_paisa']!,
          _balancePaisaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_balancePaisaMeta);
    }
    if (data.containsKey('max_txn_rowid')) {
      context.handle(
        _maxTxnRowidMeta,
        maxTxnRowid.isAcceptableOrUnknown(
          data['max_txn_rowid']!,
          _maxTxnRowidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxTxnRowidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, businessDate};
  @override
  BalanceSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceSnapshotRow(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      businessDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_date'],
      )!,
      balancePaisa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_paisa'],
      )!,
      maxTxnRowid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_txn_rowid'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BalanceSnapshotsTable createAlias(String alias) {
    return $BalanceSnapshotsTable(attachedDatabase, alias);
  }
}

class BalanceSnapshotRow extends DataClass
    implements Insertable<BalanceSnapshotRow> {
  final String accountId;
  final String businessDate;
  final int balancePaisa;

  /// Highest `txn.rowid` that was included when the snapshot was taken.
  final int maxTxnRowid;
  final int createdAt;
  const BalanceSnapshotRow({
    required this.accountId,
    required this.businessDate,
    required this.balancePaisa,
    required this.maxTxnRowid,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['business_date'] = Variable<String>(businessDate);
    map['balance_paisa'] = Variable<int>(balancePaisa);
    map['max_txn_rowid'] = Variable<int>(maxTxnRowid);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BalanceSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BalanceSnapshotsCompanion(
      accountId: Value(accountId),
      businessDate: Value(businessDate),
      balancePaisa: Value(balancePaisa),
      maxTxnRowid: Value(maxTxnRowid),
      createdAt: Value(createdAt),
    );
  }

  factory BalanceSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceSnapshotRow(
      accountId: serializer.fromJson<String>(json['accountId']),
      businessDate: serializer.fromJson<String>(json['businessDate']),
      balancePaisa: serializer.fromJson<int>(json['balancePaisa']),
      maxTxnRowid: serializer.fromJson<int>(json['maxTxnRowid']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'businessDate': serializer.toJson<String>(businessDate),
      'balancePaisa': serializer.toJson<int>(balancePaisa),
      'maxTxnRowid': serializer.toJson<int>(maxTxnRowid),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  BalanceSnapshotRow copyWith({
    String? accountId,
    String? businessDate,
    int? balancePaisa,
    int? maxTxnRowid,
    int? createdAt,
  }) => BalanceSnapshotRow(
    accountId: accountId ?? this.accountId,
    businessDate: businessDate ?? this.businessDate,
    balancePaisa: balancePaisa ?? this.balancePaisa,
    maxTxnRowid: maxTxnRowid ?? this.maxTxnRowid,
    createdAt: createdAt ?? this.createdAt,
  );
  BalanceSnapshotRow copyWithCompanion(BalanceSnapshotsCompanion data) {
    return BalanceSnapshotRow(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      businessDate: data.businessDate.present
          ? data.businessDate.value
          : this.businessDate,
      balancePaisa: data.balancePaisa.present
          ? data.balancePaisa.value
          : this.balancePaisa,
      maxTxnRowid: data.maxTxnRowid.present
          ? data.maxTxnRowid.value
          : this.maxTxnRowid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotRow(')
          ..write('accountId: $accountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('balancePaisa: $balancePaisa, ')
          ..write('maxTxnRowid: $maxTxnRowid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    businessDate,
    balancePaisa,
    maxTxnRowid,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceSnapshotRow &&
          other.accountId == this.accountId &&
          other.businessDate == this.businessDate &&
          other.balancePaisa == this.balancePaisa &&
          other.maxTxnRowid == this.maxTxnRowid &&
          other.createdAt == this.createdAt);
}

class BalanceSnapshotsCompanion extends UpdateCompanion<BalanceSnapshotRow> {
  final Value<String> accountId;
  final Value<String> businessDate;
  final Value<int> balancePaisa;
  final Value<int> maxTxnRowid;
  final Value<int> createdAt;
  final Value<int> rowid;
  const BalanceSnapshotsCompanion({
    this.accountId = const Value.absent(),
    this.businessDate = const Value.absent(),
    this.balancePaisa = const Value.absent(),
    this.maxTxnRowid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalanceSnapshotsCompanion.insert({
    required String accountId,
    required String businessDate,
    required int balancePaisa,
    required int maxTxnRowid,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       businessDate = Value(businessDate),
       balancePaisa = Value(balancePaisa),
       maxTxnRowid = Value(maxTxnRowid),
       createdAt = Value(createdAt);
  static Insertable<BalanceSnapshotRow> custom({
    Expression<String>? accountId,
    Expression<String>? businessDate,
    Expression<int>? balancePaisa,
    Expression<int>? maxTxnRowid,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (businessDate != null) 'business_date': businessDate,
      if (balancePaisa != null) 'balance_paisa': balancePaisa,
      if (maxTxnRowid != null) 'max_txn_rowid': maxTxnRowid,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalanceSnapshotsCompanion copyWith({
    Value<String>? accountId,
    Value<String>? businessDate,
    Value<int>? balancePaisa,
    Value<int>? maxTxnRowid,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return BalanceSnapshotsCompanion(
      accountId: accountId ?? this.accountId,
      businessDate: businessDate ?? this.businessDate,
      balancePaisa: balancePaisa ?? this.balancePaisa,
      maxTxnRowid: maxTxnRowid ?? this.maxTxnRowid,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (businessDate.present) {
      map['business_date'] = Variable<String>(businessDate.value);
    }
    if (balancePaisa.present) {
      map['balance_paisa'] = Variable<int>(balancePaisa.value);
    }
    if (maxTxnRowid.present) {
      map['max_txn_rowid'] = Variable<int>(maxTxnRowid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('businessDate: $businessDate, ')
          ..write('balancePaisa: $balancePaisa, ')
          ..write('maxTxnRowid: $maxTxnRowid, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TxnsTable txns = $TxnsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $CommissionRulesTable commissionRules = $CommissionRulesTable(
    this,
  );
  late final $CustomersTable customers = $CustomersTable(this);
  late final $DayClosesTable dayCloses = $DayClosesTable(this);
  late final $DayCloseLinesTable dayCloseLines = $DayCloseLinesTable(this);
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $BalanceSnapshotsTable balanceSnapshots = $BalanceSnapshotsTable(
    this,
  );
  late final Index idxTxnOccurred = Index(
    'idx_txn_occurred',
    'CREATE INDEX idx_txn_occurred ON txn (occurred_at)',
  );
  late final Index idxTxnTypeDay = Index(
    'idx_txn_type_day',
    'CREATE INDEX idx_txn_type_day ON txn (type, occurred_at)',
  );
  late final Index idxTxnStatus = Index(
    'idx_txn_status',
    'CREATE INDEX idx_txn_status ON txn (status)',
  );
  late final Index idxTxnCustomer = Index(
    'idx_txn_customer',
    'CREATE INDEX idx_txn_customer ON txn (customer_number)',
  );
  late final Index idxTxnReference = Index(
    'idx_txn_reference',
    'CREATE INDEX idx_txn_reference ON txn (reference)',
  );
  late final Index idxLeAccount = Index(
    'idx_le_account',
    'CREATE INDEX idx_le_account ON ledger_entry (account_id)',
  );
  late final Index idxLeTxn = Index(
    'idx_le_txn',
    'CREATE INDEX idx_le_txn ON ledger_entry (txn_id)',
  );
  late final Index idxAuditEntity = Index(
    'idx_audit_entity',
    'CREATE INDEX idx_audit_entity ON audit_log (entity, entity_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    txns,
    ledgerEntries,
    commissionRules,
    customers,
    dayCloses,
    dayCloseLines,
    expenseCategories,
    appUsers,
    auditLogs,
    settings,
    balanceSnapshots,
    idxTxnOccurred,
    idxTxnTypeDay,
    idxTxnStatus,
    idxTxnCustomer,
    idxTxnReference,
    idxLeAccount,
    idxLeTxn,
    idxAuditEntity,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String kind,
  Value<String?> provider,
  required String label,
  Value<String?> number,
  Value<int> openingPaisa,
  Value<int?> lowAlertPaisa,
  Value<bool> isActive,
  Value<int> sortOrder,
  required int createdAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String?> provider,
  Value<String> label,
  Value<String?> number,
  Value<int> openingPaisa,
  Value<int?> lowAlertPaisa,
  Value<bool> isActive,
  Value<int> sortOrder,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LedgerEntriesTable, List<LedgerEntryRow>>
  _ledgerEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerEntries,
    aliasName: 'account__id__ledger_entry__account_id',
  );

  $$LedgerEntriesTableProcessedTableManager get ledgerEntriesRefs {
    final manager = $$LedgerEntriesTableTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ledgerEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DayCloseLinesTable, List<DayCloseLineRow>>
  _dayCloseLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dayCloseLines,
    aliasName: 'account__id__day_close_line__account_id',
  );

  $$DayCloseLinesTableProcessedTableManager get dayCloseLinesRefs {
    final manager = $$DayCloseLinesTableTableManager(
      $_db,
      $_db.dayCloseLines,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dayCloseLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BalanceSnapshotsTable, List<BalanceSnapshotRow>>
  _balanceSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.balanceSnapshots,
    aliasName: 'account__id__balance_snapshot__account_id',
  );

  $$BalanceSnapshotsTableProcessedTableManager get balanceSnapshotsRefs {
    final manager = $$BalanceSnapshotsTableTableManager(
      $_db,
      $_db.balanceSnapshots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _balanceSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingPaisa => $composableBuilder(
    column: $table.openingPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowAlertPaisa => $composableBuilder(
    column: $table.lowAlertPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ledgerEntriesRefs(
    Expression<bool> Function($$LedgerEntriesTableFilterComposer f) f,
  ) {
    final $$LedgerEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dayCloseLinesRefs(
    Expression<bool> Function($$DayCloseLinesTableFilterComposer f) f,
  ) {
    final $$DayCloseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayCloseLines,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayCloseLinesTableFilterComposer(
            $db: $db,
            $table: $db.dayCloseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> balanceSnapshotsRefs(
    Expression<bool> Function($$BalanceSnapshotsTableFilterComposer f) f,
  ) {
    final $$BalanceSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingPaisa => $composableBuilder(
    column: $table.openingPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowAlertPaisa => $composableBuilder(
    column: $table.lowAlertPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get openingPaisa => $composableBuilder(
    column: $table.openingPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lowAlertPaisa => $composableBuilder(
    column: $table.lowAlertPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> ledgerEntriesRefs<T extends Object>(
    Expression<T> Function($$LedgerEntriesTableAnnotationComposer a) f,
  ) {
    final $$LedgerEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dayCloseLinesRefs<T extends Object>(
    Expression<T> Function($$DayCloseLinesTableAnnotationComposer a) f,
  ) {
    final $$DayCloseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayCloseLines,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayCloseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.dayCloseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> balanceSnapshotsRefs<T extends Object>(
    Expression<T> Function($$BalanceSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$BalanceSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({
            bool ledgerEntriesRefs,
            bool dayCloseLinesRefs,
            bool balanceSnapshotsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> number = const Value.absent(),
                Value<int> openingPaisa = const Value.absent(),
                Value<int?> lowAlertPaisa = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                kind: kind,
                provider: provider,
                label: label,
                number: number,
                openingPaisa: openingPaisa,
                lowAlertPaisa: lowAlertPaisa,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                Value<String?> provider = const Value.absent(),
                required String label,
                Value<String?> number = const Value.absent(),
                Value<int> openingPaisa = const Value.absent(),
                Value<int?> lowAlertPaisa = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                kind: kind,
                provider: provider,
                label: label,
                number: number,
                openingPaisa: openingPaisa,
                lowAlertPaisa: lowAlertPaisa,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, AccountRow>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ledgerEntriesRefs = false,
                dayCloseLinesRefs = false,
                balanceSnapshotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ledgerEntriesRefs) db.ledgerEntries,
                    if (dayCloseLinesRefs) db.dayCloseLines,
                    if (balanceSnapshotsRefs) db.balanceSnapshots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ledgerEntriesRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          LedgerEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._ledgerEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).ledgerEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dayCloseLinesRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          DayCloseLineRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._dayCloseLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).dayCloseLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (balanceSnapshotsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          BalanceSnapshotRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._balanceSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).balanceSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({
        bool ledgerEntriesRefs,
        bool dayCloseLinesRefs,
        bool balanceSnapshotsRefs,
      })
    >;
typedef $$TxnsTableCreateCompanionBuilder = TxnsCompanion Function({
  required String id,
  required String type,
  required int occurredAt,
  required int recordedAt,
  required int amountPaisa,
  Value<int> chargePaisa,
  Value<int> commissionPaisa,
  Value<String?> commissionRuleId,
  Value<bool> commissionOverridden,
  Value<String?> customerId,
  Value<String?> customerNumber,
  Value<String?> reference,
  Value<String?> note,
  Value<String> status,
  Value<String?> voidReason,
  Value<int?> voidedAt,
  Value<String?> replacesTxnId,
  Value<String?> dayCloseId,
  required String createdBy,
  Value<String?> shiftId,
  required String deviceId,
  Value<int> rowid,
});
typedef $$TxnsTableUpdateCompanionBuilder = TxnsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<int> occurredAt,
  Value<int> recordedAt,
  Value<int> amountPaisa,
  Value<int> chargePaisa,
  Value<int> commissionPaisa,
  Value<String?> commissionRuleId,
  Value<bool> commissionOverridden,
  Value<String?> customerId,
  Value<String?> customerNumber,
  Value<String?> reference,
  Value<String?> note,
  Value<String> status,
  Value<String?> voidReason,
  Value<int?> voidedAt,
  Value<String?> replacesTxnId,
  Value<String?> dayCloseId,
  Value<String> createdBy,
  Value<String?> shiftId,
  Value<String> deviceId,
  Value<int> rowid,
});

final class $$TxnsTableReferences
    extends BaseReferences<_$AppDatabase, $TxnsTable, TxnRow> {
  $$TxnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LedgerEntriesTable, List<LedgerEntryRow>>
  _ledgerEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerEntries,
    aliasName: 'txn__id__ledger_entry__txn_id',
  );

  $$LedgerEntriesTableProcessedTableManager get ledgerEntriesRefs {
    final manager = $$LedgerEntriesTableTableManager(
      $_db,
      $_db.ledgerEntries,
    ).filter((f) => f.txnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ledgerEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TxnsTableFilterComposer extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chargePaisa => $composableBuilder(
    column: $table.chargePaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commissionPaisa => $composableBuilder(
    column: $table.commissionPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commissionRuleId => $composableBuilder(
    column: $table.commissionRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get commissionOverridden => $composableBuilder(
    column: $table.commissionOverridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerNumber => $composableBuilder(
    column: $table.customerNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replacesTxnId => $composableBuilder(
    column: $table.replacesTxnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayCloseId => $composableBuilder(
    column: $table.dayCloseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ledgerEntriesRefs(
    Expression<bool> Function($$LedgerEntriesTableFilterComposer f) f,
  ) {
    final $$LedgerEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.txnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableFilterComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TxnsTableOrderingComposer extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargePaisa => $composableBuilder(
    column: $table.chargePaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commissionPaisa => $composableBuilder(
    column: $table.commissionPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commissionRuleId => $composableBuilder(
    column: $table.commissionRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get commissionOverridden => $composableBuilder(
    column: $table.commissionOverridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerNumber => $composableBuilder(
    column: $table.customerNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replacesTxnId => $composableBuilder(
    column: $table.replacesTxnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayCloseId => $composableBuilder(
    column: $table.dayCloseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftId => $composableBuilder(
    column: $table.shiftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TxnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TxnsTable> {
  $$TxnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountPaisa => $composableBuilder(
    column: $table.amountPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chargePaisa => $composableBuilder(
    column: $table.chargePaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get commissionPaisa => $composableBuilder(
    column: $table.commissionPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commissionRuleId => $composableBuilder(
    column: $table.commissionRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get commissionOverridden => $composableBuilder(
    column: $table.commissionOverridden,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerNumber => $composableBuilder(
    column: $table.customerNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get replacesTxnId => $composableBuilder(
    column: $table.replacesTxnId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayCloseId => $composableBuilder(
    column: $table.dayCloseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  Expression<T> ledgerEntriesRefs<T extends Object>(
    Expression<T> Function($$LedgerEntriesTableAnnotationComposer a) f,
  ) {
    final $$LedgerEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerEntries,
      getReferencedColumn: (t) => t.txnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TxnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TxnsTable,
          TxnRow,
          $$TxnsTableFilterComposer,
          $$TxnsTableOrderingComposer,
          $$TxnsTableAnnotationComposer,
          $$TxnsTableCreateCompanionBuilder,
          $$TxnsTableUpdateCompanionBuilder,
          (TxnRow, $$TxnsTableReferences),
          TxnRow,
          PrefetchHooks Function({bool ledgerEntriesRefs})
        > {
  $$TxnsTableTableManager(_$AppDatabase db, $TxnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TxnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TxnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TxnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
                Value<int> amountPaisa = const Value.absent(),
                Value<int> chargePaisa = const Value.absent(),
                Value<int> commissionPaisa = const Value.absent(),
                Value<String?> commissionRuleId = const Value.absent(),
                Value<bool> commissionOverridden = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> customerNumber = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> replacesTxnId = const Value.absent(),
                Value<String?> dayCloseId = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String?> shiftId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TxnsCompanion(
                id: id,
                type: type,
                occurredAt: occurredAt,
                recordedAt: recordedAt,
                amountPaisa: amountPaisa,
                chargePaisa: chargePaisa,
                commissionPaisa: commissionPaisa,
                commissionRuleId: commissionRuleId,
                commissionOverridden: commissionOverridden,
                customerId: customerId,
                customerNumber: customerNumber,
                reference: reference,
                note: note,
                status: status,
                voidReason: voidReason,
                voidedAt: voidedAt,
                replacesTxnId: replacesTxnId,
                dayCloseId: dayCloseId,
                createdBy: createdBy,
                shiftId: shiftId,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required int occurredAt,
                required int recordedAt,
                required int amountPaisa,
                Value<int> chargePaisa = const Value.absent(),
                Value<int> commissionPaisa = const Value.absent(),
                Value<String?> commissionRuleId = const Value.absent(),
                Value<bool> commissionOverridden = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> customerNumber = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int?> voidedAt = const Value.absent(),
                Value<String?> replacesTxnId = const Value.absent(),
                Value<String?> dayCloseId = const Value.absent(),
                required String createdBy,
                Value<String?> shiftId = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => TxnsCompanion.insert(
                id: id,
                type: type,
                occurredAt: occurredAt,
                recordedAt: recordedAt,
                amountPaisa: amountPaisa,
                chargePaisa: chargePaisa,
                commissionPaisa: commissionPaisa,
                commissionRuleId: commissionRuleId,
                commissionOverridden: commissionOverridden,
                customerId: customerId,
                customerNumber: customerNumber,
                reference: reference,
                note: note,
                status: status,
                voidReason: voidReason,
                voidedAt: voidedAt,
                replacesTxnId: replacesTxnId,
                dayCloseId: dayCloseId,
                createdBy: createdBy,
                shiftId: shiftId,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TxnsTable, TxnRow>(table),
                  $$TxnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ledgerEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ledgerEntriesRefs) db.ledgerEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ledgerEntriesRefs)
                    await $_getPrefetchedData<
                      TxnRow,
                      $TxnsTable,
                      LedgerEntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$TxnsTableReferences
                          ._ledgerEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$TxnsTableReferences(
                        db,
                        table,
                        p0,
                      ).ledgerEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.txnId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TxnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TxnsTable,
      TxnRow,
      $$TxnsTableFilterComposer,
      $$TxnsTableOrderingComposer,
      $$TxnsTableAnnotationComposer,
      $$TxnsTableCreateCompanionBuilder,
      $$TxnsTableUpdateCompanionBuilder,
      (TxnRow, $$TxnsTableReferences),
      TxnRow,
      PrefetchHooks Function({bool ledgerEntriesRefs})
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      required String id,
      required String txnId,
      required String accountId,
      required int deltaPaisa,
      required int lineNo,
      Value<int> rowid,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> txnId,
      Value<String> accountId,
      Value<int> deltaPaisa,
      Value<int> lineNo,
      Value<int> rowid,
    });

final class $$LedgerEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntryRow> {
  $$LedgerEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TxnsTable _txnIdTable(_$AppDatabase db) =>
      db.txns.createAlias('ledger_entry__txn_id__txn__id');

  $$TxnsTableProcessedTableManager get txnId {
    final $_column = $_itemColumn<String>('txn_id')!;

    final manager = $$TxnsTableTableManager(
      $_db,
      $_db.txns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_txnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('ledger_entry__account_id__account__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deltaPaisa => $composableBuilder(
    column: $table.deltaPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnFilters(column),
  );

  $$TxnsTableFilterComposer get txnId {
    final $$TxnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.txnId,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableFilterComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deltaPaisa => $composableBuilder(
    column: $table.deltaPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnOrderings(column),
  );

  $$TxnsTableOrderingComposer get txnId {
    final $$TxnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.txnId,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableOrderingComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get deltaPaisa => $composableBuilder(
    column: $table.deltaPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  $$TxnsTableAnnotationComposer get txnId {
    final $$TxnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.txnId,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableAnnotationComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerEntriesTable,
          LedgerEntryRow,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (LedgerEntryRow, $$LedgerEntriesTableReferences),
          LedgerEntryRow,
          PrefetchHooks Function({bool txnId, bool accountId})
        > {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> txnId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> deltaPaisa = const Value.absent(),
                Value<int> lineNo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                id: id,
                txnId: txnId,
                accountId: accountId,
                deltaPaisa: deltaPaisa,
                lineNo: lineNo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String txnId,
                required String accountId,
                required int deltaPaisa,
                required int lineNo,
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                id: id,
                txnId: txnId,
                accountId: accountId,
                deltaPaisa: deltaPaisa,
                lineNo: lineNo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LedgerEntriesTable, LedgerEntryRow>(table),
                  $$LedgerEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({txnId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (txnId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.txnId,
                        referencedTable: $$LedgerEntriesTableReferences
                            ._txnIdTable(db),
                        referencedColumn: $$LedgerEntriesTableReferences
                            ._txnIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$LedgerEntriesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$LedgerEntriesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerEntriesTable,
      LedgerEntryRow,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (LedgerEntryRow, $$LedgerEntriesTableReferences),
      LedgerEntryRow,
      PrefetchHooks Function({bool txnId, bool accountId})
    >;
typedef $$CommissionRulesTableCreateCompanionBuilder =
    CommissionRulesCompanion Function({
      required String id,
      required String provider,
      required String txnType,
      required String mode,
      required int value,
      Value<String?> tiersJson,
      required int effectiveFrom,
      Value<int?> effectiveTo,
      Value<int> rowid,
    });
typedef $$CommissionRulesTableUpdateCompanionBuilder =
    CommissionRulesCompanion Function({
      Value<String> id,
      Value<String> provider,
      Value<String> txnType,
      Value<String> mode,
      Value<int> value,
      Value<String?> tiersJson,
      Value<int> effectiveFrom,
      Value<int?> effectiveTo,
      Value<int> rowid,
    });

class $$CommissionRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CommissionRulesTable> {
  $$CommissionRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txnType => $composableBuilder(
    column: $table.txnType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tiersJson => $composableBuilder(
    column: $table.tiersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommissionRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CommissionRulesTable> {
  $$CommissionRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txnType => $composableBuilder(
    column: $table.txnType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tiersJson => $composableBuilder(
    column: $table.tiersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommissionRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommissionRulesTable> {
  $$CommissionRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get txnType =>
      $composableBuilder(column: $table.txnType, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get tiersJson =>
      $composableBuilder(column: $table.tiersJson, builder: (column) => column);

  GeneratedColumn<int> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effectiveTo => $composableBuilder(
    column: $table.effectiveTo,
    builder: (column) => column,
  );
}

class $$CommissionRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommissionRulesTable,
          CommissionRuleRow,
          $$CommissionRulesTableFilterComposer,
          $$CommissionRulesTableOrderingComposer,
          $$CommissionRulesTableAnnotationComposer,
          $$CommissionRulesTableCreateCompanionBuilder,
          $$CommissionRulesTableUpdateCompanionBuilder,
          (
            CommissionRuleRow,
            BaseReferences<
              _$AppDatabase,
              $CommissionRulesTable,
              CommissionRuleRow
            >,
          ),
          CommissionRuleRow,
          PrefetchHooks Function()
        > {
  $$CommissionRulesTableTableManager(
    _$AppDatabase db,
    $CommissionRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommissionRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommissionRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommissionRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> txnType = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<String?> tiersJson = const Value.absent(),
                Value<int> effectiveFrom = const Value.absent(),
                Value<int?> effectiveTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommissionRulesCompanion(
                id: id,
                provider: provider,
                txnType: txnType,
                mode: mode,
                value: value,
                tiersJson: tiersJson,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String provider,
                required String txnType,
                required String mode,
                required int value,
                Value<String?> tiersJson = const Value.absent(),
                required int effectiveFrom,
                Value<int?> effectiveTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommissionRulesCompanion.insert(
                id: id,
                provider: provider,
                txnType: txnType,
                mode: mode,
                value: value,
                tiersJson: tiersJson,
                effectiveFrom: effectiveFrom,
                effectiveTo: effectiveTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CommissionRulesTable, CommissionRuleRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CommissionRulesTable,
                    CommissionRuleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommissionRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommissionRulesTable,
      CommissionRuleRow,
      $$CommissionRulesTableFilterComposer,
      $$CommissionRulesTableOrderingComposer,
      $$CommissionRulesTableAnnotationComposer,
      $$CommissionRulesTableCreateCompanionBuilder,
      $$CommissionRulesTableUpdateCompanionBuilder,
      (
        CommissionRuleRow,
        BaseReferences<_$AppDatabase, $CommissionRulesTable, CommissionRuleRow>,
      ),
      CommissionRuleRow,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  Value<String?> name,
  Value<String?> phone,
  Value<String?> note,
  required int createdAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String?> name,
  Value<String?> phone,
  Value<String?> note,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (
            CustomerRow,
            BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
          ),
          CustomerRow,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, CustomerRow>(table),
                  BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (
        CustomerRow,
        BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
      ),
      CustomerRow,
      PrefetchHooks Function()
    >;
typedef $$DayClosesTableCreateCompanionBuilder = DayClosesCompanion Function({
  required String id,
  required String businessDate,
  required String status,
  Value<String?> note,
  Value<String?> closedBy,
  Value<int?> closedAt,
  Value<String?> reopenedBy,
  Value<int?> reopenedAt,
  Value<String?> reopenReason,
  Value<int> rowid,
});
typedef $$DayClosesTableUpdateCompanionBuilder = DayClosesCompanion Function({
  Value<String> id,
  Value<String> businessDate,
  Value<String> status,
  Value<String?> note,
  Value<String?> closedBy,
  Value<int?> closedAt,
  Value<String?> reopenedBy,
  Value<int?> reopenedAt,
  Value<String?> reopenReason,
  Value<int> rowid,
});

final class $$DayClosesTableReferences
    extends BaseReferences<_$AppDatabase, $DayClosesTable, DayCloseRow> {
  $$DayClosesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DayCloseLinesTable, List<DayCloseLineRow>>
  _dayCloseLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dayCloseLines,
    aliasName: 'day_close__id__day_close_line__day_close_id',
  );

  $$DayCloseLinesTableProcessedTableManager get dayCloseLinesRefs {
    final manager = $$DayCloseLinesTableTableManager(
      $_db,
      $_db.dayCloseLines,
    ).filter((f) => f.dayCloseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_dayCloseLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DayClosesTableFilterComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reopenedBy => $composableBuilder(
    column: $table.reopenedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reopenedAt => $composableBuilder(
    column: $table.reopenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dayCloseLinesRefs(
    Expression<bool> Function($$DayCloseLinesTableFilterComposer f) f,
  ) {
    final $$DayCloseLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayCloseLines,
      getReferencedColumn: (t) => t.dayCloseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayCloseLinesTableFilterComposer(
            $db: $db,
            $table: $db.dayCloseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DayClosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedBy => $composableBuilder(
    column: $table.closedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reopenedBy => $composableBuilder(
    column: $table.reopenedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reopenedAt => $composableBuilder(
    column: $table.reopenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayClosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayClosesTable> {
  $$DayClosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get closedBy =>
      $composableBuilder(column: $table.closedBy, builder: (column) => column);

  GeneratedColumn<int> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get reopenedBy => $composableBuilder(
    column: $table.reopenedBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reopenedAt => $composableBuilder(
    column: $table.reopenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => column,
  );

  Expression<T> dayCloseLinesRefs<T extends Object>(
    Expression<T> Function($$DayCloseLinesTableAnnotationComposer a) f,
  ) {
    final $$DayCloseLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dayCloseLines,
      getReferencedColumn: (t) => t.dayCloseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayCloseLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.dayCloseLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DayClosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayClosesTable,
          DayCloseRow,
          $$DayClosesTableFilterComposer,
          $$DayClosesTableOrderingComposer,
          $$DayClosesTableAnnotationComposer,
          $$DayClosesTableCreateCompanionBuilder,
          $$DayClosesTableUpdateCompanionBuilder,
          (DayCloseRow, $$DayClosesTableReferences),
          DayCloseRow,
          PrefetchHooks Function({bool dayCloseLinesRefs})
        > {
  $$DayClosesTableTableManager(_$AppDatabase db, $DayClosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayClosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayClosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayClosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<String?> reopenedBy = const Value.absent(),
                Value<int?> reopenedAt = const Value.absent(),
                Value<String?> reopenReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayClosesCompanion(
                id: id,
                businessDate: businessDate,
                status: status,
                note: note,
                closedBy: closedBy,
                closedAt: closedAt,
                reopenedBy: reopenedBy,
                reopenedAt: reopenedAt,
                reopenReason: reopenReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String businessDate,
                required String status,
                Value<String?> note = const Value.absent(),
                Value<String?> closedBy = const Value.absent(),
                Value<int?> closedAt = const Value.absent(),
                Value<String?> reopenedBy = const Value.absent(),
                Value<int?> reopenedAt = const Value.absent(),
                Value<String?> reopenReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayClosesCompanion.insert(
                id: id,
                businessDate: businessDate,
                status: status,
                note: note,
                closedBy: closedBy,
                closedAt: closedAt,
                reopenedBy: reopenedBy,
                reopenedAt: reopenedAt,
                reopenReason: reopenReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayClosesTable, DayCloseRow>(table),
                  $$DayClosesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayCloseLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dayCloseLinesRefs) db.dayCloseLines,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dayCloseLinesRefs)
                    await $_getPrefetchedData<
                      DayCloseRow,
                      $DayClosesTable,
                      DayCloseLineRow
                    >(
                      currentTable: table,
                      referencedTable: $$DayClosesTableReferences
                          ._dayCloseLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DayClosesTableReferences(
                            db,
                            table,
                            p0,
                          ).dayCloseLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dayCloseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DayClosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayClosesTable,
      DayCloseRow,
      $$DayClosesTableFilterComposer,
      $$DayClosesTableOrderingComposer,
      $$DayClosesTableAnnotationComposer,
      $$DayClosesTableCreateCompanionBuilder,
      $$DayClosesTableUpdateCompanionBuilder,
      (DayCloseRow, $$DayClosesTableReferences),
      DayCloseRow,
      PrefetchHooks Function({bool dayCloseLinesRefs})
    >;
typedef $$DayCloseLinesTableCreateCompanionBuilder =
    DayCloseLinesCompanion Function({
      required String dayCloseId,
      required String accountId,
      required int expectedPaisa,
      required int actualPaisa,
      required int variancePaisa,
      Value<String?> adjustmentTxnId,
      Value<int> rowid,
    });
typedef $$DayCloseLinesTableUpdateCompanionBuilder =
    DayCloseLinesCompanion Function({
      Value<String> dayCloseId,
      Value<String> accountId,
      Value<int> expectedPaisa,
      Value<int> actualPaisa,
      Value<int> variancePaisa,
      Value<String?> adjustmentTxnId,
      Value<int> rowid,
    });

final class $$DayCloseLinesTableReferences
    extends
        BaseReferences<_$AppDatabase, $DayCloseLinesTable, DayCloseLineRow> {
  $$DayCloseLinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DayClosesTable _dayCloseIdTable(_$AppDatabase db) =>
      db.dayCloses.createAlias('day_close_line__day_close_id__day_close__id');

  $$DayClosesTableProcessedTableManager get dayCloseId {
    final $_column = $_itemColumn<String>('day_close_id')!;

    final manager = $$DayClosesTableTableManager(
      $_db,
      $_db.dayCloses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayCloseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('day_close_line__account_id__account__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DayCloseLinesTableFilterComposer
    extends Composer<_$AppDatabase, $DayCloseLinesTable> {
  $$DayCloseLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get expectedPaisa => $composableBuilder(
    column: $table.expectedPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualPaisa => $composableBuilder(
    column: $table.actualPaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get variancePaisa => $composableBuilder(
    column: $table.variancePaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjustmentTxnId => $composableBuilder(
    column: $table.adjustmentTxnId,
    builder: (column) => ColumnFilters(column),
  );

  $$DayClosesTableFilterComposer get dayCloseId {
    final $$DayClosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayCloseId,
      referencedTable: $db.dayCloses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayClosesTableFilterComposer(
            $db: $db,
            $table: $db.dayCloses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayCloseLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayCloseLinesTable> {
  $$DayCloseLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get expectedPaisa => $composableBuilder(
    column: $table.expectedPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualPaisa => $composableBuilder(
    column: $table.actualPaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get variancePaisa => $composableBuilder(
    column: $table.variancePaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustmentTxnId => $composableBuilder(
    column: $table.adjustmentTxnId,
    builder: (column) => ColumnOrderings(column),
  );

  $$DayClosesTableOrderingComposer get dayCloseId {
    final $$DayClosesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayCloseId,
      referencedTable: $db.dayCloses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayClosesTableOrderingComposer(
            $db: $db,
            $table: $db.dayCloses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayCloseLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayCloseLinesTable> {
  $$DayCloseLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get expectedPaisa => $composableBuilder(
    column: $table.expectedPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualPaisa => $composableBuilder(
    column: $table.actualPaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get variancePaisa => $composableBuilder(
    column: $table.variancePaisa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adjustmentTxnId => $composableBuilder(
    column: $table.adjustmentTxnId,
    builder: (column) => column,
  );

  $$DayClosesTableAnnotationComposer get dayCloseId {
    final $$DayClosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayCloseId,
      referencedTable: $db.dayCloses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DayClosesTableAnnotationComposer(
            $db: $db,
            $table: $db.dayCloses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DayCloseLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayCloseLinesTable,
          DayCloseLineRow,
          $$DayCloseLinesTableFilterComposer,
          $$DayCloseLinesTableOrderingComposer,
          $$DayCloseLinesTableAnnotationComposer,
          $$DayCloseLinesTableCreateCompanionBuilder,
          $$DayCloseLinesTableUpdateCompanionBuilder,
          (DayCloseLineRow, $$DayCloseLinesTableReferences),
          DayCloseLineRow,
          PrefetchHooks Function({bool dayCloseId, bool accountId})
        > {
  $$DayCloseLinesTableTableManager(_$AppDatabase db, $DayCloseLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayCloseLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayCloseLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayCloseLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dayCloseId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> expectedPaisa = const Value.absent(),
                Value<int> actualPaisa = const Value.absent(),
                Value<int> variancePaisa = const Value.absent(),
                Value<String?> adjustmentTxnId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayCloseLinesCompanion(
                dayCloseId: dayCloseId,
                accountId: accountId,
                expectedPaisa: expectedPaisa,
                actualPaisa: actualPaisa,
                variancePaisa: variancePaisa,
                adjustmentTxnId: adjustmentTxnId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dayCloseId,
                required String accountId,
                required int expectedPaisa,
                required int actualPaisa,
                required int variancePaisa,
                Value<String?> adjustmentTxnId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayCloseLinesCompanion.insert(
                dayCloseId: dayCloseId,
                accountId: accountId,
                expectedPaisa: expectedPaisa,
                actualPaisa: actualPaisa,
                variancePaisa: variancePaisa,
                adjustmentTxnId: adjustmentTxnId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayCloseLinesTable, DayCloseLineRow>(table),
                  $$DayCloseLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayCloseId = false, accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayCloseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.dayCloseId,
                        referencedTable: $$DayCloseLinesTableReferences
                            ._dayCloseIdTable(db),
                        referencedColumn: $$DayCloseLinesTableReferences
                            ._dayCloseIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$DayCloseLinesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$DayCloseLinesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DayCloseLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayCloseLinesTable,
      DayCloseLineRow,
      $$DayCloseLinesTableFilterComposer,
      $$DayCloseLinesTableOrderingComposer,
      $$DayCloseLinesTableAnnotationComposer,
      $$DayCloseLinesTableCreateCompanionBuilder,
      $$DayCloseLinesTableUpdateCompanionBuilder,
      (DayCloseLineRow, $$DayCloseLinesTableReferences),
      DayCloseLineRow,
      PrefetchHooks Function({bool dayCloseId, bool accountId})
    >;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      required String id,
      required String name,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$ExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategoryRow,
          $$ExpenseCategoriesTableFilterComposer,
          $$ExpenseCategoriesTableOrderingComposer,
          $$ExpenseCategoriesTableAnnotationComposer,
          $$ExpenseCategoriesTableCreateCompanionBuilder,
          $$ExpenseCategoriesTableUpdateCompanionBuilder,
          (
            ExpenseCategoryRow,
            BaseReferences<
              _$AppDatabase,
              $ExpenseCategoriesTable,
              ExpenseCategoryRow
            >,
          ),
          ExpenseCategoryRow,
          PrefetchHooks Function()
        > {
  $$ExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                name: name,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                name: name,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpenseCategoriesTable, ExpenseCategoryRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ExpenseCategoriesTable,
                    ExpenseCategoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoriesTable,
      ExpenseCategoryRow,
      $$ExpenseCategoriesTableFilterComposer,
      $$ExpenseCategoriesTableOrderingComposer,
      $$ExpenseCategoriesTableAnnotationComposer,
      $$ExpenseCategoriesTableCreateCompanionBuilder,
      $$ExpenseCategoriesTableUpdateCompanionBuilder,
      (
        ExpenseCategoryRow,
        BaseReferences<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategoryRow
        >,
      ),
      ExpenseCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$AppUsersTableCreateCompanionBuilder = AppUsersCompanion Function({
  required String id,
  required String name,
  required String role,
  Value<String?> pinHash,
  Value<bool> canSeeProfit,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$AppUsersTableUpdateCompanionBuilder = AppUsersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> role,
  Value<String?> pinHash,
  Value<bool> canSeeProfit,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canSeeProfit => $composableBuilder(
    column: $table.canSeeProfit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canSeeProfit => $composableBuilder(
    column: $table.canSeeProfit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<bool> get canSeeProfit => $composableBuilder(
    column: $table.canSeeProfit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUserRow,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (
            AppUserRow,
            BaseReferences<_$AppDatabase, $AppUsersTable, AppUserRow>,
          ),
          AppUserRow,
          PrefetchHooks Function()
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<bool> canSeeProfit = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion(
                id: id,
                name: name,
                role: role,
                pinHash: pinHash,
                canSeeProfit: canSeeProfit,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String role,
                Value<String?> pinHash = const Value.absent(),
                Value<bool> canSeeProfit = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsersCompanion.insert(
                id: id,
                name: name,
                role: role,
                pinHash: pinHash,
                canSeeProfit: canSeeProfit,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppUsersTable, AppUserRow>(table),
                  BaseReferences<_$AppDatabase, $AppUsersTable, AppUserRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUserRow,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUserRow, BaseReferences<_$AppDatabase, $AppUsersTable, AppUserRow>),
      AppUserRow,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  required int at,
  required String userId,
  required String action,
  required String entity,
  Value<String?> entityId,
  Value<String?> beforeJson,
  Value<String?> afterJson,
  Value<String?> reason,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<int> at,
  Value<String> userId,
  Value<String> action,
  Value<String> entity,
  Value<String?> entityId,
  Value<String?> beforeJson,
  Value<String?> afterJson,
  Value<String?> reason,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterJson =>
      $composableBuilder(column: $table.afterJson, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLogRow,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (
            AuditLogRow,
            BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLogRow>,
          ),
          AuditLogRow,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> at = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String?> beforeJson = const Value.absent(),
                Value<String?> afterJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                at: at,
                userId: userId,
                action: action,
                entity: entity,
                entityId: entityId,
                beforeJson: beforeJson,
                afterJson: afterJson,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int at,
                required String userId,
                required String action,
                required String entity,
                Value<String?> entityId = const Value.absent(),
                Value<String?> beforeJson = const Value.absent(),
                Value<String?> afterJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                at: at,
                userId: userId,
                action: action,
                entity: entity,
                entityId: entityId,
                beforeJson: beforeJson,
                afterJson: afterJson,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLogRow>(table),
                  BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLogRow,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (
        AuditLogRow,
        BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLogRow>,
      ),
      AuditLogRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$BalanceSnapshotsTableCreateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      required String accountId,
      required String businessDate,
      required int balancePaisa,
      required int maxTxnRowid,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$BalanceSnapshotsTableUpdateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      Value<String> accountId,
      Value<String> businessDate,
      Value<int> balancePaisa,
      Value<int> maxTxnRowid,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$BalanceSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshotRow
        > {
  $$BalanceSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('balance_snapshot__account_id__account__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BalanceSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balancePaisa => $composableBuilder(
    column: $table.balancePaisa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxTxnRowid => $composableBuilder(
    column: $table.maxTxnRowid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balancePaisa => $composableBuilder(
    column: $table.balancePaisa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxTxnRowid => $composableBuilder(
    column: $table.maxTxnRowid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get businessDate => $composableBuilder(
    column: $table.businessDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balancePaisa => $composableBuilder(
    column: $table.balancePaisa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxTxnRowid => $composableBuilder(
    column: $table.maxTxnRowid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshotRow,
          $$BalanceSnapshotsTableFilterComposer,
          $$BalanceSnapshotsTableOrderingComposer,
          $$BalanceSnapshotsTableAnnotationComposer,
          $$BalanceSnapshotsTableCreateCompanionBuilder,
          $$BalanceSnapshotsTableUpdateCompanionBuilder,
          (BalanceSnapshotRow, $$BalanceSnapshotsTableReferences),
          BalanceSnapshotRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$BalanceSnapshotsTableTableManager(
    _$AppDatabase db,
    $BalanceSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> businessDate = const Value.absent(),
                Value<int> balancePaisa = const Value.absent(),
                Value<int> maxTxnRowid = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion(
                accountId: accountId,
                businessDate: businessDate,
                balancePaisa: balancePaisa,
                maxTxnRowid: maxTxnRowid,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String businessDate,
                required int balancePaisa,
                required int maxTxnRowid,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion.insert(
                accountId: accountId,
                businessDate: businessDate,
                balancePaisa: balancePaisa,
                maxTxnRowid: maxTxnRowid,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BalanceSnapshotsTable, BalanceSnapshotRow>(
                    table,
                  ),
                  $$BalanceSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$BalanceSnapshotsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$BalanceSnapshotsTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BalanceSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceSnapshotsTable,
      BalanceSnapshotRow,
      $$BalanceSnapshotsTableFilterComposer,
      $$BalanceSnapshotsTableOrderingComposer,
      $$BalanceSnapshotsTableAnnotationComposer,
      $$BalanceSnapshotsTableCreateCompanionBuilder,
      $$BalanceSnapshotsTableUpdateCompanionBuilder,
      (BalanceSnapshotRow, $$BalanceSnapshotsTableReferences),
      BalanceSnapshotRow,
      PrefetchHooks Function({bool accountId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TxnsTableTableManager get txns => $$TxnsTableTableManager(_db, _db.txns);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$CommissionRulesTableTableManager get commissionRules =>
      $$CommissionRulesTableTableManager(_db, _db.commissionRules);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$DayClosesTableTableManager get dayCloses =>
      $$DayClosesTableTableManager(_db, _db.dayCloses);
  $$DayCloseLinesTableTableManager get dayCloseLines =>
      $$DayCloseLinesTableTableManager(_db, _db.dayCloseLines);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$BalanceSnapshotsTableTableManager get balanceSnapshots =>
      $$BalanceSnapshotsTableTableManager(_db, _db.balanceSnapshots);
}
