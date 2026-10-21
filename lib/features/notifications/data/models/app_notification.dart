import 'dart:convert';

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
    this.productId,
    this.categoryId,
    this.collection,
    this.target,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['notification_data'];
    Map<String, dynamic>? data;
    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    final title = json['notification_title'] as String;
    final body = json['notification_body'] as String;

    return AppNotification(
      id: json['notification_id'] as int,
      type: NotificationType.fromApi(json['notification_type'] as String),
      title: title,
      body: body,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      orderId: data?['order_id'] != null
          ? int.tryParse(data!['order_id'].toString())
          : null,
      productId: data?['product_id'] != null
          ? int.tryParse(data!['product_id'].toString())
          : null,
      categoryId: data?['category_id'] != null
          ? int.tryParse(data!['category_id'].toString())
          : null,
      collection: data?['collection']?.toString(),
      target: data?['target']?.toString() ?? data?['screen']?.toString(),
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

  /// The product it is about (`notification_data.product_id`); tapping opens it.
  final int? productId;

  /// The category it is about (`notification_data.category_id`); tapping opens it.
  final int? categoryId;

  /// The collection it is about (e.g. 'deals'); tapping opens Gundua with that collection.
  final String? collection;

  /// Explicit navigation target (e.g. 'wishlist').
  final String? target;

  /// Whether this notification relates to the customer's saved favourites (Vipendwa).
  bool get isWishlist =>
      target == 'wishlist' ||
      target == 'vipendwa' ||
      title.toLowerCase().contains('vipendwa') ||
      body.toLowerCase().contains('vipendwa');

  AppNotification copyWith({
    bool? isRead,
    int? orderId,
    int? productId,
    int? categoryId,
    String? collection,
    String? target,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      collection: collection ?? this.collection,
      target: target ?? this.target,
    );
  }
}

