import 'dart:convert';

class Ward {
  String? id;
  String? name;
  String? level;
  String? provinceId;
  String? districtId;
  Ward({
    this.id,
    this.name,
    this.level,
    this.provinceId,
    this.districtId,
  });

  Ward copyWith({
    String? id,
    String? name,
    String? level,
    String? provinceId,
    String? districtId,
  }) {
    return Ward(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      provinceId: provinceId ?? this.provinceId,
      districtId: districtId ?? this.districtId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'level': level,
      'provinceId': provinceId,
      'districtId': districtId,
    };
  }

  factory Ward.fromMap(Map<String, dynamic> map) {
    return Ward(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      level: map['level'] != null ? map['level'] as String : null,
      provinceId:
          map['provinceId'] != null ? map['provinceId'] as String : null,
      districtId:
          map['districtId'] != null ? map['districtId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Ward.fromJson(String source) =>
      Ward.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Ward(id: $id, name: $name, level: $level, provinceId: $provinceId, districtId: $districtId)';
  }

  @override
  bool operator ==(covariant Ward other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.level == level &&
        other.provinceId == provinceId &&
        other.districtId == districtId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        level.hashCode ^
        provinceId.hashCode ^
        districtId.hashCode;
  }
}
