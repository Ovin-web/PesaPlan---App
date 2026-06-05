import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? colorHex; // For gamified dashboard colors
  final String? note; // Optional notes for predictive suggestions

  Category({
    required this.id,
    required this.name,
    DateTime? createdAt,
    this.colorHex,
    this.note,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create Category from Firestore snapshot
  factory Category.fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      colorHex: map['colorHex'],
      note: map['note'],
    );
  }

  // Convert Category to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt,
      if (colorHex != null) 'colorHex': colorHex,
      if (note != null) 'note': note,
    };
  }

  // CopyWith for immutability & updates
  Category copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? colorHex,
    String? note,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      colorHex: colorHex ?? this.colorHex,
      note: note ?? this.note,
    );
  }
}
