import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isRecurring;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.isRecurring = false,
  });

  // --------------------------------------------------
  // Convert Expense → Firestore Map (SAFE)
  // --------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
    };
  }

  // --------------------------------------------------
  // Convert Firestore → Expense (🔥 VERY IMPORTANT FIX)
  // --------------------------------------------------
  factory Expense.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      // ❗ Never crash app or AI
      return Expense(
        id: doc.id,
        title: '',
        category: 'General',
        amount: 0.0,
        date: DateTime.now(),
        isRecurring: false,
      );
    }

    // ✅ SAFELY parse amount
    final rawAmount = data['amount'];
    final double amount =
    rawAmount is num ? rawAmount.toDouble() : 0.0;

    // ✅ SAFELY parse date (THIS FIXES YOUR CRASH)
    DateTime date;
    final rawDate = data['date'];

    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    } else {
      date = DateTime.now();
    }

    return Expense(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      category: data['category']?.toString() ?? 'General',
      amount: amount,
      date: date,
      isRecurring: data['isRecurring'] == true,
    );
  }
}
