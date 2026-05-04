// lib/features/lead_category/data/models/lead_category_model.dart

class LeadsModel {
  final String id;
  final String name;
  final String createdBy;
  final String idOfCreator; 
  final DateTime createdAt;

  const LeadsModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.idOfCreator,
    required this.createdAt,
  });

  factory LeadsModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return LeadsModel(
      id: docId,
      name: data['name'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      idOfCreator: data['idOfCreator'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate() as DateTime
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdBy': createdBy,
      'idOfCreator': idOfCreator,
      'createdAt': createdAt,
    };
  }

  LeadsModel copyWith({
    String? id,
    String? name,
    String? createdBy,
    String? idOfCreator,
    DateTime? createdAt,
  }) {
    return LeadsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      idOfCreator: idOfCreator ?? this.idOfCreator,
      createdAt: createdAt ?? this.createdAt,
    );
  }

 // ✅ Compare all fields, not just id
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is LeadsModel &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        name == other.name &&        // ✅ include name
        createdBy == other.createdBy; // ✅ include createdBy
        // idOfCreator == other.idOfCreator; // ✅ include idOfCreator

@override
int get hashCode => Object.hash(id, name, createdBy);
}