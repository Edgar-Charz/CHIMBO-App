/// Reply of `GET /health`: is the API up and can it reach the database?
class HealthStatus {
  const HealthStatus({
    required this.status,
    required this.app,
    required this.version,
    required this.database,
    required this.time,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String,
      app: json['app'] as String,
      version: json['version'] as String,
      database: json['database'] as String,
      time: DateTime.parse(json['time'] as String),
    );
  }

  static const String ok = 'ok';

  final String status;
  final String app;
  final String version;
  final String database;
  final DateTime time;

  bool get isServerOk => status == ok;
  bool get isDatabaseOk => database == ok;
}
