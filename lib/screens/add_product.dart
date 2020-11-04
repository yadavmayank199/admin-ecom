import 'dart:io';
import 'package:ecommadminnew/db/product.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommadminnew/db/brand.dart';
import 'package:ecommadminnew/db/category.dart';
import 'package:ecommadminnew/db/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  BrandService brandService= BrandService();
  CategoryService categoryService= CategoryService();
  ProductService productService = ProductService();
  GlobalKey<FormState>_formkey=GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController productQuantityController = TextEditingController();
  final productPriceController = TextEditingController();
  List<DocumentSnapshot> brands=<DocumentSnapshot>[];
  List<DocumentSnapshot> categories=<DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =<DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown =<DropdownMenuItem<String>>[];
  String _currentCategory;
  String _currentBrand;
  Color white= Colors.white;
  Color grey= Colors.grey;
  Color black= Colors.black;
  Color red= Colors.red;
  List<String> selectedSizes =<String>[];
  File _image1;
  File _image2;
  File _image3;
  bool isLoading = false;
  @override
  void initState(){
    _getCategories();
    _getBrands();
//      getCategoriesDropDown();
//        print(categoriesDropDown.length);
    //    _currentCategory = categoriesDropDown[0].value;  
      }
     List<DropdownMenuItem<String>> getCategoriesDropDown(){
       List<DropdownMenuItem<String>> items =new List();
        for(int i=0; i < categories.length; i++){
          setState(() {
            items.insert(0, DropdownMenuItem(child: Text (categories[i].data['category']),
            value: categories[i].data['category']));
          });
        }
        return items;
      }

      List<DropdownMenuItem<String>> getBrandDropDown(){
       List<DropdownMenuItem<String>> items =new List();
        for(int i=0; i < brands.length; i++){
          setState(() {
            items.insert(0, DropdownMenuItem(child: Text (brands[i].data['brand']),
            value: brands[i].data['brand']));
          });
        }
        return items;
      }
    
    
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0.1,
            backgroundColor: white,
            leading: Icon(Icons.close,color:black),
            title: Text("add product",style: TextStyle(color:black),),
          ),
          body:Form(
            key:_formkey,
              child: SingleChildScrollView(
                child: isLoading ? CircularProgressIndicator(): Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlineButton(
                          borderSide: BorderSide(color: grey.withOpacity(0.8),width:1.0),
                          onPressed: (){
                            _selectImage(ImagePicker.pickImage(source: ImageSource.gallery),1);
                          },
                            child: _displayChild1()
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlineButton(
                          borderSide: BorderSide(color: grey.withOpacity(0.8),width:1.0),
                          onPressed: (){
                            _selectImage(ImagePicker.pickImage(source: ImageSource.gallery),2);
                          },

                          child: _displayChild2()
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlineButton(
                          borderSide: BorderSide(color: grey.withOpacity(0.8),width:1.0),
                          onPressed: (){
                            _selectImage(ImagePicker.pickImage(source: ImageSource.gallery),3);
                          },
                          child: _displayChild3()
                        ),
                      ),
                    ),
                  ],
                  ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ENTER A PRODUCT NAME WITH 10 CHARACTER AT MAXIMUM ',
                        textAlign: TextAlign.center,style: TextStyle(color: Colors.red),
                      ),
                    ),
    
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller:productNameController,
                      decoration: InputDecoration(
                        hintText: 'Product name'
                      ),
                      validator:(value){
                        if(value.isEmpty){
                        return 'you must entered the product name';
                      }else if(value.length>10){
                        return 'Product name cannot be more than 10 letter';
                      }
                      },
                    ),
                  ),
                  // select category

                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Category:', style: TextStyle(color:red),),
                        ),
                        DropdownButton(items: categoriesDropDown,onChanged: changeSelectedCategory, value: _currentCategory,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Brand:', style: TextStyle(color:red),),
                        ),
                        DropdownButton(items: brandsDropDown,onChanged: changeSelectedBrand, value: _currentBrand,),
                        
                        ],
                    ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller:productQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Quantity'
                      ),
                      validator: (value){
                        if(value.isEmpty){
                          return 'You must entered Quantity';
                        }
                      },
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller:productPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: 'Price'
                      ),

                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must entered Price';
                          }
                        },
                    ),
                  ),


                      Text('Available Sizes'),
                      Row(
                        children: <Widget>[
                        Checkbox(value: selectedSizes.contains('xS'),onChanged: (value)=> changeSelectedSize('xS'),),
                        Text('xS'),
                          Checkbox(value: selectedSizes.contains('S'),onChanged: (value)=> changeSelectedSize('S'),),
                        Text('S'),
                          Checkbox(value: selectedSizes.contains('M'),onChanged: (value)=> changeSelectedSize('M'),),
                        Text('M'),
                          Checkbox(value: selectedSizes.contains('L'),onChanged: (value)=> changeSelectedSize('L'),),
                        Text('L'),
                          Checkbox(value: selectedSizes.contains('XL'),onChanged: (value)=> changeSelectedSize('XL'),),
                        Text('XL'),
                          Checkbox(value: selectedSizes.contains('XXL'),onChanged: (value)=> changeSelectedSize('XXL'),),
                        Text('XXL'),
                      ],),

                       Row(
                        children: <Widget>[
                          Checkbox(value: selectedSizes.contains('28'),onChanged: (value)=> changeSelectedSize('28'),),
                        Text('28'),
                          Checkbox(value: selectedSizes.contains('30'),onChanged: (value)=> changeSelectedSize('30'),),
                        Text('30'),
                          Checkbox(value: selectedSizes.contains('32'),onChanged: (value)=> changeSelectedSize('32'),),
                        Text('32'),
                          Checkbox(value: selectedSizes.contains('34'),onChanged: (value)=> changeSelectedSize('34'),),
                        Text('34'),
                          Checkbox(value: selectedSizes.contains('36'),onChanged: (value)=> changeSelectedSize('36'),),
                        Text('36'),
                          Checkbox(value: selectedSizes.contains('38'),onChanged: (value)=> changeSelectedSize('38'),),
                        Text('38'),
                      ],),


                       Row(
                        children: <Widget>[
                          Checkbox(value: selectedSizes.contains('40'),onChanged: (value)=> changeSelectedSize('40'),),
                        Text('40'),
                          Checkbox(value: selectedSizes.contains('42'),onChanged: (value)=> changeSelectedSize('42'),),
                        Text('42'),
                          Checkbox(value: selectedSizes.contains('44'),onChanged: (value)=> changeSelectedSize('44'),),
                        Text('44'),
                          Checkbox(value: selectedSizes.contains('46'),onChanged: (value)=> changeSelectedSize('46'),),
                        Text('46'),
                          Checkbox(value: selectedSizes.contains('48'),onChanged: (value)=> changeSelectedSize('48'),),
                        Text('48'),
                          Checkbox(value: selectedSizes.contains('50'),onChanged: (value)=> changeSelectedSize('50'),),
                        Text('50'),
                      ],),


                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: FlatButton(
                         color: red,child: Text('Add Product'),
                         onPressed: (){
                           validateAndUpload();
                         },
                       ),
                     ),
                                   ],
                                  ),
              ),
                              ),
                            );
                          }
                        
                           _getCategories() async{
                             List<DocumentSnapshot> data = await categoryService.getCategories();
                             print(data.length);
                             setState(() {
                               categories = data;
                               categoriesDropDown = getCategoriesDropDown();
                               _currentCategory = categories[0].data['category'];
                               print(categories.length);
                             });
                           }

                    _getBrands() async{
                             List<DocumentSnapshot> data = await brandService.getBrands();
                             print(data.length);
                             setState(() {
                               brands = data;
                               brandsDropDown = getBrandDropDown();
                               _currentBrand = brands[0].data['brand'];
                               print(brands.length);
                             });
                           }
                    
                    
                    changeSelectedCategory(String selectedCategory) {
                      setState(()=> _currentCategory =selectedCategory);
                    }
                    changeSelectedBrand(String selectedBrand) {
                      setState(()=> _currentBrand =selectedBrand);
                    }

                    void changeSelectedSize( String size){
                      if(selectedSizes.contains(size)){
                        setState(() {
                          selectedSizes.remove(size);
                        });

                      }
                      else{
                        setState(() {
                          selectedSizes.insert(0,size);
                        });

                      }
                    }

  void _selectImage(Future<File> pickImage, int imageNumber) async{
    File tempImg = await pickImage;
    switch(imageNumber){
      case 1: setState(()=> _image1= tempImg);
      break;
    case 2: setState(()=> _image2= tempImg);
    break;
    case 3: setState(()=> _image3= tempImg);
    break;
    }
  }

  Widget _displayChild1() {
    if(_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 40, 14, 40),
        child: Icon(Icons.add, color: grey),
      );
    }else{
      return Image.file(_image1,fit:BoxFit.cover,width: double.infinity,);
    }
    }

  Widget _displayChild2() {
    if(_image2 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 40, 14, 40),
        child: Icon(Icons.add, color: grey),
      );
    }else{
      return Image.file(_image2,fit:BoxFit.cover,width: double.infinity,);
    }
  }

  Widget _displayChild3() {
    if(_image3 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 40, 14, 40),
        child: Icon(Icons.add, color: grey),
      );
    }else{
      return Image.file(_image3,fit:BoxFit.cover,width: double.infinity,);
    }
  }

   Future<void> validateAndUpload()  async {
    if(_formkey.currentState.validate()){
      setState(() => isLoading = true );
      if(_image1 != null && _image2 != null && _image3 != null){
        if(selectedSizes.isNotEmpty){
          String imageUrl1;
          String imageUrl2;
          String imageUrl3;
          final FirebaseStorage storage = FirebaseStorage.instance;
          final String picture1 ="1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task1 = storage.ref().child(picture1).putFile(_image1);
          final String picture2 ="2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task2 = storage.ref().child(picture2).putFile(_image2);
          final String picture3 ="3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          StorageUploadTask task3 = storage.ref().child(picture3).putFile(_image3);

          StorageTaskSnapshot snapshot1 = await task1.onComplete.then((snapshot)=> snapshot);
          StorageTaskSnapshot snapshot2 = await task2.onComplete.then((snapshot)=> snapshot);
          task3.onComplete.then((snapshot3) async{
            imageUrl1 = await snapshot1.ref.getDownloadURL();
            imageUrl2 = await snapshot2.ref.getDownloadURL();
            imageUrl3 = await snapshot3.ref.getDownloadURL();
            List<String> imageList =[imageUrl1,imageUrl2,imageUrl3];

            productService.uploadProduct(
              productName: productNameController.text,
              price: double.parse(productPriceController.text),
              sizes: selectedSizes,
              images: imageList,
              Quantity: int.parse(productQuantityController.text));
              _formkey.currentState.reset();
              setState(() => isLoading = false);
              Fluttertoast.showToast(msg: 'Product Added');
              Navigator.pop(context);
          });
        }else {
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: 'select atleast one size');
        }
      }else{
        setState(() => isLoading = false);
        Fluttertoast.showToast(msg: 'all images must be provided');
      }
    }
  }
  }

