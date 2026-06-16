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
    r'fa67810886e623c769922ce6c3a0a24e4f360b50';

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
