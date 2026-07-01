/// The actual rest taken before a given set — the data a fixed countdown
/// timer can never capture, and the seed of this product's differentiation.
///
/// [setIndex] is 1-based (rest before set 2 has setIndex 2).
class RestRecord {
  const RestRecord({
    required this.setIndex,
    required this.actualRest,
    required this.softTarget,
  });

  final int setIndex;
  final Duration actualRest;
  final Duration softTarget;

  /// User rested past the soft target — i.e. took the flexibility.
  bool get overTarget => actualRest > softTarget;
}
