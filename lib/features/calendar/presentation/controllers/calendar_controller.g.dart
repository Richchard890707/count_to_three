// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarControllerHash() =>
    r'994f798e1061691da1cb35f4ba74db48bc095c06';

/// See also [calendarController].
@ProviderFor(calendarController)
final calendarControllerProvider =
    AutoDisposeFutureProvider<Map<DateTime, List<CalendarEvent>>>.internal(
      calendarController,
      name: r'calendarControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calendarControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarControllerRef =
    AutoDisposeFutureProviderRef<Map<DateTime, List<CalendarEvent>>>;
String _$calendarFocusedDayHash() =>
    r'68675c30697b70e5af2029097d53499320677f51';

/// See also [CalendarFocusedDay].
@ProviderFor(CalendarFocusedDay)
final calendarFocusedDayProvider =
    AutoDisposeNotifierProvider<CalendarFocusedDay, DateTime>.internal(
      CalendarFocusedDay.new,
      name: r'calendarFocusedDayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calendarFocusedDayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CalendarFocusedDay = AutoDisposeNotifier<DateTime>;
String _$calendarSelectedDayHash() =>
    r'00aa6eb61dafb55a9d296197f4e7eef3ea25ba29';

/// See also [CalendarSelectedDay].
@ProviderFor(CalendarSelectedDay)
final calendarSelectedDayProvider =
    AutoDisposeNotifierProvider<CalendarSelectedDay, DateTime>.internal(
      CalendarSelectedDay.new,
      name: r'calendarSelectedDayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calendarSelectedDayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CalendarSelectedDay = AutoDisposeNotifier<DateTime>;
String _$calendarViewModeHash() => r'41b8947507dfc0723be5ac3e3daef591b9f07fab';

/// See also [CalendarViewMode].
@ProviderFor(CalendarViewMode)
final calendarViewModeProvider =
    AutoDisposeNotifierProvider<CalendarViewMode, CalViewMode>.internal(
      CalendarViewMode.new,
      name: r'calendarViewModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$calendarViewModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CalendarViewMode = AutoDisposeNotifier<CalViewMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
