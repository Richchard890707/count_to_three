// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alarmEventsHash() => r'31a6d9c003468f7ac0ee8c418fd7663bf4630433';

/// See also [alarmEvents].
@ProviderFor(alarmEvents)
final alarmEventsProvider =
    AutoDisposeStreamProvider<AlarmEngineEvent>.internal(
      alarmEvents,
      name: r'alarmEventsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alarmEventsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlarmEventsRef = AutoDisposeStreamProviderRef<AlarmEngineEvent>;
String _$alarmListSelectionHash() =>
    r'ed5ef725e8232ee358198228587c0de19acb20bf';

/// See also [AlarmListSelection].
@ProviderFor(AlarmListSelection)
final alarmListSelectionProvider =
    AutoDisposeNotifierProvider<
      AlarmListSelection,
      AlarmListSelectionState
    >.internal(
      AlarmListSelection.new,
      name: r'alarmListSelectionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alarmListSelectionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlarmListSelection = AutoDisposeNotifier<AlarmListSelectionState>;
String _$alarmFilterHash() => r'e07346c4a80d0302a08498d03e2fe56b08453d90';

/// See also [AlarmFilter].
@ProviderFor(AlarmFilter)
final alarmFilterProvider =
    AutoDisposeNotifierProvider<AlarmFilter, AlarmListFilterState>.internal(
      AlarmFilter.new,
      name: r'alarmFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alarmFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlarmFilter = AutoDisposeNotifier<AlarmListFilterState>;
String _$selectedReminderTypeHash() =>
    r'de613066cdbf10454dea87dcb0e21a3b9ba91a4e';

/// See also [SelectedReminderType].
@ProviderFor(SelectedReminderType)
final selectedReminderTypeProvider =
    AutoDisposeNotifierProvider<SelectedReminderType, ReminderType>.internal(
      SelectedReminderType.new,
      name: r'selectedReminderTypeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedReminderTypeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedReminderType = AutoDisposeNotifier<ReminderType>;
String _$selectedAlertLevelHash() =>
    r'2dff5395d5795de78691a05083f28c8c2393cc37';

/// See also [SelectedAlertLevel].
@ProviderFor(SelectedAlertLevel)
final selectedAlertLevelProvider =
    AutoDisposeNotifierProvider<SelectedAlertLevel, AlertLevel>.internal(
      SelectedAlertLevel.new,
      name: r'selectedAlertLevelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedAlertLevelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedAlertLevel = AutoDisposeNotifier<AlertLevel>;
String _$selectedFreqHash() => r'8c4bb22cb343b20af244405e20564ca8a382c6be';

/// See also [SelectedFreq].
@ProviderFor(SelectedFreq)
final selectedFreqProvider =
    AutoDisposeNotifierProvider<SelectedFreq, RecurrenceFreq>.internal(
      SelectedFreq.new,
      name: r'selectedFreqProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedFreqHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedFreq = AutoDisposeNotifier<RecurrenceFreq>;
String _$alarmListControllerHash() =>
    r'5eb605da2a2c07afeeea829d1fd5582c02325cb2';

/// See also [AlarmListController].
@ProviderFor(AlarmListController)
final alarmListControllerProvider =
    AutoDisposeStreamNotifierProvider<
      AlarmListController,
      List<Reminder>
    >.internal(
      AlarmListController.new,
      name: r'alarmListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alarmListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AlarmListController = AutoDisposeStreamNotifier<List<Reminder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
