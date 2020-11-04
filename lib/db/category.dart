import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CategoryService{
  Firestore _firestore = Firestore.instance;
  String ref= 'categories';
  void createCategory(String name){
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection(ref).document(brandId).setData({'category': name});
  }
  Future<List<DocumentSnapshot>> getCategories() =>
    _firestore.collection(ref).getDocuments().then((snaps){
     return snaps.documents;
    });
  

  Future <List<DocumentSnapshot>> getSuggestions (String suggestion)=>
    _firestore.collection(ref).where('category',isEqualTo: suggestion).getDocuments().then((snap){
      return snap.documents;
    });
  
}