// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
    type: DriftSqlType.string,
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
  List<GeneratedColumn> get $columns => [id, email, displayName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
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
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String displayName;
  final int createdAt;
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    int? createdAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> displayName;
  final Value<int> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String displayName,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? displayName,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
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
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
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
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Taipei'),
  );
  static const VerificationMeta _recurrenceRuleIdMeta = const VerificationMeta(
    'recurrenceRuleId',
  );
  @override
  late final GeneratedColumn<String> recurrenceRuleId = GeneratedColumn<String>(
    'recurrence_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alertLevelMeta = const VerificationMeta(
    'alertLevel',
  );
  @override
  late final GeneratedColumn<String> alertLevel = GeneratedColumn<String>(
    'alert_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NOTIFICATION'),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    title,
    note,
    startAt,
    timezone,
    recurrenceRuleId,
    alertLevel,
    isEnabled,
    isCompleted,
    completedAt,
    createdAt,
    updatedAt,
    isDeleted,
    version,
    syncStatus,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('recurrence_rule_id')) {
      context.handle(
        _recurrenceRuleIdMeta,
        recurrenceRuleId.isAcceptableOrUnknown(
          data['recurrence_rule_id']!,
          _recurrenceRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('alert_level')) {
      context.handle(
        _alertLevelMeta,
        alertLevel.isAcceptableOrUnknown(data['alert_level']!, _alertLevelMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_at'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      recurrenceRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule_id'],
      ),
      alertLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_level'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String? userId;
  final String type;
  final String title;
  final String? note;
  final int startAt;
  final String timezone;
  final String? recurrenceRuleId;
  final String alertLevel;
  final bool isEnabled;
  final bool isCompleted;
  final int? completedAt;
  final int createdAt;
  final int updatedAt;
  final bool isDeleted;
  final int version;
  final String syncStatus;
  final String? color;
  const Reminder({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    this.note,
    required this.startAt,
    required this.timezone,
    this.recurrenceRuleId,
    required this.alertLevel,
    required this.isEnabled,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.version,
    required this.syncStatus,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['start_at'] = Variable<int>(startAt);
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || recurrenceRuleId != null) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId);
    }
    map['alert_level'] = Variable<String>(alertLevel);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      type: Value(type),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      startAt: Value(startAt),
      timezone: Value(timezone),
      recurrenceRuleId: recurrenceRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRuleId),
      alertLevel: Value(alertLevel),
      isEnabled: Value(isEnabled),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      version: Value(version),
      syncStatus: Value(syncStatus),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      startAt: serializer.fromJson<int>(json['startAt']),
      timezone: serializer.fromJson<String>(json['timezone']),
      recurrenceRuleId: serializer.fromJson<String?>(json['recurrenceRuleId']),
      alertLevel: serializer.fromJson<String>(json['alertLevel']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'startAt': serializer.toJson<int>(startAt),
      'timezone': serializer.toJson<String>(timezone),
      'recurrenceRuleId': serializer.toJson<String?>(recurrenceRuleId),
      'alertLevel': serializer.toJson<String>(alertLevel),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'color': serializer.toJson<String?>(color),
    };
  }

  Reminder copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? type,
    String? title,
    Value<String?> note = const Value.absent(),
    int? startAt,
    String? timezone,
    Value<String?> recurrenceRuleId = const Value.absent(),
    String? alertLevel,
    bool? isEnabled,
    bool? isCompleted,
    Value<int?> completedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    int? version,
    String? syncStatus,
    Value<String?> color = const Value.absent(),
  }) => Reminder(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    type: type ?? this.type,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    startAt: startAt ?? this.startAt,
    timezone: timezone ?? this.timezone,
    recurrenceRuleId: recurrenceRuleId.present
        ? recurrenceRuleId.value
        : this.recurrenceRuleId,
    alertLevel: alertLevel ?? this.alertLevel,
    isEnabled: isEnabled ?? this.isEnabled,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    color: color.present ? color.value : this.color,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      recurrenceRuleId: data.recurrenceRuleId.present
          ? data.recurrenceRuleId.value
          : this.recurrenceRuleId,
      alertLevel: data.alertLevel.present
          ? data.alertLevel.value
          : this.alertLevel,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('startAt: $startAt, ')
          ..write('timezone: $timezone, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    type,
    title,
    note,
    startAt,
    timezone,
    recurrenceRuleId,
    alertLevel,
    isEnabled,
    isCompleted,
    completedAt,
    createdAt,
    updatedAt,
    isDeleted,
    version,
    syncStatus,
    color,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.title == this.title &&
          other.note == this.note &&
          other.startAt == this.startAt &&
          other.timezone == this.timezone &&
          other.recurrenceRuleId == this.recurrenceRuleId &&
          other.alertLevel == this.alertLevel &&
          other.isEnabled == this.isEnabled &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.color == this.color);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> note;
  final Value<int> startAt;
  final Value<String> timezone;
  final Value<String?> recurrenceRuleId;
  final Value<String> alertLevel;
  final Value<bool> isEnabled;
  final Value<bool> isCompleted;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> isDeleted;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<String?> color;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.startAt = const Value.absent(),
    this.timezone = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.alertLevel = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String type,
    required String title,
    this.note = const Value.absent(),
    required int startAt,
    this.timezone = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.alertLevel = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.isDeleted = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       startAt = Value(startAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? note,
    Expression<int>? startAt,
    Expression<String>? timezone,
    Expression<String>? recurrenceRuleId,
    Expression<String>? alertLevel,
    Expression<bool>? isEnabled,
    Expression<bool>? isCompleted,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (startAt != null) 'start_at': startAt,
      if (timezone != null) 'timezone': timezone,
      if (recurrenceRuleId != null) 'recurrence_rule_id': recurrenceRuleId,
      if (alertLevel != null) 'alert_level': alertLevel,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? note,
    Value<int>? startAt,
    Value<String>? timezone,
    Value<String?>? recurrenceRuleId,
    Value<String>? alertLevel,
    Value<bool>? isEnabled,
    Value<bool>? isCompleted,
    Value<int?>? completedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<bool>? isDeleted,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<String?>? color,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      note: note ?? this.note,
      startAt: startAt ?? this.startAt,
      timezone: timezone ?? this.timezone,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      alertLevel: alertLevel ?? this.alertLevel,
      isEnabled: isEnabled ?? this.isEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (recurrenceRuleId.present) {
      map['recurrence_rule_id'] = Variable<String>(recurrenceRuleId.value);
    }
    if (alertLevel.present) {
      map['alert_level'] = Variable<String>(alertLevel.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('startAt: $startAt, ')
          ..write('timezone: $timezone, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurrenceRulesTable extends RecurrenceRules
    with TableInfo<$RecurrenceRulesTable, RecurrenceRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurrenceRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rruleStringMeta = const VerificationMeta(
    'rruleString',
  );
  @override
  late final GeneratedColumn<String> rruleString = GeneratedColumn<String>(
    'rrule_string',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _freqMeta = const VerificationMeta('freq');
  @override
  late final GeneratedColumn<String> freq = GeneratedColumn<String>(
    'freq',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NONE'),
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _byWeekdayMeta = const VerificationMeta(
    'byWeekday',
  );
  @override
  late final GeneratedColumn<String> byWeekday = GeneratedColumn<String>(
    'by_weekday',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byMonthdayMeta = const VerificationMeta(
    'byMonthday',
  );
  @override
  late final GeneratedColumn<String> byMonthday = GeneratedColumn<String>(
    'by_monthday',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byMonthMeta = const VerificationMeta(
    'byMonth',
  );
  @override
  late final GeneratedColumn<String> byMonth = GeneratedColumn<String>(
    'by_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesOfDayMeta = const VerificationMeta(
    'timesOfDay',
  );
  @override
  late final GeneratedColumn<String> timesOfDay = GeneratedColumn<String>(
    'times_of_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _untilMeta = const VerificationMeta('until');
  @override
  late final GeneratedColumn<int> until = GeneratedColumn<int>(
    'until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rruleString,
    freq,
    interval,
    byWeekday,
    byMonthday,
    byMonth,
    timesOfDay,
    count,
    until,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurrence_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurrenceRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rrule_string')) {
      context.handle(
        _rruleStringMeta,
        rruleString.isAcceptableOrUnknown(
          data['rrule_string']!,
          _rruleStringMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rruleStringMeta);
    }
    if (data.containsKey('freq')) {
      context.handle(
        _freqMeta,
        freq.isAcceptableOrUnknown(data['freq']!, _freqMeta),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('by_weekday')) {
      context.handle(
        _byWeekdayMeta,
        byWeekday.isAcceptableOrUnknown(data['by_weekday']!, _byWeekdayMeta),
      );
    }
    if (data.containsKey('by_monthday')) {
      context.handle(
        _byMonthdayMeta,
        byMonthday.isAcceptableOrUnknown(data['by_monthday']!, _byMonthdayMeta),
      );
    }
    if (data.containsKey('by_month')) {
      context.handle(
        _byMonthMeta,
        byMonth.isAcceptableOrUnknown(data['by_month']!, _byMonthMeta),
      );
    }
    if (data.containsKey('times_of_day')) {
      context.handle(
        _timesOfDayMeta,
        timesOfDay.isAcceptableOrUnknown(
          data['times_of_day']!,
          _timesOfDayMeta,
        ),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('until')) {
      context.handle(
        _untilMeta,
        until.isAcceptableOrUnknown(data['until']!, _untilMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurrenceRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurrenceRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rruleString: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rrule_string'],
      )!,
      freq: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freq'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      byWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}by_weekday'],
      ),
      byMonthday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}by_monthday'],
      ),
      byMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}by_month'],
      ),
      timesOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times_of_day'],
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      ),
      until: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}until'],
      ),
    );
  }

  @override
  $RecurrenceRulesTable createAlias(String alias) {
    return $RecurrenceRulesTable(attachedDatabase, alias);
  }
}

class RecurrenceRule extends DataClass implements Insertable<RecurrenceRule> {
  final String id;
  final String rruleString;
  final String freq;
  final int interval;
  final String? byWeekday;
  final String? byMonthday;
  final String? byMonth;
  final String? timesOfDay;
  final int? count;
  final int? until;
  const RecurrenceRule({
    required this.id,
    required this.rruleString,
    required this.freq,
    required this.interval,
    this.byWeekday,
    this.byMonthday,
    this.byMonth,
    this.timesOfDay,
    this.count,
    this.until,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rrule_string'] = Variable<String>(rruleString);
    map['freq'] = Variable<String>(freq);
    map['interval'] = Variable<int>(interval);
    if (!nullToAbsent || byWeekday != null) {
      map['by_weekday'] = Variable<String>(byWeekday);
    }
    if (!nullToAbsent || byMonthday != null) {
      map['by_monthday'] = Variable<String>(byMonthday);
    }
    if (!nullToAbsent || byMonth != null) {
      map['by_month'] = Variable<String>(byMonth);
    }
    if (!nullToAbsent || timesOfDay != null) {
      map['times_of_day'] = Variable<String>(timesOfDay);
    }
    if (!nullToAbsent || count != null) {
      map['count'] = Variable<int>(count);
    }
    if (!nullToAbsent || until != null) {
      map['until'] = Variable<int>(until);
    }
    return map;
  }

  RecurrenceRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurrenceRulesCompanion(
      id: Value(id),
      rruleString: Value(rruleString),
      freq: Value(freq),
      interval: Value(interval),
      byWeekday: byWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(byWeekday),
      byMonthday: byMonthday == null && nullToAbsent
          ? const Value.absent()
          : Value(byMonthday),
      byMonth: byMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(byMonth),
      timesOfDay: timesOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(timesOfDay),
      count: count == null && nullToAbsent
          ? const Value.absent()
          : Value(count),
      until: until == null && nullToAbsent
          ? const Value.absent()
          : Value(until),
    );
  }

  factory RecurrenceRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurrenceRule(
      id: serializer.fromJson<String>(json['id']),
      rruleString: serializer.fromJson<String>(json['rruleString']),
      freq: serializer.fromJson<String>(json['freq']),
      interval: serializer.fromJson<int>(json['interval']),
      byWeekday: serializer.fromJson<String?>(json['byWeekday']),
      byMonthday: serializer.fromJson<String?>(json['byMonthday']),
      byMonth: serializer.fromJson<String?>(json['byMonth']),
      timesOfDay: serializer.fromJson<String?>(json['timesOfDay']),
      count: serializer.fromJson<int?>(json['count']),
      until: serializer.fromJson<int?>(json['until']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rruleString': serializer.toJson<String>(rruleString),
      'freq': serializer.toJson<String>(freq),
      'interval': serializer.toJson<int>(interval),
      'byWeekday': serializer.toJson<String?>(byWeekday),
      'byMonthday': serializer.toJson<String?>(byMonthday),
      'byMonth': serializer.toJson<String?>(byMonth),
      'timesOfDay': serializer.toJson<String?>(timesOfDay),
      'count': serializer.toJson<int?>(count),
      'until': serializer.toJson<int?>(until),
    };
  }

  RecurrenceRule copyWith({
    String? id,
    String? rruleString,
    String? freq,
    int? interval,
    Value<String?> byWeekday = const Value.absent(),
    Value<String?> byMonthday = const Value.absent(),
    Value<String?> byMonth = const Value.absent(),
    Value<String?> timesOfDay = const Value.absent(),
    Value<int?> count = const Value.absent(),
    Value<int?> until = const Value.absent(),
  }) => RecurrenceRule(
    id: id ?? this.id,
    rruleString: rruleString ?? this.rruleString,
    freq: freq ?? this.freq,
    interval: interval ?? this.interval,
    byWeekday: byWeekday.present ? byWeekday.value : this.byWeekday,
    byMonthday: byMonthday.present ? byMonthday.value : this.byMonthday,
    byMonth: byMonth.present ? byMonth.value : this.byMonth,
    timesOfDay: timesOfDay.present ? timesOfDay.value : this.timesOfDay,
    count: count.present ? count.value : this.count,
    until: until.present ? until.value : this.until,
  );
  RecurrenceRule copyWithCompanion(RecurrenceRulesCompanion data) {
    return RecurrenceRule(
      id: data.id.present ? data.id.value : this.id,
      rruleString: data.rruleString.present
          ? data.rruleString.value
          : this.rruleString,
      freq: data.freq.present ? data.freq.value : this.freq,
      interval: data.interval.present ? data.interval.value : this.interval,
      byWeekday: data.byWeekday.present ? data.byWeekday.value : this.byWeekday,
      byMonthday: data.byMonthday.present
          ? data.byMonthday.value
          : this.byMonthday,
      byMonth: data.byMonth.present ? data.byMonth.value : this.byMonth,
      timesOfDay: data.timesOfDay.present
          ? data.timesOfDay.value
          : this.timesOfDay,
      count: data.count.present ? data.count.value : this.count,
      until: data.until.present ? data.until.value : this.until,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRule(')
          ..write('id: $id, ')
          ..write('rruleString: $rruleString, ')
          ..write('freq: $freq, ')
          ..write('interval: $interval, ')
          ..write('byWeekday: $byWeekday, ')
          ..write('byMonthday: $byMonthday, ')
          ..write('byMonth: $byMonth, ')
          ..write('timesOfDay: $timesOfDay, ')
          ..write('count: $count, ')
          ..write('until: $until')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rruleString,
    freq,
    interval,
    byWeekday,
    byMonthday,
    byMonth,
    timesOfDay,
    count,
    until,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurrenceRule &&
          other.id == this.id &&
          other.rruleString == this.rruleString &&
          other.freq == this.freq &&
          other.interval == this.interval &&
          other.byWeekday == this.byWeekday &&
          other.byMonthday == this.byMonthday &&
          other.byMonth == this.byMonth &&
          other.timesOfDay == this.timesOfDay &&
          other.count == this.count &&
          other.until == this.until);
}

class RecurrenceRulesCompanion extends UpdateCompanion<RecurrenceRule> {
  final Value<String> id;
  final Value<String> rruleString;
  final Value<String> freq;
  final Value<int> interval;
  final Value<String?> byWeekday;
  final Value<String?> byMonthday;
  final Value<String?> byMonth;
  final Value<String?> timesOfDay;
  final Value<int?> count;
  final Value<int?> until;
  final Value<int> rowid;
  const RecurrenceRulesCompanion({
    this.id = const Value.absent(),
    this.rruleString = const Value.absent(),
    this.freq = const Value.absent(),
    this.interval = const Value.absent(),
    this.byWeekday = const Value.absent(),
    this.byMonthday = const Value.absent(),
    this.byMonth = const Value.absent(),
    this.timesOfDay = const Value.absent(),
    this.count = const Value.absent(),
    this.until = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurrenceRulesCompanion.insert({
    required String id,
    required String rruleString,
    this.freq = const Value.absent(),
    this.interval = const Value.absent(),
    this.byWeekday = const Value.absent(),
    this.byMonthday = const Value.absent(),
    this.byMonth = const Value.absent(),
    this.timesOfDay = const Value.absent(),
    this.count = const Value.absent(),
    this.until = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rruleString = Value(rruleString);
  static Insertable<RecurrenceRule> custom({
    Expression<String>? id,
    Expression<String>? rruleString,
    Expression<String>? freq,
    Expression<int>? interval,
    Expression<String>? byWeekday,
    Expression<String>? byMonthday,
    Expression<String>? byMonth,
    Expression<String>? timesOfDay,
    Expression<int>? count,
    Expression<int>? until,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rruleString != null) 'rrule_string': rruleString,
      if (freq != null) 'freq': freq,
      if (interval != null) 'interval': interval,
      if (byWeekday != null) 'by_weekday': byWeekday,
      if (byMonthday != null) 'by_monthday': byMonthday,
      if (byMonth != null) 'by_month': byMonth,
      if (timesOfDay != null) 'times_of_day': timesOfDay,
      if (count != null) 'count': count,
      if (until != null) 'until': until,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurrenceRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? rruleString,
    Value<String>? freq,
    Value<int>? interval,
    Value<String?>? byWeekday,
    Value<String?>? byMonthday,
    Value<String?>? byMonth,
    Value<String?>? timesOfDay,
    Value<int?>? count,
    Value<int?>? until,
    Value<int>? rowid,
  }) {
    return RecurrenceRulesCompanion(
      id: id ?? this.id,
      rruleString: rruleString ?? this.rruleString,
      freq: freq ?? this.freq,
      interval: interval ?? this.interval,
      byWeekday: byWeekday ?? this.byWeekday,
      byMonthday: byMonthday ?? this.byMonthday,
      byMonth: byMonth ?? this.byMonth,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      count: count ?? this.count,
      until: until ?? this.until,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rruleString.present) {
      map['rrule_string'] = Variable<String>(rruleString.value);
    }
    if (freq.present) {
      map['freq'] = Variable<String>(freq.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (byWeekday.present) {
      map['by_weekday'] = Variable<String>(byWeekday.value);
    }
    if (byMonthday.present) {
      map['by_monthday'] = Variable<String>(byMonthday.value);
    }
    if (byMonth.present) {
      map['by_month'] = Variable<String>(byMonth.value);
    }
    if (timesOfDay.present) {
      map['times_of_day'] = Variable<String>(timesOfDay.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (until.present) {
      map['until'] = Variable<int>(until.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurrenceRulesCompanion(')
          ..write('id: $id, ')
          ..write('rruleString: $rruleString, ')
          ..write('freq: $freq, ')
          ..write('interval: $interval, ')
          ..write('byWeekday: $byWeekday, ')
          ..write('byMonthday: $byMonthday, ')
          ..write('byMonth: $byMonth, ')
          ..write('timesOfDay: $timesOfDay, ')
          ..write('count: $count, ')
          ..write('until: $until, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlarmConfigsTable extends AlarmConfigs
    with TableInfo<$AlarmConfigsTable, AlarmConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlarmConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ringtoneUriMeta = const VerificationMeta(
    'ringtoneUri',
  );
  @override
  late final GeneratedColumn<String> ringtoneUri = GeneratedColumn<String>(
    'ringtone_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vibrateMeta = const VerificationMeta(
    'vibrate',
  );
  @override
  late final GeneratedColumn<bool> vibrate = GeneratedColumn<bool>(
    'vibrate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibrate" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _volumeRampMeta = const VerificationMeta(
    'volumeRamp',
  );
  @override
  late final GeneratedColumn<bool> volumeRamp = GeneratedColumn<bool>(
    'volume_ramp',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("volume_ramp" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _snoozeMinutesMeta = const VerificationMeta(
    'snoozeMinutes',
  );
  @override
  late final GeneratedColumn<int> snoozeMinutes = GeneratedColumn<int>(
    'snooze_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _snoozeMaxCountMeta = const VerificationMeta(
    'snoozeMaxCount',
  );
  @override
  late final GeneratedColumn<int> snoozeMaxCount = GeneratedColumn<int>(
    'snooze_max_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _preNotifyMinutesMeta = const VerificationMeta(
    'preNotifyMinutes',
  );
  @override
  late final GeneratedColumn<int> preNotifyMinutes = GeneratedColumn<int>(
    'pre_notify_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shiftPatternJsonMeta = const VerificationMeta(
    'shiftPatternJson',
  );
  @override
  late final GeneratedColumn<String> shiftPatternJson = GeneratedColumn<String>(
    'shift_pattern_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    reminderId,
    ringtoneUri,
    vibrate,
    volumeRamp,
    snoozeMinutes,
    snoozeMaxCount,
    preNotifyMinutes,
    shiftPatternJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alarm_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlarmConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('ringtone_uri')) {
      context.handle(
        _ringtoneUriMeta,
        ringtoneUri.isAcceptableOrUnknown(
          data['ringtone_uri']!,
          _ringtoneUriMeta,
        ),
      );
    }
    if (data.containsKey('vibrate')) {
      context.handle(
        _vibrateMeta,
        vibrate.isAcceptableOrUnknown(data['vibrate']!, _vibrateMeta),
      );
    }
    if (data.containsKey('volume_ramp')) {
      context.handle(
        _volumeRampMeta,
        volumeRamp.isAcceptableOrUnknown(data['volume_ramp']!, _volumeRampMeta),
      );
    }
    if (data.containsKey('snooze_minutes')) {
      context.handle(
        _snoozeMinutesMeta,
        snoozeMinutes.isAcceptableOrUnknown(
          data['snooze_minutes']!,
          _snoozeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('snooze_max_count')) {
      context.handle(
        _snoozeMaxCountMeta,
        snoozeMaxCount.isAcceptableOrUnknown(
          data['snooze_max_count']!,
          _snoozeMaxCountMeta,
        ),
      );
    }
    if (data.containsKey('pre_notify_minutes')) {
      context.handle(
        _preNotifyMinutesMeta,
        preNotifyMinutes.isAcceptableOrUnknown(
          data['pre_notify_minutes']!,
          _preNotifyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('shift_pattern_json')) {
      context.handle(
        _shiftPatternJsonMeta,
        shiftPatternJson.isAcceptableOrUnknown(
          data['shift_pattern_json']!,
          _shiftPatternJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reminderId};
  @override
  AlarmConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlarmConfig(
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      )!,
      ringtoneUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ringtone_uri'],
      ),
      vibrate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibrate'],
      )!,
      volumeRamp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}volume_ramp'],
      )!,
      snoozeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_minutes'],
      )!,
      snoozeMaxCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_max_count'],
      )!,
      preNotifyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pre_notify_minutes'],
      ),
      shiftPatternJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift_pattern_json'],
      ),
    );
  }

  @override
  $AlarmConfigsTable createAlias(String alias) {
    return $AlarmConfigsTable(attachedDatabase, alias);
  }
}

class AlarmConfig extends DataClass implements Insertable<AlarmConfig> {
  final String reminderId;
  final String? ringtoneUri;
  final bool vibrate;
  final bool volumeRamp;
  final int snoozeMinutes;
  final int snoozeMaxCount;
  final int? preNotifyMinutes;
  final String? shiftPatternJson;
  const AlarmConfig({
    required this.reminderId,
    this.ringtoneUri,
    required this.vibrate,
    required this.volumeRamp,
    required this.snoozeMinutes,
    required this.snoozeMaxCount,
    this.preNotifyMinutes,
    this.shiftPatternJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reminder_id'] = Variable<String>(reminderId);
    if (!nullToAbsent || ringtoneUri != null) {
      map['ringtone_uri'] = Variable<String>(ringtoneUri);
    }
    map['vibrate'] = Variable<bool>(vibrate);
    map['volume_ramp'] = Variable<bool>(volumeRamp);
    map['snooze_minutes'] = Variable<int>(snoozeMinutes);
    map['snooze_max_count'] = Variable<int>(snoozeMaxCount);
    if (!nullToAbsent || preNotifyMinutes != null) {
      map['pre_notify_minutes'] = Variable<int>(preNotifyMinutes);
    }
    if (!nullToAbsent || shiftPatternJson != null) {
      map['shift_pattern_json'] = Variable<String>(shiftPatternJson);
    }
    return map;
  }

  AlarmConfigsCompanion toCompanion(bool nullToAbsent) {
    return AlarmConfigsCompanion(
      reminderId: Value(reminderId),
      ringtoneUri: ringtoneUri == null && nullToAbsent
          ? const Value.absent()
          : Value(ringtoneUri),
      vibrate: Value(vibrate),
      volumeRamp: Value(volumeRamp),
      snoozeMinutes: Value(snoozeMinutes),
      snoozeMaxCount: Value(snoozeMaxCount),
      preNotifyMinutes: preNotifyMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(preNotifyMinutes),
      shiftPatternJson: shiftPatternJson == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftPatternJson),
    );
  }

  factory AlarmConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlarmConfig(
      reminderId: serializer.fromJson<String>(json['reminderId']),
      ringtoneUri: serializer.fromJson<String?>(json['ringtoneUri']),
      vibrate: serializer.fromJson<bool>(json['vibrate']),
      volumeRamp: serializer.fromJson<bool>(json['volumeRamp']),
      snoozeMinutes: serializer.fromJson<int>(json['snoozeMinutes']),
      snoozeMaxCount: serializer.fromJson<int>(json['snoozeMaxCount']),
      preNotifyMinutes: serializer.fromJson<int?>(json['preNotifyMinutes']),
      shiftPatternJson: serializer.fromJson<String?>(json['shiftPatternJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reminderId': serializer.toJson<String>(reminderId),
      'ringtoneUri': serializer.toJson<String?>(ringtoneUri),
      'vibrate': serializer.toJson<bool>(vibrate),
      'volumeRamp': serializer.toJson<bool>(volumeRamp),
      'snoozeMinutes': serializer.toJson<int>(snoozeMinutes),
      'snoozeMaxCount': serializer.toJson<int>(snoozeMaxCount),
      'preNotifyMinutes': serializer.toJson<int?>(preNotifyMinutes),
      'shiftPatternJson': serializer.toJson<String?>(shiftPatternJson),
    };
  }

  AlarmConfig copyWith({
    String? reminderId,
    Value<String?> ringtoneUri = const Value.absent(),
    bool? vibrate,
    bool? volumeRamp,
    int? snoozeMinutes,
    int? snoozeMaxCount,
    Value<int?> preNotifyMinutes = const Value.absent(),
    Value<String?> shiftPatternJson = const Value.absent(),
  }) => AlarmConfig(
    reminderId: reminderId ?? this.reminderId,
    ringtoneUri: ringtoneUri.present ? ringtoneUri.value : this.ringtoneUri,
    vibrate: vibrate ?? this.vibrate,
    volumeRamp: volumeRamp ?? this.volumeRamp,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    snoozeMaxCount: snoozeMaxCount ?? this.snoozeMaxCount,
    preNotifyMinutes: preNotifyMinutes.present
        ? preNotifyMinutes.value
        : this.preNotifyMinutes,
    shiftPatternJson: shiftPatternJson.present
        ? shiftPatternJson.value
        : this.shiftPatternJson,
  );
  AlarmConfig copyWithCompanion(AlarmConfigsCompanion data) {
    return AlarmConfig(
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      ringtoneUri: data.ringtoneUri.present
          ? data.ringtoneUri.value
          : this.ringtoneUri,
      vibrate: data.vibrate.present ? data.vibrate.value : this.vibrate,
      volumeRamp: data.volumeRamp.present
          ? data.volumeRamp.value
          : this.volumeRamp,
      snoozeMinutes: data.snoozeMinutes.present
          ? data.snoozeMinutes.value
          : this.snoozeMinutes,
      snoozeMaxCount: data.snoozeMaxCount.present
          ? data.snoozeMaxCount.value
          : this.snoozeMaxCount,
      preNotifyMinutes: data.preNotifyMinutes.present
          ? data.preNotifyMinutes.value
          : this.preNotifyMinutes,
      shiftPatternJson: data.shiftPatternJson.present
          ? data.shiftPatternJson.value
          : this.shiftPatternJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlarmConfig(')
          ..write('reminderId: $reminderId, ')
          ..write('ringtoneUri: $ringtoneUri, ')
          ..write('vibrate: $vibrate, ')
          ..write('volumeRamp: $volumeRamp, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('snoozeMaxCount: $snoozeMaxCount, ')
          ..write('preNotifyMinutes: $preNotifyMinutes, ')
          ..write('shiftPatternJson: $shiftPatternJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    reminderId,
    ringtoneUri,
    vibrate,
    volumeRamp,
    snoozeMinutes,
    snoozeMaxCount,
    preNotifyMinutes,
    shiftPatternJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlarmConfig &&
          other.reminderId == this.reminderId &&
          other.ringtoneUri == this.ringtoneUri &&
          other.vibrate == this.vibrate &&
          other.volumeRamp == this.volumeRamp &&
          other.snoozeMinutes == this.snoozeMinutes &&
          other.snoozeMaxCount == this.snoozeMaxCount &&
          other.preNotifyMinutes == this.preNotifyMinutes &&
          other.shiftPatternJson == this.shiftPatternJson);
}

class AlarmConfigsCompanion extends UpdateCompanion<AlarmConfig> {
  final Value<String> reminderId;
  final Value<String?> ringtoneUri;
  final Value<bool> vibrate;
  final Value<bool> volumeRamp;
  final Value<int> snoozeMinutes;
  final Value<int> snoozeMaxCount;
  final Value<int?> preNotifyMinutes;
  final Value<String?> shiftPatternJson;
  final Value<int> rowid;
  const AlarmConfigsCompanion({
    this.reminderId = const Value.absent(),
    this.ringtoneUri = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.volumeRamp = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.snoozeMaxCount = const Value.absent(),
    this.preNotifyMinutes = const Value.absent(),
    this.shiftPatternJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlarmConfigsCompanion.insert({
    required String reminderId,
    this.ringtoneUri = const Value.absent(),
    this.vibrate = const Value.absent(),
    this.volumeRamp = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.snoozeMaxCount = const Value.absent(),
    this.preNotifyMinutes = const Value.absent(),
    this.shiftPatternJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : reminderId = Value(reminderId);
  static Insertable<AlarmConfig> custom({
    Expression<String>? reminderId,
    Expression<String>? ringtoneUri,
    Expression<bool>? vibrate,
    Expression<bool>? volumeRamp,
    Expression<int>? snoozeMinutes,
    Expression<int>? snoozeMaxCount,
    Expression<int>? preNotifyMinutes,
    Expression<String>? shiftPatternJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reminderId != null) 'reminder_id': reminderId,
      if (ringtoneUri != null) 'ringtone_uri': ringtoneUri,
      if (vibrate != null) 'vibrate': vibrate,
      if (volumeRamp != null) 'volume_ramp': volumeRamp,
      if (snoozeMinutes != null) 'snooze_minutes': snoozeMinutes,
      if (snoozeMaxCount != null) 'snooze_max_count': snoozeMaxCount,
      if (preNotifyMinutes != null) 'pre_notify_minutes': preNotifyMinutes,
      if (shiftPatternJson != null) 'shift_pattern_json': shiftPatternJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlarmConfigsCompanion copyWith({
    Value<String>? reminderId,
    Value<String?>? ringtoneUri,
    Value<bool>? vibrate,
    Value<bool>? volumeRamp,
    Value<int>? snoozeMinutes,
    Value<int>? snoozeMaxCount,
    Value<int?>? preNotifyMinutes,
    Value<String?>? shiftPatternJson,
    Value<int>? rowid,
  }) {
    return AlarmConfigsCompanion(
      reminderId: reminderId ?? this.reminderId,
      ringtoneUri: ringtoneUri ?? this.ringtoneUri,
      vibrate: vibrate ?? this.vibrate,
      volumeRamp: volumeRamp ?? this.volumeRamp,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      snoozeMaxCount: snoozeMaxCount ?? this.snoozeMaxCount,
      preNotifyMinutes: preNotifyMinutes ?? this.preNotifyMinutes,
      shiftPatternJson: shiftPatternJson ?? this.shiftPatternJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (ringtoneUri.present) {
      map['ringtone_uri'] = Variable<String>(ringtoneUri.value);
    }
    if (vibrate.present) {
      map['vibrate'] = Variable<bool>(vibrate.value);
    }
    if (volumeRamp.present) {
      map['volume_ramp'] = Variable<bool>(volumeRamp.value);
    }
    if (snoozeMinutes.present) {
      map['snooze_minutes'] = Variable<int>(snoozeMinutes.value);
    }
    if (snoozeMaxCount.present) {
      map['snooze_max_count'] = Variable<int>(snoozeMaxCount.value);
    }
    if (preNotifyMinutes.present) {
      map['pre_notify_minutes'] = Variable<int>(preNotifyMinutes.value);
    }
    if (shiftPatternJson.present) {
      map['shift_pattern_json'] = Variable<String>(shiftPatternJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlarmConfigsCompanion(')
          ..write('reminderId: $reminderId, ')
          ..write('ringtoneUri: $ringtoneUri, ')
          ..write('vibrate: $vibrate, ')
          ..write('volumeRamp: $volumeRamp, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('snoozeMaxCount: $snoozeMaxCount, ')
          ..write('preNotifyMinutes: $preNotifyMinutes, ')
          ..write('shiftPatternJson: $shiftPatternJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OccurrencesTable extends Occurrences
    with TableInfo<$OccurrencesTable, Occurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firedAtMeta = const VerificationMeta(
    'firedAt',
  );
  @override
  late final GeneratedColumn<int> firedAt = GeneratedColumn<int>(
    'fired_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _osScheduledMeta = const VerificationMeta(
    'osScheduled',
  );
  @override
  late final GeneratedColumn<bool> osScheduled = GeneratedColumn<bool>(
    'os_scheduled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("os_scheduled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reminderId,
    scheduledAt,
    state,
    snoozeCount,
    firedAt,
    osScheduled,
    syncStatus,
    userId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Occurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('fired_at')) {
      context.handle(
        _firedAtMeta,
        firedAt.isAcceptableOrUnknown(data['fired_at']!, _firedAtMeta),
      );
    }
    if (data.containsKey('os_scheduled')) {
      context.handle(
        _osScheduledMeta,
        osScheduled.isAcceptableOrUnknown(
          data['os_scheduled']!,
          _osScheduledMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Occurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Occurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      firedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fired_at'],
      ),
      osScheduled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}os_scheduled'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $OccurrencesTable createAlias(String alias) {
    return $OccurrencesTable(attachedDatabase, alias);
  }
}

class Occurrence extends DataClass implements Insertable<Occurrence> {
  final String id;
  final String reminderId;
  final int scheduledAt;
  final String state;
  final int snoozeCount;
  final int? firedAt;
  final bool osScheduled;
  final String? syncStatus;
  final String? userId;
  final int? updatedAt;
  const Occurrence({
    required this.id,
    required this.reminderId,
    required this.scheduledAt,
    required this.state,
    required this.snoozeCount,
    this.firedAt,
    required this.osScheduled,
    this.syncStatus,
    this.userId,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reminder_id'] = Variable<String>(reminderId);
    map['scheduled_at'] = Variable<int>(scheduledAt);
    map['state'] = Variable<String>(state);
    map['snooze_count'] = Variable<int>(snoozeCount);
    if (!nullToAbsent || firedAt != null) {
      map['fired_at'] = Variable<int>(firedAt);
    }
    map['os_scheduled'] = Variable<bool>(osScheduled);
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  OccurrencesCompanion toCompanion(bool nullToAbsent) {
    return OccurrencesCompanion(
      id: Value(id),
      reminderId: Value(reminderId),
      scheduledAt: Value(scheduledAt),
      state: Value(state),
      snoozeCount: Value(snoozeCount),
      firedAt: firedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firedAt),
      osScheduled: Value(osScheduled),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Occurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Occurrence(
      id: serializer.fromJson<String>(json['id']),
      reminderId: serializer.fromJson<String>(json['reminderId']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      state: serializer.fromJson<String>(json['state']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      firedAt: serializer.fromJson<int?>(json['firedAt']),
      osScheduled: serializer.fromJson<bool>(json['osScheduled']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      userId: serializer.fromJson<String?>(json['userId']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reminderId': serializer.toJson<String>(reminderId),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'state': serializer.toJson<String>(state),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'firedAt': serializer.toJson<int?>(firedAt),
      'osScheduled': serializer.toJson<bool>(osScheduled),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'userId': serializer.toJson<String?>(userId),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  Occurrence copyWith({
    String? id,
    String? reminderId,
    int? scheduledAt,
    String? state,
    int? snoozeCount,
    Value<int?> firedAt = const Value.absent(),
    bool? osScheduled,
    Value<String?> syncStatus = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => Occurrence(
    id: id ?? this.id,
    reminderId: reminderId ?? this.reminderId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    state: state ?? this.state,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    firedAt: firedAt.present ? firedAt.value : this.firedAt,
    osScheduled: osScheduled ?? this.osScheduled,
    syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
    userId: userId.present ? userId.value : this.userId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Occurrence copyWithCompanion(OccurrencesCompanion data) {
    return Occurrence(
      id: data.id.present ? data.id.value : this.id,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      state: data.state.present ? data.state.value : this.state,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      firedAt: data.firedAt.present ? data.firedAt.value : this.firedAt,
      osScheduled: data.osScheduled.present
          ? data.osScheduled.value
          : this.osScheduled,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      userId: data.userId.present ? data.userId.value : this.userId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Occurrence(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('state: $state, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('firedAt: $firedAt, ')
          ..write('osScheduled: $osScheduled, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reminderId,
    scheduledAt,
    state,
    snoozeCount,
    firedAt,
    osScheduled,
    syncStatus,
    userId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Occurrence &&
          other.id == this.id &&
          other.reminderId == this.reminderId &&
          other.scheduledAt == this.scheduledAt &&
          other.state == this.state &&
          other.snoozeCount == this.snoozeCount &&
          other.firedAt == this.firedAt &&
          other.osScheduled == this.osScheduled &&
          other.syncStatus == this.syncStatus &&
          other.userId == this.userId &&
          other.updatedAt == this.updatedAt);
}

class OccurrencesCompanion extends UpdateCompanion<Occurrence> {
  final Value<String> id;
  final Value<String> reminderId;
  final Value<int> scheduledAt;
  final Value<String> state;
  final Value<int> snoozeCount;
  final Value<int?> firedAt;
  final Value<bool> osScheduled;
  final Value<String?> syncStatus;
  final Value<String?> userId;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const OccurrencesCompanion({
    this.id = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.state = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.firedAt = const Value.absent(),
    this.osScheduled = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OccurrencesCompanion.insert({
    required String id,
    required String reminderId,
    required int scheduledAt,
    this.state = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.firedAt = const Value.absent(),
    this.osScheduled = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reminderId = Value(reminderId),
       scheduledAt = Value(scheduledAt);
  static Insertable<Occurrence> custom({
    Expression<String>? id,
    Expression<String>? reminderId,
    Expression<int>? scheduledAt,
    Expression<String>? state,
    Expression<int>? snoozeCount,
    Expression<int>? firedAt,
    Expression<bool>? osScheduled,
    Expression<String>? syncStatus,
    Expression<String>? userId,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderId != null) 'reminder_id': reminderId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (state != null) 'state': state,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (firedAt != null) 'fired_at': firedAt,
      if (osScheduled != null) 'os_scheduled': osScheduled,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? reminderId,
    Value<int>? scheduledAt,
    Value<String>? state,
    Value<int>? snoozeCount,
    Value<int?>? firedAt,
    Value<bool>? osScheduled,
    Value<String?>? syncStatus,
    Value<String?>? userId,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return OccurrencesCompanion(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      state: state ?? this.state,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      firedAt: firedAt ?? this.firedAt,
      osScheduled: osScheduled ?? this.osScheduled,
      syncStatus: syncStatus ?? this.syncStatus,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (firedAt.present) {
      map['fired_at'] = Variable<int>(firedAt.value);
    }
    if (osScheduled.present) {
      map['os_scheduled'] = Variable<bool>(osScheduled.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('state: $state, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('firedAt: $firedAt, ')
          ..write('osScheduled: $osScheduled, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _softTargetMsMeta = const VerificationMeta(
    'softTargetMs',
  );
  @override
  late final GeneratedColumn<int> softTargetMs = GeneratedColumn<int>(
    'soft_target_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileMeta = const VerificationMeta(
    'profile',
  );
  @override
  late final GeneratedColumn<String> profile = GeneratedColumn<String>(
    'profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('workout'),
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
    startedAt,
    endedAt,
    targetSets,
    softTargetMs,
    profile,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSetsMeta);
    }
    if (data.containsKey('soft_target_ms')) {
      context.handle(
        _softTargetMsMeta,
        softTargetMs.isAcceptableOrUnknown(
          data['soft_target_ms']!,
          _softTargetMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_softTargetMsMeta);
    }
    if (data.containsKey('profile')) {
      context.handle(
        _profileMeta,
        profile.isAcceptableOrUnknown(data['profile']!, _profileMeta),
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
  WorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      softTargetMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}soft_target_ms'],
      )!,
      profile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionRow extends DataClass
    implements Insertable<WorkoutSessionRow> {
  final String id;
  final int startedAt;
  final int? endedAt;
  final int targetSets;
  final int softTargetMs;
  final String profile;
  final int createdAt;
  const WorkoutSessionRow({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.targetSets,
    required this.softTargetMs,
    required this.profile,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['target_sets'] = Variable<int>(targetSets);
    map['soft_target_ms'] = Variable<int>(softTargetMs);
    map['profile'] = Variable<String>(profile);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      targetSets: Value(targetSets),
      softTargetMs: Value(softTargetMs),
      profile: Value(profile),
      createdAt: Value(createdAt),
    );
  }

  factory WorkoutSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionRow(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      softTargetMs: serializer.fromJson<int>(json['softTargetMs']),
      profile: serializer.fromJson<String>(json['profile']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'targetSets': serializer.toJson<int>(targetSets),
      'softTargetMs': serializer.toJson<int>(softTargetMs),
      'profile': serializer.toJson<String>(profile),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  WorkoutSessionRow copyWith({
    String? id,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    int? targetSets,
    int? softTargetMs,
    String? profile,
    int? createdAt,
  }) => WorkoutSessionRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    targetSets: targetSets ?? this.targetSets,
    softTargetMs: softTargetMs ?? this.softTargetMs,
    profile: profile ?? this.profile,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkoutSessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      softTargetMs: data.softTargetMs.present
          ? data.softTargetMs.value
          : this.softTargetMs,
      profile: data.profile.present ? data.profile.value : this.profile,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetSets: $targetSets, ')
          ..write('softTargetMs: $softTargetMs, ')
          ..write('profile: $profile, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    targetSets,
    softTargetMs,
    profile,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.targetSets == this.targetSets &&
          other.softTargetMs == this.softTargetMs &&
          other.profile == this.profile &&
          other.createdAt == this.createdAt);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionRow> {
  final Value<String> id;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int> targetSets;
  final Value<int> softTargetMs;
  final Value<String> profile;
  final Value<int> createdAt;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.softTargetMs = const Value.absent(),
    this.profile = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required int startedAt,
    this.endedAt = const Value.absent(),
    required int targetSets,
    required int softTargetMs,
    this.profile = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       targetSets = Value(targetSets),
       softTargetMs = Value(softTargetMs),
       createdAt = Value(createdAt);
  static Insertable<WorkoutSessionRow> custom({
    Expression<String>? id,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? targetSets,
    Expression<int>? softTargetMs,
    Expression<String>? profile,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (targetSets != null) 'target_sets': targetSets,
      if (softTargetMs != null) 'soft_target_ms': softTargetMs,
      if (profile != null) 'profile': profile,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int>? targetSets,
    Value<int>? softTargetMs,
    Value<String>? profile,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      targetSets: targetSets ?? this.targetSets,
      softTargetMs: softTargetMs ?? this.softTargetMs,
      profile: profile ?? this.profile,
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
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (softTargetMs.present) {
      map['soft_target_ms'] = Variable<int>(softTargetMs.value);
    }
    if (profile.present) {
      map['profile'] = Variable<String>(profile.value);
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
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetSets: $targetSets, ')
          ..write('softTargetMs: $softTargetMs, ')
          ..write('profile: $profile, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetRecordsTable extends SetRecords
    with TableInfo<$SetRecordsTable, SetRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restStartMsMeta = const VerificationMeta(
    'restStartMs',
  );
  @override
  late final GeneratedColumn<int> restStartMs = GeneratedColumn<int>(
    'rest_start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restEndMsMeta = const VerificationMeta(
    'restEndMs',
  );
  @override
  late final GeneratedColumn<int> restEndMs = GeneratedColumn<int>(
    'rest_end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restDurationMsMeta = const VerificationMeta(
    'restDurationMs',
  );
  @override
  late final GeneratedColumn<int> restDurationMs = GeneratedColumn<int>(
    'rest_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cueConfigJsonMeta = const VerificationMeta(
    'cueConfigJson',
  );
  @override
  late final GeneratedColumn<String> cueConfigJson = GeneratedColumn<String>(
    'cue_config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    id,
    sessionId,
    setIndex,
    restStartMs,
    restEndMs,
    restDurationMs,
    cueConfigJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('rest_start_ms')) {
      context.handle(
        _restStartMsMeta,
        restStartMs.isAcceptableOrUnknown(
          data['rest_start_ms']!,
          _restStartMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restStartMsMeta);
    }
    if (data.containsKey('rest_end_ms')) {
      context.handle(
        _restEndMsMeta,
        restEndMs.isAcceptableOrUnknown(data['rest_end_ms']!, _restEndMsMeta),
      );
    } else if (isInserting) {
      context.missing(_restEndMsMeta);
    }
    if (data.containsKey('rest_duration_ms')) {
      context.handle(
        _restDurationMsMeta,
        restDurationMs.isAcceptableOrUnknown(
          data['rest_duration_ms']!,
          _restDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restDurationMsMeta);
    }
    if (data.containsKey('cue_config_json')) {
      context.handle(
        _cueConfigJsonMeta,
        cueConfigJson.isAcceptableOrUnknown(
          data['cue_config_json']!,
          _cueConfigJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cueConfigJsonMeta);
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
  SetRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      restStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_start_ms'],
      )!,
      restEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_end_ms'],
      )!,
      restDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_duration_ms'],
      )!,
      cueConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_config_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SetRecordsTable createAlias(String alias) {
    return $SetRecordsTable(attachedDatabase, alias);
  }
}

class SetRecordRow extends DataClass implements Insertable<SetRecordRow> {
  final String id;
  final String sessionId;
  final int setIndex;
  final int restStartMs;
  final int restEndMs;
  final int restDurationMs;
  final String cueConfigJson;
  final int createdAt;
  const SetRecordRow({
    required this.id,
    required this.sessionId,
    required this.setIndex,
    required this.restStartMs,
    required this.restEndMs,
    required this.restDurationMs,
    required this.cueConfigJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['set_index'] = Variable<int>(setIndex);
    map['rest_start_ms'] = Variable<int>(restStartMs);
    map['rest_end_ms'] = Variable<int>(restEndMs);
    map['rest_duration_ms'] = Variable<int>(restDurationMs);
    map['cue_config_json'] = Variable<String>(cueConfigJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SetRecordsCompanion toCompanion(bool nullToAbsent) {
    return SetRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      setIndex: Value(setIndex),
      restStartMs: Value(restStartMs),
      restEndMs: Value(restEndMs),
      restDurationMs: Value(restDurationMs),
      cueConfigJson: Value(cueConfigJson),
      createdAt: Value(createdAt),
    );
  }

  factory SetRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetRecordRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      restStartMs: serializer.fromJson<int>(json['restStartMs']),
      restEndMs: serializer.fromJson<int>(json['restEndMs']),
      restDurationMs: serializer.fromJson<int>(json['restDurationMs']),
      cueConfigJson: serializer.fromJson<String>(json['cueConfigJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'setIndex': serializer.toJson<int>(setIndex),
      'restStartMs': serializer.toJson<int>(restStartMs),
      'restEndMs': serializer.toJson<int>(restEndMs),
      'restDurationMs': serializer.toJson<int>(restDurationMs),
      'cueConfigJson': serializer.toJson<String>(cueConfigJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SetRecordRow copyWith({
    String? id,
    String? sessionId,
    int? setIndex,
    int? restStartMs,
    int? restEndMs,
    int? restDurationMs,
    String? cueConfigJson,
    int? createdAt,
  }) => SetRecordRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    setIndex: setIndex ?? this.setIndex,
    restStartMs: restStartMs ?? this.restStartMs,
    restEndMs: restEndMs ?? this.restEndMs,
    restDurationMs: restDurationMs ?? this.restDurationMs,
    cueConfigJson: cueConfigJson ?? this.cueConfigJson,
    createdAt: createdAt ?? this.createdAt,
  );
  SetRecordRow copyWithCompanion(SetRecordsCompanion data) {
    return SetRecordRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      restStartMs: data.restStartMs.present
          ? data.restStartMs.value
          : this.restStartMs,
      restEndMs: data.restEndMs.present ? data.restEndMs.value : this.restEndMs,
      restDurationMs: data.restDurationMs.present
          ? data.restDurationMs.value
          : this.restDurationMs,
      cueConfigJson: data.cueConfigJson.present
          ? data.cueConfigJson.value
          : this.cueConfigJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetRecordRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('setIndex: $setIndex, ')
          ..write('restStartMs: $restStartMs, ')
          ..write('restEndMs: $restEndMs, ')
          ..write('restDurationMs: $restDurationMs, ')
          ..write('cueConfigJson: $cueConfigJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    setIndex,
    restStartMs,
    restEndMs,
    restDurationMs,
    cueConfigJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetRecordRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.setIndex == this.setIndex &&
          other.restStartMs == this.restStartMs &&
          other.restEndMs == this.restEndMs &&
          other.restDurationMs == this.restDurationMs &&
          other.cueConfigJson == this.cueConfigJson &&
          other.createdAt == this.createdAt);
}

class SetRecordsCompanion extends UpdateCompanion<SetRecordRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> setIndex;
  final Value<int> restStartMs;
  final Value<int> restEndMs;
  final Value<int> restDurationMs;
  final Value<String> cueConfigJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SetRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.restStartMs = const Value.absent(),
    this.restEndMs = const Value.absent(),
    this.restDurationMs = const Value.absent(),
    this.cueConfigJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetRecordsCompanion.insert({
    required String id,
    required String sessionId,
    required int setIndex,
    required int restStartMs,
    required int restEndMs,
    required int restDurationMs,
    required String cueConfigJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       setIndex = Value(setIndex),
       restStartMs = Value(restStartMs),
       restEndMs = Value(restEndMs),
       restDurationMs = Value(restDurationMs),
       cueConfigJson = Value(cueConfigJson),
       createdAt = Value(createdAt);
  static Insertable<SetRecordRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? setIndex,
    Expression<int>? restStartMs,
    Expression<int>? restEndMs,
    Expression<int>? restDurationMs,
    Expression<String>? cueConfigJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (setIndex != null) 'set_index': setIndex,
      if (restStartMs != null) 'rest_start_ms': restStartMs,
      if (restEndMs != null) 'rest_end_ms': restEndMs,
      if (restDurationMs != null) 'rest_duration_ms': restDurationMs,
      if (cueConfigJson != null) 'cue_config_json': cueConfigJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? setIndex,
    Value<int>? restStartMs,
    Value<int>? restEndMs,
    Value<int>? restDurationMs,
    Value<String>? cueConfigJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SetRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      setIndex: setIndex ?? this.setIndex,
      restStartMs: restStartMs ?? this.restStartMs,
      restEndMs: restEndMs ?? this.restEndMs,
      restDurationMs: restDurationMs ?? this.restDurationMs,
      cueConfigJson: cueConfigJson ?? this.cueConfigJson,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (restStartMs.present) {
      map['rest_start_ms'] = Variable<int>(restStartMs.value);
    }
    if (restEndMs.present) {
      map['rest_end_ms'] = Variable<int>(restEndMs.value);
    }
    if (restDurationMs.present) {
      map['rest_duration_ms'] = Variable<int>(restDurationMs.value);
    }
    if (cueConfigJson.present) {
      map['cue_config_json'] = Variable<String>(cueConfigJson.value);
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
    return (StringBuffer('SetRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('setIndex: $setIndex, ')
          ..write('restStartMs: $restStartMs, ')
          ..write('restEndMs: $restEndMs, ')
          ..write('restDurationMs: $restDurationMs, ')
          ..write('cueConfigJson: $cueConfigJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $RecurrenceRulesTable recurrenceRules = $RecurrenceRulesTable(
    this,
  );
  late final $AlarmConfigsTable alarmConfigs = $AlarmConfigsTable(this);
  late final $OccurrencesTable occurrences = $OccurrencesTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $SetRecordsTable setRecords = $SetRecordsTable(this);
  late final ReminderDao reminderDao = ReminderDao(this as AppDatabase);
  late final OccurrenceDao occurrenceDao = OccurrenceDao(this as AppDatabase);
  late final RecurrenceRuleDao recurrenceRuleDao = RecurrenceRuleDao(
    this as AppDatabase,
  );
  late final AlarmConfigDao alarmConfigDao = AlarmConfigDao(
    this as AppDatabase,
  );
  late final WorkoutDao workoutDao = WorkoutDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    reminders,
    recurrenceRules,
    alarmConfigs,
    occurrences,
    workoutSessions,
    setRecords,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      required String displayName,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> displayName,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String displayName,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      Value<String?> userId,
      required String type,
      required String title,
      Value<String?> note,
      required int startAt,
      Value<String> timezone,
      Value<String?> recurrenceRuleId,
      Value<String> alertLevel,
      Value<bool> isEnabled,
      Value<bool> isCompleted,
      Value<int?> completedAt,
      required int createdAt,
      required int updatedAt,
      Value<bool> isDeleted,
      Value<int> version,
      Value<String> syncStatus,
      Value<String?> color,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> type,
      Value<String> title,
      Value<String?> note,
      Value<int> startAt,
      Value<String> timezone,
      Value<String?> recurrenceRuleId,
      Value<String> alertLevel,
      Value<bool> isEnabled,
      Value<bool> isCompleted,
      Value<int?> completedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<bool> isDeleted,
      Value<int> version,
      Value<String> syncStatus,
      Value<String?> color,
      Value<int> rowid,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertLevel => $composableBuilder(
    column: $table.alertLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertLevel => $composableBuilder(
    column: $table.alertLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRuleId => $composableBuilder(
    column: $table.recurrenceRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertLevel => $composableBuilder(
    column: $table.alertLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> startAt = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String?> recurrenceRuleId = const Value.absent(),
                Value<String> alertLevel = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                userId: userId,
                type: type,
                title: title,
                note: note,
                startAt: startAt,
                timezone: timezone,
                recurrenceRuleId: recurrenceRuleId,
                alertLevel: alertLevel,
                isEnabled: isEnabled,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                version: version,
                syncStatus: syncStatus,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String type,
                required String title,
                Value<String?> note = const Value.absent(),
                required int startAt,
                Value<String> timezone = const Value.absent(),
                Value<String?> recurrenceRuleId = const Value.absent(),
                Value<String> alertLevel = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                title: title,
                note: note,
                startAt: startAt,
                timezone: timezone,
                recurrenceRuleId: recurrenceRuleId,
                alertLevel: alertLevel,
                isEnabled: isEnabled,
                isCompleted: isCompleted,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                version: version,
                syncStatus: syncStatus,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;
typedef $$RecurrenceRulesTableCreateCompanionBuilder =
    RecurrenceRulesCompanion Function({
      required String id,
      required String rruleString,
      Value<String> freq,
      Value<int> interval,
      Value<String?> byWeekday,
      Value<String?> byMonthday,
      Value<String?> byMonth,
      Value<String?> timesOfDay,
      Value<int?> count,
      Value<int?> until,
      Value<int> rowid,
    });
typedef $$RecurrenceRulesTableUpdateCompanionBuilder =
    RecurrenceRulesCompanion Function({
      Value<String> id,
      Value<String> rruleString,
      Value<String> freq,
      Value<int> interval,
      Value<String?> byWeekday,
      Value<String?> byMonthday,
      Value<String?> byMonth,
      Value<String?> timesOfDay,
      Value<int?> count,
      Value<int?> until,
      Value<int> rowid,
    });

class $$RecurrenceRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableFilterComposer({
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

  ColumnFilters<String> get rruleString => $composableBuilder(
    column: $table.rruleString,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get byWeekday => $composableBuilder(
    column: $table.byWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get byMonthday => $composableBuilder(
    column: $table.byMonthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get byMonth => $composableBuilder(
    column: $table.byMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timesOfDay => $composableBuilder(
    column: $table.timesOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get until => $composableBuilder(
    column: $table.until,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurrenceRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableOrderingComposer({
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

  ColumnOrderings<String> get rruleString => $composableBuilder(
    column: $table.rruleString,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freq => $composableBuilder(
    column: $table.freq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get byWeekday => $composableBuilder(
    column: $table.byWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get byMonthday => $composableBuilder(
    column: $table.byMonthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get byMonth => $composableBuilder(
    column: $table.byMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timesOfDay => $composableBuilder(
    column: $table.timesOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get until => $composableBuilder(
    column: $table.until,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurrenceRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurrenceRulesTable> {
  $$RecurrenceRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rruleString => $composableBuilder(
    column: $table.rruleString,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freq =>
      $composableBuilder(column: $table.freq, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<String> get byWeekday =>
      $composableBuilder(column: $table.byWeekday, builder: (column) => column);

  GeneratedColumn<String> get byMonthday => $composableBuilder(
    column: $table.byMonthday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get byMonth =>
      $composableBuilder(column: $table.byMonth, builder: (column) => column);

  GeneratedColumn<String> get timesOfDay => $composableBuilder(
    column: $table.timesOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get until =>
      $composableBuilder(column: $table.until, builder: (column) => column);
}

class $$RecurrenceRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurrenceRulesTable,
          RecurrenceRule,
          $$RecurrenceRulesTableFilterComposer,
          $$RecurrenceRulesTableOrderingComposer,
          $$RecurrenceRulesTableAnnotationComposer,
          $$RecurrenceRulesTableCreateCompanionBuilder,
          $$RecurrenceRulesTableUpdateCompanionBuilder,
          (
            RecurrenceRule,
            BaseReferences<
              _$AppDatabase,
              $RecurrenceRulesTable,
              RecurrenceRule
            >,
          ),
          RecurrenceRule,
          PrefetchHooks Function()
        > {
  $$RecurrenceRulesTableTableManager(
    _$AppDatabase db,
    $RecurrenceRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurrenceRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurrenceRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurrenceRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> rruleString = const Value.absent(),
                Value<String> freq = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<String?> byWeekday = const Value.absent(),
                Value<String?> byMonthday = const Value.absent(),
                Value<String?> byMonth = const Value.absent(),
                Value<String?> timesOfDay = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<int?> until = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceRulesCompanion(
                id: id,
                rruleString: rruleString,
                freq: freq,
                interval: interval,
                byWeekday: byWeekday,
                byMonthday: byMonthday,
                byMonth: byMonth,
                timesOfDay: timesOfDay,
                count: count,
                until: until,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String rruleString,
                Value<String> freq = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<String?> byWeekday = const Value.absent(),
                Value<String?> byMonthday = const Value.absent(),
                Value<String?> byMonth = const Value.absent(),
                Value<String?> timesOfDay = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<int?> until = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurrenceRulesCompanion.insert(
                id: id,
                rruleString: rruleString,
                freq: freq,
                interval: interval,
                byWeekday: byWeekday,
                byMonthday: byMonthday,
                byMonth: byMonth,
                timesOfDay: timesOfDay,
                count: count,
                until: until,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurrenceRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurrenceRulesTable,
      RecurrenceRule,
      $$RecurrenceRulesTableFilterComposer,
      $$RecurrenceRulesTableOrderingComposer,
      $$RecurrenceRulesTableAnnotationComposer,
      $$RecurrenceRulesTableCreateCompanionBuilder,
      $$RecurrenceRulesTableUpdateCompanionBuilder,
      (
        RecurrenceRule,
        BaseReferences<_$AppDatabase, $RecurrenceRulesTable, RecurrenceRule>,
      ),
      RecurrenceRule,
      PrefetchHooks Function()
    >;
typedef $$AlarmConfigsTableCreateCompanionBuilder =
    AlarmConfigsCompanion Function({
      required String reminderId,
      Value<String?> ringtoneUri,
      Value<bool> vibrate,
      Value<bool> volumeRamp,
      Value<int> snoozeMinutes,
      Value<int> snoozeMaxCount,
      Value<int?> preNotifyMinutes,
      Value<String?> shiftPatternJson,
      Value<int> rowid,
    });
typedef $$AlarmConfigsTableUpdateCompanionBuilder =
    AlarmConfigsCompanion Function({
      Value<String> reminderId,
      Value<String?> ringtoneUri,
      Value<bool> vibrate,
      Value<bool> volumeRamp,
      Value<int> snoozeMinutes,
      Value<int> snoozeMaxCount,
      Value<int?> preNotifyMinutes,
      Value<String?> shiftPatternJson,
      Value<int> rowid,
    });

class $$AlarmConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $AlarmConfigsTable> {
  $$AlarmConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ringtoneUri => $composableBuilder(
    column: $table.ringtoneUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get volumeRamp => $composableBuilder(
    column: $table.volumeRamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeMaxCount => $composableBuilder(
    column: $table.snoozeMaxCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preNotifyMinutes => $composableBuilder(
    column: $table.preNotifyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shiftPatternJson => $composableBuilder(
    column: $table.shiftPatternJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlarmConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlarmConfigsTable> {
  $$AlarmConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ringtoneUri => $composableBuilder(
    column: $table.ringtoneUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrate => $composableBuilder(
    column: $table.vibrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get volumeRamp => $composableBuilder(
    column: $table.volumeRamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeMaxCount => $composableBuilder(
    column: $table.snoozeMaxCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preNotifyMinutes => $composableBuilder(
    column: $table.preNotifyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shiftPatternJson => $composableBuilder(
    column: $table.shiftPatternJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlarmConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlarmConfigsTable> {
  $$AlarmConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ringtoneUri => $composableBuilder(
    column: $table.ringtoneUri,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vibrate =>
      $composableBuilder(column: $table.vibrate, builder: (column) => column);

  GeneratedColumn<bool> get volumeRamp => $composableBuilder(
    column: $table.volumeRamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeMaxCount => $composableBuilder(
    column: $table.snoozeMaxCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preNotifyMinutes => $composableBuilder(
    column: $table.preNotifyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shiftPatternJson => $composableBuilder(
    column: $table.shiftPatternJson,
    builder: (column) => column,
  );
}

class $$AlarmConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlarmConfigsTable,
          AlarmConfig,
          $$AlarmConfigsTableFilterComposer,
          $$AlarmConfigsTableOrderingComposer,
          $$AlarmConfigsTableAnnotationComposer,
          $$AlarmConfigsTableCreateCompanionBuilder,
          $$AlarmConfigsTableUpdateCompanionBuilder,
          (
            AlarmConfig,
            BaseReferences<_$AppDatabase, $AlarmConfigsTable, AlarmConfig>,
          ),
          AlarmConfig,
          PrefetchHooks Function()
        > {
  $$AlarmConfigsTableTableManager(_$AppDatabase db, $AlarmConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlarmConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlarmConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlarmConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> reminderId = const Value.absent(),
                Value<String?> ringtoneUri = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<bool> volumeRamp = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<int> snoozeMaxCount = const Value.absent(),
                Value<int?> preNotifyMinutes = const Value.absent(),
                Value<String?> shiftPatternJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlarmConfigsCompanion(
                reminderId: reminderId,
                ringtoneUri: ringtoneUri,
                vibrate: vibrate,
                volumeRamp: volumeRamp,
                snoozeMinutes: snoozeMinutes,
                snoozeMaxCount: snoozeMaxCount,
                preNotifyMinutes: preNotifyMinutes,
                shiftPatternJson: shiftPatternJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String reminderId,
                Value<String?> ringtoneUri = const Value.absent(),
                Value<bool> vibrate = const Value.absent(),
                Value<bool> volumeRamp = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<int> snoozeMaxCount = const Value.absent(),
                Value<int?> preNotifyMinutes = const Value.absent(),
                Value<String?> shiftPatternJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlarmConfigsCompanion.insert(
                reminderId: reminderId,
                ringtoneUri: ringtoneUri,
                vibrate: vibrate,
                volumeRamp: volumeRamp,
                snoozeMinutes: snoozeMinutes,
                snoozeMaxCount: snoozeMaxCount,
                preNotifyMinutes: preNotifyMinutes,
                shiftPatternJson: shiftPatternJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlarmConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlarmConfigsTable,
      AlarmConfig,
      $$AlarmConfigsTableFilterComposer,
      $$AlarmConfigsTableOrderingComposer,
      $$AlarmConfigsTableAnnotationComposer,
      $$AlarmConfigsTableCreateCompanionBuilder,
      $$AlarmConfigsTableUpdateCompanionBuilder,
      (
        AlarmConfig,
        BaseReferences<_$AppDatabase, $AlarmConfigsTable, AlarmConfig>,
      ),
      AlarmConfig,
      PrefetchHooks Function()
    >;
typedef $$OccurrencesTableCreateCompanionBuilder =
    OccurrencesCompanion Function({
      required String id,
      required String reminderId,
      required int scheduledAt,
      Value<String> state,
      Value<int> snoozeCount,
      Value<int?> firedAt,
      Value<bool> osScheduled,
      Value<String?> syncStatus,
      Value<String?> userId,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$OccurrencesTableUpdateCompanionBuilder =
    OccurrencesCompanion Function({
      Value<String> id,
      Value<String> reminderId,
      Value<int> scheduledAt,
      Value<String> state,
      Value<int> snoozeCount,
      Value<int?> firedAt,
      Value<bool> osScheduled,
      Value<String?> syncStatus,
      Value<String?> userId,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

class $$OccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableFilterComposer({
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

  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get osScheduled => $composableBuilder(
    column: $table.osScheduled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableOrderingComposer({
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

  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firedAt => $composableBuilder(
    column: $table.firedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get osScheduled => $composableBuilder(
    column: $table.osScheduled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OccurrencesTable> {
  $$OccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firedAt =>
      $composableBuilder(column: $table.firedAt, builder: (column) => column);

  GeneratedColumn<bool> get osScheduled => $composableBuilder(
    column: $table.osScheduled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OccurrencesTable,
          Occurrence,
          $$OccurrencesTableFilterComposer,
          $$OccurrencesTableOrderingComposer,
          $$OccurrencesTableAnnotationComposer,
          $$OccurrencesTableCreateCompanionBuilder,
          $$OccurrencesTableUpdateCompanionBuilder,
          (
            Occurrence,
            BaseReferences<_$AppDatabase, $OccurrencesTable, Occurrence>,
          ),
          Occurrence,
          PrefetchHooks Function()
        > {
  $$OccurrencesTableTableManager(_$AppDatabase db, $OccurrencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reminderId = const Value.absent(),
                Value<int> scheduledAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<int?> firedAt = const Value.absent(),
                Value<bool> osScheduled = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion(
                id: id,
                reminderId: reminderId,
                scheduledAt: scheduledAt,
                state: state,
                snoozeCount: snoozeCount,
                firedAt: firedAt,
                osScheduled: osScheduled,
                syncStatus: syncStatus,
                userId: userId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String reminderId,
                required int scheduledAt,
                Value<String> state = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<int?> firedAt = const Value.absent(),
                Value<bool> osScheduled = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OccurrencesCompanion.insert(
                id: id,
                reminderId: reminderId,
                scheduledAt: scheduledAt,
                state: state,
                snoozeCount: snoozeCount,
                firedAt: firedAt,
                osScheduled: osScheduled,
                syncStatus: syncStatus,
                userId: userId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OccurrencesTable,
      Occurrence,
      $$OccurrencesTableFilterComposer,
      $$OccurrencesTableOrderingComposer,
      $$OccurrencesTableAnnotationComposer,
      $$OccurrencesTableCreateCompanionBuilder,
      $$OccurrencesTableUpdateCompanionBuilder,
      (
        Occurrence,
        BaseReferences<_$AppDatabase, $OccurrencesTable, Occurrence>,
      ),
      Occurrence,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String id,
      required int startedAt,
      Value<int?> endedAt,
      required int targetSets,
      required int softTargetMs,
      Value<String> profile,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<int> targetSets,
      Value<int> softTargetMs,
      Value<String> profile,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
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

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get softTargetMs => $composableBuilder(
    column: $table.softTargetMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get softTargetMs => $composableBuilder(
    column: $table.softTargetMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profile => $composableBuilder(
    column: $table.profile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get softTargetMs => $composableBuilder(
    column: $table.softTargetMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profile =>
      $composableBuilder(column: $table.profile, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (
            WorkoutSessionRow,
            BaseReferences<
              _$AppDatabase,
              $WorkoutSessionsTable,
              WorkoutSessionRow
            >,
          ),
          WorkoutSessionRow,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> softTargetMs = const Value.absent(),
                Value<String> profile = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                targetSets: targetSets,
                softTargetMs: softTargetMs,
                profile: profile,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                required int targetSets,
                required int softTargetMs,
                Value<String> profile = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                targetSets: targetSets,
                softTargetMs: softTargetMs,
                profile: profile,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (
        WorkoutSessionRow,
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSessionRow>,
      ),
      WorkoutSessionRow,
      PrefetchHooks Function()
    >;
typedef $$SetRecordsTableCreateCompanionBuilder =
    SetRecordsCompanion Function({
      required String id,
      required String sessionId,
      required int setIndex,
      required int restStartMs,
      required int restEndMs,
      required int restDurationMs,
      required String cueConfigJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SetRecordsTableUpdateCompanionBuilder =
    SetRecordsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> setIndex,
      Value<int> restStartMs,
      Value<int> restEndMs,
      Value<int> restDurationMs,
      Value<String> cueConfigJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SetRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SetRecordsTable> {
  $$SetRecordsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restStartMs => $composableBuilder(
    column: $table.restStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restEndMs => $composableBuilder(
    column: $table.restEndMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cueConfigJson => $composableBuilder(
    column: $table.cueConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SetRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetRecordsTable> {
  $$SetRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restStartMs => $composableBuilder(
    column: $table.restStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restEndMs => $composableBuilder(
    column: $table.restEndMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cueConfigJson => $composableBuilder(
    column: $table.cueConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SetRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetRecordsTable> {
  $$SetRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<int> get restStartMs => $composableBuilder(
    column: $table.restStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restEndMs =>
      $composableBuilder(column: $table.restEndMs, builder: (column) => column);

  GeneratedColumn<int> get restDurationMs => $composableBuilder(
    column: $table.restDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cueConfigJson => $composableBuilder(
    column: $table.cueConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SetRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetRecordsTable,
          SetRecordRow,
          $$SetRecordsTableFilterComposer,
          $$SetRecordsTableOrderingComposer,
          $$SetRecordsTableAnnotationComposer,
          $$SetRecordsTableCreateCompanionBuilder,
          $$SetRecordsTableUpdateCompanionBuilder,
          (
            SetRecordRow,
            BaseReferences<_$AppDatabase, $SetRecordsTable, SetRecordRow>,
          ),
          SetRecordRow,
          PrefetchHooks Function()
        > {
  $$SetRecordsTableTableManager(_$AppDatabase db, $SetRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<int> restStartMs = const Value.absent(),
                Value<int> restEndMs = const Value.absent(),
                Value<int> restDurationMs = const Value.absent(),
                Value<String> cueConfigJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetRecordsCompanion(
                id: id,
                sessionId: sessionId,
                setIndex: setIndex,
                restStartMs: restStartMs,
                restEndMs: restEndMs,
                restDurationMs: restDurationMs,
                cueConfigJson: cueConfigJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int setIndex,
                required int restStartMs,
                required int restEndMs,
                required int restDurationMs,
                required String cueConfigJson,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SetRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                setIndex: setIndex,
                restStartMs: restStartMs,
                restEndMs: restEndMs,
                restDurationMs: restDurationMs,
                cueConfigJson: cueConfigJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SetRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetRecordsTable,
      SetRecordRow,
      $$SetRecordsTableFilterComposer,
      $$SetRecordsTableOrderingComposer,
      $$SetRecordsTableAnnotationComposer,
      $$SetRecordsTableCreateCompanionBuilder,
      $$SetRecordsTableUpdateCompanionBuilder,
      (
        SetRecordRow,
        BaseReferences<_$AppDatabase, $SetRecordsTable, SetRecordRow>,
      ),
      SetRecordRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$RecurrenceRulesTableTableManager get recurrenceRules =>
      $$RecurrenceRulesTableTableManager(_db, _db.recurrenceRules);
  $$AlarmConfigsTableTableManager get alarmConfigs =>
      $$AlarmConfigsTableTableManager(_db, _db.alarmConfigs);
  $$OccurrencesTableTableManager get occurrences =>
      $$OccurrencesTableTableManager(_db, _db.occurrences);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SetRecordsTableTableManager get setRecords =>
      $$SetRecordsTableTableManager(_db, _db.setRecords);
}
