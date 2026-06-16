import 'package:count_to_three/features/alarm_engine/data/rrule_engine_impl.dart';
import 'package:count_to_three/features/alarm_engine/domain/rule_engine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rule_engine_provider.g.dart';

@Riverpod(keepAlive: true)
RuleEngine ruleEngine(RuleEngineRef ref) => const RruleEngineImpl();