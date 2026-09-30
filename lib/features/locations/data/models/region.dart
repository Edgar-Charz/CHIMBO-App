/// A Tanzanian region (Mkoa). JSON keys are the `regions` table columns.
class Region {
  const Region({required this.id, required this.name});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['region_id'] as int,
      name: json['region_name'] as String,
    );
  }

  final int id;
  final String name;

  Map<String, dynamic> toJson() => {'region_id': id, 'region_name': name};

  // Equality by id, so a dropdown keeps its selection when the list is loaded again.
  @override
  bool operator ==(Object other) => other is Region && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
