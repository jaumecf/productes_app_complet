import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:productes_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      "flutter-dev-a6fa0-default-rtdb.europe-west1.firebasedatabase.app";
  final List<Product> products = [];
  late Product selectedProduct;

  bool isLoading = true;
  bool isSaving = false;

  File? newPictureFile;

  //TODO: fetch dels productes

  ProductsService() {
    this.loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    this.isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
    final response = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(response.body);

    //print(productsMap);

    // Mapejam la resposta del servidor, per cada producte, el convertim a la classe i l'afegim a la llista
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      this.products.add(tempProduct);
    });
    //print(products[0].name);

    this.isLoading = false;
    notifyListeners();
    return this.products;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      //Cream el producte
      await this.createProduct(product);
    } else {
      //Actualitzam un producte
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final response = await http.put(url, body: product.toJson());
    final decodedData = response.body;
    //print(decodedData);

    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;
    //Sense aquest noti, no funciona correctament
    //notifyListeners();
    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final response = await http.post(url, body: product.toJson());
    final decodedData = json.decode(response.body);
    print(decodedData);
    product.id = decodedData['name'];

    // Falta posar ID del producte
    this.products.add(product);
    return product.id!;
  }

  void updateSelectedProductImage(String path) async {
    this.selectedProduct.picture = path;
    this.newPictureFile = new File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    //Upload to Cloudinary
    if (this.newPictureFile == null) return null;

    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/cifp-pau-casesnoves/image/upload?upload_preset=hn0p8z0z');
    final imageUploadRequest = await http.MultipartRequest('POST', url);
    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Hi ha hagut algun error');
      print(response.body);
      return null;
    }

    final decodedData = json.decode(response.body);
    return decodedData['secure_url'];
  }
}
