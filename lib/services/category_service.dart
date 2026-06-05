import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pesaplan_new/models/category.dart';

class CategoryService {
  final String uid;
  CategoryService({required this.uid});

  // Firestore collection reference
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categories');

  // Add a new category
  Future<void> addCategory(String name) async {
    if (name.isEmpty) return;
    await categoryCollection
        .doc(uid)
        .collection('userCategories')
        .add({'name': name});
  }

  // Update an existing category
  Future<void> updateCategory(String categoryId, String newName) async {
    if (newName.isEmpty) return;
    await categoryCollection
        .doc(uid)
        .collection('userCategories')
        .doc(categoryId)
        .update({'name': newName});
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    await categoryCollection
        .doc(uid)
        .collection('userCategories')
        .doc(categoryId)
        .delete();
  }

  // Stream list of categories
  Stream<List<Category>> get categories {
    return categoryCollection
        .doc(uid)
        .collection('userCategories')
        .orderBy('name')
        .snapshots()
        .map(_categoryListFromSnapshot);
  }

  // Convert snapshot to List<Category>
  List<Category> _categoryListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Category.fromMap(data, doc.id);
    }).toList();
  }

  // Get category by name (for predictive checks or quick lookup)
  Future<Category?> getCategoryByName(String name) async {
    final snapshot = await categoryCollection
        .doc(uid)
        .collection('userCategories')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Category.fromMap(snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id);
  }
}
