// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statsControllerHash() => r'a313ce68b334c294840e456e0f6c5174200d33ae';

/// See also [statsController].
@ProviderFor(statsController)
final statsControllerProvider = AutoDisposeFutureProvider<StatsData>.internal(
  statsController,
  name: r'statsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatsControllerRef = AutoDisposeFutureProviderRef<StatsData>;
String _$todayOccurrencesHash() => r'86a6befb796427a6ba8579b261247813ff61d3d5';

/// Stream of all occurrences for today, ordered chronologically.
///
/// Copied from [todayOccurrences].
@ProviderFor(todayOccurrences)
final todayOccurrencesProvider =
    AutoDisposeStreamProvider<List<Occurrence>>.internal(
      todayOccurrences,
      name: r'todayOccurrencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayOccurrencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayOccurrencesRef = AutoDisposeStreamProviderRef<List<Occurrence>>;
String _$reminderTitleMapHash() => r'754e818ea2352fa04c413bd0a7da33d434eca04b';

/// Map of reminderId → reminder title for all reminders.
///
/// Copied from [reminderTitleMap].
@ProviderFor(reminderTitleMap)
final reminderTitleMapProvider =
    AutoDisposeStreamProvider<Map<String, String>>.internal(
      reminderTitleMap,
      name: r'reminderTitleMapProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reminderTitleMapHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReminderTitleMapRef = AutoDisposeStreamProviderRef<Map<String, String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
