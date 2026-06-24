// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_list_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recurrenceRuleHash() => r'738534c621dbc1f990b7b7d270cbb807c69570ad';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [recurrenceRule].
@ProviderFor(recurrenceRule)
const recurrenceRuleProvider = RecurrenceRuleFamily();

/// See also [recurrenceRule].
class RecurrenceRuleFamily extends Family<AsyncValue<RecurrenceRule?>> {
  /// See also [recurrenceRule].
  const RecurrenceRuleFamily();

  /// See also [recurrenceRule].
  RecurrenceRuleProvider call(String? ruleId) {
    return RecurrenceRuleProvider(ruleId);
  }

  @override
  RecurrenceRuleProvider getProviderOverride(
    covariant RecurrenceRuleProvider provider,
  ) {
    return call(provider.ruleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recurrenceRuleProvider';
}

/// See also [recurrenceRule].
class RecurrenceRuleProvider
    extends AutoDisposeFutureProvider<RecurrenceRule?> {
  /// See also [recurrenceRule].
  RecurrenceRuleProvider(String? ruleId)
    : this._internal(
        (ref) => recurrenceRule(ref as RecurrenceRuleRef, ruleId),
        from: recurrenceRuleProvider,
        name: r'recurrenceRuleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recurrenceRuleHash,
        dependencies: RecurrenceRuleFamily._dependencies,
        allTransitiveDependencies:
            RecurrenceRuleFamily._allTransitiveDependencies,
        ruleId: ruleId,
      );

  RecurrenceRuleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ruleId,
  }) : super.internal();

  final String? ruleId;

  @override
  Override overrideWith(
    FutureOr<RecurrenceRule?> Function(RecurrenceRuleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecurrenceRuleProvider._internal(
        (ref) => create(ref as RecurrenceRuleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ruleId: ruleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RecurrenceRule?> createElement() {
    return _RecurrenceRuleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecurrenceRuleProvider && other.ruleId == ruleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ruleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecurrenceRuleRef on AutoDisposeFutureProviderRef<RecurrenceRule?> {
  /// The parameter `ruleId` of this provider.
  String? get ruleId;
}

class _RecurrenceRuleProviderElement
    extends AutoDisposeFutureProviderElement<RecurrenceRule?>
    with RecurrenceRuleRef {
  _RecurrenceRuleProviderElement(super.provider);

  @override
  String? get ruleId => (origin as RecurrenceRuleProvider).ruleId;
}

String _$recentOccurrencesHash() => r'24783ce65cf1629eb02b32bd86e0922caf8f4ae6';

/// See also [recentOccurrences].
@ProviderFor(recentOccurrences)
const recentOccurrencesProvider = RecentOccurrencesFamily();

/// See also [recentOccurrences].
class RecentOccurrencesFamily extends Family<AsyncValue<List<Occurrence>>> {
  /// See also [recentOccurrences].
  const RecentOccurrencesFamily();

  /// See also [recentOccurrences].
  RecentOccurrencesProvider call(String reminderId) {
    return RecentOccurrencesProvider(reminderId);
  }

  @override
  RecentOccurrencesProvider getProviderOverride(
    covariant RecentOccurrencesProvider provider,
  ) {
    return call(provider.reminderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentOccurrencesProvider';
}

/// See also [recentOccurrences].
class RecentOccurrencesProvider
    extends AutoDisposeFutureProvider<List<Occurrence>> {
  /// See also [recentOccurrences].
  RecentOccurrencesProvider(String reminderId)
    : this._internal(
        (ref) => recentOccurrences(ref as RecentOccurrencesRef, reminderId),
        from: recentOccurrencesProvider,
        name: r'recentOccurrencesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentOccurrencesHash,
        dependencies: RecentOccurrencesFamily._dependencies,
        allTransitiveDependencies:
            RecentOccurrencesFamily._allTransitiveDependencies,
        reminderId: reminderId,
      );

  RecentOccurrencesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reminderId,
  }) : super.internal();

  final String reminderId;

  @override
  Override overrideWith(
    FutureOr<List<Occurrence>> Function(RecentOccurrencesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentOccurrencesProvider._internal(
        (ref) => create(ref as RecentOccurrencesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reminderId: reminderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Occurrence>> createElement() {
    return _RecentOccurrencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentOccurrencesProvider && other.reminderId == reminderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reminderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentOccurrencesRef on AutoDisposeFutureProviderRef<List<Occurrence>> {
  /// The parameter `reminderId` of this provider.
  String get reminderId;
}

class _RecentOccurrencesProviderElement
    extends AutoDisposeFutureProviderElement<List<Occurrence>>
    with RecentOccurrencesRef {
  _RecentOccurrencesProviderElement(super.provider);

  @override
  String get reminderId => (origin as RecentOccurrencesProvider).reminderId;
}

String _$nextOccurrenceHash() => r'b57400e70d0d1b536b06f4e7d644474b9c3dc318';

/// Streams the next pending occurrence for a reminder so the card can
/// display the correct upcoming fire time instead of the original startAt.
///
/// Copied from [nextOccurrence].
@ProviderFor(nextOccurrence)
const nextOccurrenceProvider = NextOccurrenceFamily();

/// Streams the next pending occurrence for a reminder so the card can
/// display the correct upcoming fire time instead of the original startAt.
///
/// Copied from [nextOccurrence].
class NextOccurrenceFamily extends Family<AsyncValue<Occurrence?>> {
  /// Streams the next pending occurrence for a reminder so the card can
  /// display the correct upcoming fire time instead of the original startAt.
  ///
  /// Copied from [nextOccurrence].
  const NextOccurrenceFamily();

  /// Streams the next pending occurrence for a reminder so the card can
  /// display the correct upcoming fire time instead of the original startAt.
  ///
  /// Copied from [nextOccurrence].
  NextOccurrenceProvider call(String reminderId) {
    return NextOccurrenceProvider(reminderId);
  }

  @override
  NextOccurrenceProvider getProviderOverride(
    covariant NextOccurrenceProvider provider,
  ) {
    return call(provider.reminderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'nextOccurrenceProvider';
}

/// Streams the next pending occurrence for a reminder so the card can
/// display the correct upcoming fire time instead of the original startAt.
///
/// Copied from [nextOccurrence].
class NextOccurrenceProvider extends AutoDisposeStreamProvider<Occurrence?> {
  /// Streams the next pending occurrence for a reminder so the card can
  /// display the correct upcoming fire time instead of the original startAt.
  ///
  /// Copied from [nextOccurrence].
  NextOccurrenceProvider(String reminderId)
    : this._internal(
        (ref) => nextOccurrence(ref as NextOccurrenceRef, reminderId),
        from: nextOccurrenceProvider,
        name: r'nextOccurrenceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$nextOccurrenceHash,
        dependencies: NextOccurrenceFamily._dependencies,
        allTransitiveDependencies:
            NextOccurrenceFamily._allTransitiveDependencies,
        reminderId: reminderId,
      );

  NextOccurrenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reminderId,
  }) : super.internal();

  final String reminderId;

  @override
  Override overrideWith(
    Stream<Occurrence?> Function(NextOccurrenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NextOccurrenceProvider._internal(
        (ref) => create(ref as NextOccurrenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reminderId: reminderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Occurrence?> createElement() {
    return _NextOccurrenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NextOccurrenceProvider && other.reminderId == reminderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reminderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NextOccurrenceRef on AutoDisposeStreamProviderRef<Occurrence?> {
  /// The parameter `reminderId` of this provider.
  String get reminderId;
}

class _NextOccurrenceProviderElement
    extends AutoDisposeStreamProviderElement<Occurrence?>
    with NextOccurrenceRef {
  _NextOccurrenceProviderElement(super.provider);

  @override
  String get reminderId => (origin as NextOccurrenceProvider).reminderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
