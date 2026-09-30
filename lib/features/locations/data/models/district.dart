/// A district (Wilaya) inside a region. JSON keys are the `districts` table columns.
class District {
  const District({
    required this.id,
    required this.regionId,
    required this.name,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['district_id'] as int,
      regionId: json['region_id'] as int,
      name: json['district_name'] as String,
    );
  }

  final int id;
  final int regionId;
  final String name;

  Map<String, dynamic> toJson() => {
    'district_id': id,
    'region_id': regionId,
    'district_name': name,
  };

  // Equality by id, so a dropdown keeps its selection when the list is loaded again.
  @override
  bool operator ==(Object other) => other is District && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
