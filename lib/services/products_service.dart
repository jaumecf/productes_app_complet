import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:productes_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      "flutter-dev-a6fa0-default-rtdb.europe-west1.firebasedatabase.app";
  final List<Product> products = [];

  bool isLoading = true;

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
}
