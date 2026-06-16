class NotificationRequest {
  const NotificationRequest({
    required this.id,
    required this.reminderId,
    required this.title,
    this.body,
    required this.triggerAt,
  });

  final int id;
  final String reminderId;
  final String title;
  final String? body;
  final DateTime triggerAt;
}
