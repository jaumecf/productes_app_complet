import 'package:flutter/material.dart';

import '../models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  Product tempProduct;

  // Contructor per rebre el producte temporal que hi ha al formulari
  ProductFormProvider(this.tempProduct);

  bool isValidForm() {
    print(tempProduct.name);
    print(tempProduct.price);
    print(tempProduct.available);
    return formKey.currentState?.validate() ?? false;
  }

  updateAvailability(bool value) {
    print(value);
    this.tempProduct.available = value;
    notifyListeners();
  }
}
