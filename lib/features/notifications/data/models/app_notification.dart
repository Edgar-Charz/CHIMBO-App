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
    this.translations = const {},
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
      translations: _readTranslations(data),
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

  /// Optional server-provided copies keyed by language code, kept in notification_data.
  final Map<String, Map<String, String>> translations;

  String titleFor(String languageCode) =>
      translations[languageCode]?['title'] ?? title;

  String bodyFor(String languageCode) =>
      translations[languageCode]?['body'] ?? body;

  /// Reads localized notification copy from either an API item or an FCM data payload.
  static String localizedPushText({
    required Map<String, dynamic> data,
    required String languageCode,
    required String field,
    required String fallback,
  }) {
    final rawData = data['notification_data'];
    final notificationData = _decodeData(rawData);
    final translations = _readTranslations(notificationData ?? data);
    return translations[languageCode]?[field] ?? fallback;
  }

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
      translations: translations,
    );
  }

  static Map<String, dynamic>? _decodeData(Object? rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    if (rawData is! String || rawData.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      return null;
    }
    return null;
  }

  static Map<String, Map<String, String>> _readTranslations(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return const {};
    final translations = <String, Map<String, String>>{};
    final rawTranslations =
        data['translations'] ?? data['notification_translations'];
    if (rawTranslations is Map) {
      for (final entry in rawTranslations.entries) {
        if (entry.value is! Map) continue;
        final copy = Map<String, dynamic>.from(entry.value as Map);
        final title = copy['title']?.toString();
        final body = copy['body']?.toString();
        translations[entry.key.toString()] = {
          if (title != null && title.isNotEmpty) 'title': title,
          if (body != null && body.isNotEmpty) 'body': body,
        };
      }
    }
    for (final languageCode in ['en', 'sw']) {
      final title = data['notification_title_$languageCode']?.toString();
      final body = data['notification_body_$languageCode']?.toString();
      if (title != null || body != null) {
        translations[languageCode] = {
          ...?translations[languageCode],
          if (title != null && title.isNotEmpty) 'title': title,
          if (body != null && body.isNotEmpty) 'body': body,
        };
      }
    }
    return translations;
  }
}
