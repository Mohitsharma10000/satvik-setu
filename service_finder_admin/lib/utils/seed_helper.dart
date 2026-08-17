import 'package:cloud_firestore/cloud_firestore.dart';

class SeedHelper {
  static Future<void> seedDefaultCategories(FirebaseFirestore firestore) async {
    final categoriesCollection = firestore.collection('categories');
    final subcategoriesCollection = firestore.collection('subcategories');

    final defaultCategories = [
      {'name': 'Electrician', 'icon': 'electrical_services', 'order': 1, 'isActive': true},
      {'name': 'Plumber', 'icon': 'plumbing', 'order': 2, 'isActive': true},
      {'name': 'Mechanic', 'icon': 'build', 'order': 3, 'isActive': true},
      {'name': 'Carpenter', 'icon': 'construction', 'order': 4, 'isActive': true},
      {'name': 'Painter', 'icon': 'format_paint', 'order': 5, 'isActive': true},
      {'name': 'AC Repair', 'icon': 'ac_unit', 'order': 6, 'isActive': true},
      {'name': 'RO Service', 'icon': 'water_drop', 'order': 7, 'isActive': true},
      {'name': 'Refrigerator Repair', 'icon': 'kitchen', 'order': 8, 'isActive': true},
      {'name': 'Washing Machine Repair', 'icon': 'local_laundry_service', 'order': 9, 'isActive': true},
      {'name': 'TV Repair', 'icon': 'tv', 'order': 10, 'isActive': true},
      {'name': 'Mobile Repair', 'icon': 'smartphone', 'order': 11, 'isActive': true},
      {'name': 'Laptop Repair', 'icon': 'laptop', 'order': 12, 'isActive': true},
      {'name': 'CCTV Installation', 'icon': 'videocam', 'order': 13, 'isActive': true},
      {'name': 'Driver', 'icon': 'directions_car', 'order': 14, 'isActive': true},
      {'name': 'Gardener', 'icon': 'grass', 'order': 15, 'isActive': true},
      {'name': 'House Cleaning', 'icon': 'cleaning_services', 'order': 16, 'isActive': true},
      {'name': 'Pest Control', 'icon': 'bug_report', 'order': 17, 'isActive': true},
      {'name': 'Mason', 'icon': 'foundation', 'order': 18, 'isActive': true},
      {'name': 'Welder', 'icon': 'precision_manufacturing', 'order': 19, 'isActive': true},
      {'name': 'Internet Technician', 'icon': 'wifi', 'order': 20, 'isActive': true},
      {'name': 'Computer Repair', 'icon': 'desktop_windows', 'order': 21, 'isActive': true},
      {'name': 'Rent of houses', 'icon': 'house', 'order': 22, 'isActive': true},
      {'name': 'Home Tuitions', 'icon': 'school', 'order': 23, 'isActive': true},
    ];

    for (var catData in defaultCategories) {
      final docRef = await categoriesCollection.add({
        'name': catData['name'],
        'icon': catData['icon'],
        'order': catData['order'],
        'isActive': catData['isActive'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add sample subcategories for top categories
      final catName = catData['name'] as String;
      if (catName == 'Electrician') {
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'House Wiring', 'order': 1, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Fan Installation', 'order': 2, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Switch Board Repair', 'order': 3, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'MCB & Fuse Repair', 'order': 4, 'isActive': true});
      } else if (catName == 'Plumber') {
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Pipe Fitting & Leakage', 'order': 1, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Tap & Mixer Repair', 'order': 2, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Water Tank Cleaning', 'order': 3, 'isActive': true});
      } else if (catName == 'AC Repair') {
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'AC Servicing', 'order': 1, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'AC Gas Refilling', 'order': 2, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'AC Installation', 'order': 3, 'isActive': true});
      } else if (catName == 'Rent of houses') {
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': '1 BHK House for Rent', 'order': 1, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': '2 BHK House for Rent', 'order': 2, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': '3 BHK / Independent House', 'order': 3, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Commercial / Shop Space', 'order': 4, 'isActive': true});
      } else if (catName == 'Home Tuitions') {
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Class 1 to 5 (All Subjects)', 'order': 1, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Class 6 to 10 (Maths & Science)', 'order': 2, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Class 11 & 12 (Physics/Chemistry/Maths)', 'order': 3, 'isActive': true});
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': 'Competitive Exam Coaching', 'order': 4, 'isActive': true});
      } else {
        await subcategoriesCollection.add({'categoryId': docRef.id, 'name': '$catName General Repair', 'order': 1, 'isActive': true});
      }
    }
  }
}
