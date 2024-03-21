import 'dart:convert';

class District {
  String? id;
  String? name;
  String? level;
  String? provinceId;
  District({
    this.id,
    this.name,
    this.level,
    this.provinceId,
  });

  District copyWith({
    String? id,
    String? name,
    String? level,
    String? provinceId,
  }) {
    return District(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      provinceId: provinceId ?? this.provinceId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'level': level,
      'provinceId': provinceId,
    };
  }

  factory District.fromMap(Map<String, dynamic> map) {
    return District(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      level: map['level'] != null ? map['level'] as String : null,
      provinceId:
          map['provinceId'] != null ? map['provinceId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory District.fromJson(String source) =>
      District.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'District(id: $id, name: $name, level: $level, provinceId: $provinceId)';
  }

  @override
  bool operator ==(covariant District other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.level == level &&
        other.provinceId == provinceId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ level.hashCode ^ provinceId.hashCode;
  }
}
