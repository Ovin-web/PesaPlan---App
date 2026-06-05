import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String category;
  final double amount;
  final DateTime createdAt;
  final String? note;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    DateTime? createdAt,
    this.note,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory to create Budget from Firestore map
  factory Budget.fromMap(Map<String, dynamic> map, String id) {
    return Budget(
      id: id,
      category: map['category'] ?? '',
      amount: (map['amount']?.toDouble() ?? 0.0),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      note: map['note'],
    );
  }

  // Convert Budget to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'createdAt': createdAt,
      if (note != null) 'note': note,
    };
  }

  // CopyWith for immutability & updates
  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? createdAt,
    String? note,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }
}
