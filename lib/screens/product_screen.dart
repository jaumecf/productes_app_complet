import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:productes_app/providers/providers.dart';
import 'package:productes_app/services/products_service.dart';
import 'package:productes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../ui/input_decorations.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);

    //  Hem extret el Widget Scaffold, convertint-lo en un "body"
    // per poder utilitzar el provider del form al llarg de tots els arbres de widgets que pegen
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productsService.selectedProduct),
      child: ProductScreenBody(productsService: productsService),
    );
  }
}

class ProductScreenBody extends StatelessWidget {
  const ProductScreenBody({
    Key? key,
    required this.productsService,
  }) : super(key: key);

  final ProductsService productsService;

  @override
  Widget build(BuildContext context) {
    final productForm =
        Provider.of<ProductFormProvider>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        // Aquesta opció, és per tancar el teclat quan es faci scroll o els polsi qualsevol lloc
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(url: productsService.selectedProduct.picture),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      //TODO: Implementar funcionalitat de cercar imatge de la galeria
                      final ImagePicker _picker = ImagePicker();
                      // Pick an image
                      //final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      // Capture a photo
                      final XFile? photo = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 100,
                      );
                      if (photo == null) {
                        print('No tenim imatge');
                      } else {
                        print('Tenim imatge ${photo.path}');
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            _ProductForm(),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save_outlined),
          onPressed: (() async {
            //TODO: Emmagatzemar producte
            if (!productForm.isValidForm()) return;
            await productsService.saveOrCreateProduct(productForm.tempProduct);
          })),
    );
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final tempProduct = productForm.tempProduct;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              SizedBox(height: 10),
              TextFormField(
                initialValue: tempProduct.name,
                onChanged: (value) => tempProduct.name = value,
                validator: (value) {
                  if (value == null || value.length < 1)
                    return 'El nom és obligatori';
                },
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'Nom del producte', labelText: 'Nom:'),
              ),
              SizedBox(height: 30),
              TextFormField(
                initialValue: '${tempProduct.price}',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  if (double.tryParse(value) == null) {
                    tempProduct.price = 0;
                  } else {
                    tempProduct.price = double.parse(value);
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                    hintText: '99€', labelText: 'Preu:'),
              ),
              SizedBox(height: 30),
              SwitchListTile.adaptive(
                value: tempProduct.available,
                title: Text('Disponible'),
                activeColor: Colors.indigo,
                // Funció resumida
                onChanged: productForm.updateAvailability,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, 5),
              blurRadius: 5),
        ],
      );
}
