import 'package:flutter/material.dart';
import 'package:productes_app/screens/screens.dart';
import 'package:productes_app/services/products_service.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Llegim el prodiver per a que s'executi el contructor per primer cop

    final productService = Provider.of<ProductsService>(context);

    if (productService.isLoading) return LoadingScreen();
    return Scaffold(
      appBar: AppBar(
        title: Text('Productes'),
      ),
      body: ListView.builder(
        itemCount: productService.products.length,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
          child: ProductCard(
            product: productService.products[index],
          ),
          onTap: () {
            productService.selectedProduct =
                productService.products[index].copy();
            Navigator.of(context).pushNamed('product');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          productService.selectedProduct =
              new Product(available: true, name: '', price: 0);
          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}
