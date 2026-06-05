import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  final String id;
  final String source;
  final double amount;
  final DateTime date;

  Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
  });

  // --------------------------------------------------
  // Convert Income → Firestore Map (Timestamp FIX)
  // --------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }

  // --------------------------------------------------
  // Convert Firestore → Income (Timestamp FIX)
  // --------------------------------------------------
  factory Income.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    return Income(
      id: doc.id,
      source: data['source'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
