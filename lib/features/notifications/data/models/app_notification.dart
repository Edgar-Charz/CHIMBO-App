/// What a notification is about (`notification_type`); decides its icon.
enum NotificationType {
  orderStatus('order_status'),
  payment('payment'),
  promo('promo'),
  system('system');

  const NotificationType(this.apiValue);

  final String apiValue;

  /// A type added on the server later is shown like a system message.
  static NotificationType fromApi(String value) =>
      values.firstWhere((type) => type.apiValue == value, orElse: () => system);
}

/// One message under the bell ("Oda #CHB765068 imetumwa").
///
/// Named `AppNotification` because Flutter already has a `Notification` class.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.orderId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['notification_data'] as Map<String, dynamic>?;
    return AppNotification(
      id: json['notification_id'] as int,
      type: NotificationType.fromApi(json['notification_type'] as String),
      title: json['notification_title'] as String,
      body: json['notification_body'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      orderId: data?['order_id'] as int?,
    );
  }

  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  /// The order it is about (`notification_data.order_id`); tapping opens it.
  final int? orderId;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      orderId: orderId,
    );
  }
}
