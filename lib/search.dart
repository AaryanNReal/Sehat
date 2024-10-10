import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _productInfo = '';
  String? _productImageUrl;
  bool _isLoading = false;
  String nutrientsInfo = '';
  String quantity = "";
  String sugar = "";
  String fat = "";
 

  String barcode = "No barcode scanned";

  @override
  void initState() {
    super.initState();
    _scanBarcode(); // Automatically scan barcode when page opens
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcode = result.rawContent.isNotEmpty
            ? result.rawContent
            : "No barcode scanned";
      });

      if (barcode != "No barcode scanned" && barcode.isNotEmpty) {
        await _searchProductByBarcode(barcode);
      }
    } catch (e) {
      setState(() {
        barcode = "Failed to get the barcode.";
      });
    }
  }

  Future<void> _searchProductByBarcode(String barcode) async {
    _setLoadingState(true);

    final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          final product = data['product'];
          _updateProductDetails(product);
        } else {
          _setProductInfo('No product found.', null);
        }
      } else {
        _setProductInfo('Error fetching data.', null);
      }
    } catch (e) {
      _setProductInfo('Failed to load data. Please try again.', null);
    } finally {
      _setLoadingState(false);
    }
  }

  void _updateProductDetails(dynamic product) {
    setState(() {
      _productInfo =
          'Name: ${product['product_name']}\nBrand: ${product['brands']}\nQuantity: ${product['quantity']}\nCategories: ${product['categories']}\nLabels: ${product['labels']}\nOrigin: ${product['origin_of_ingredients'] ?? 'Not available'}';
      _productImageUrl = product['image_url'];
      quantity = product['quantity'];
      sugar = product['nutriments']['sugars'].toString();
      fat = product['nutriments']['fat'].toString();
      nutrientsInfo = 'Energy: ${product['nutriments']['energy']} kJ\n'
          'Fat: ${product['nutriments']['fat']} g\n'
          'Saturated Fat: ${product['nutriments']['saturated-fat']} g\n'
          'Carbohydrates: ${product['nutriments']['carbohydrates']} g\n'
          'Sugars: ${product['nutriments']['sugars']} g\n'
          'Fiber: ${product['nutriments']['fiber']} g\n'
          'Protein: ${product['nutriments']['proteins']} g\n'
          'Salt: ${product['nutriments']['salt']} g';

    });
  }

  

  void _setLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
      if (isLoading) {
        _productInfo = '';
        _productImageUrl = null;
        nutrientsInfo = '';
        quantity = '';
        sugar = '';
        fat = '';

      }
    });
  }

  void _setProductInfo(String info, String? imageUrl) {
    setState(() {
      _productInfo = info;
      _productImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Product Details',style: TextStyle(color:Colors.black),),
        backgroundColor: Colors.white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 15,
                shadowColor: Colors.black,
                color: Colors.teal,
                child: Padding(padding: EdgeInsets.all(10),
              
                child: Column(
                  children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black,))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_productImageUrl != null)
                        Container(
                          height: 300,
                          child: 
                          Image.network(
                            _productImageUrl!,
                           
                          ),),
                        const SizedBox(height: 10),
                        Card( elevation:5,
                shadowColor: Colors.white,
                color: Colors.black,
                child: Padding(padding: EdgeInsets.all(10),
                        child: Column(children: [
                        Text(
                          _productInfo,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Lighter gray for text
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          color: Colors.white,
                        child: Padding(padding: EdgeInsets.all(10),
                        child: Column(children: [
                        Text(
                          nutrientsInfo,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black, // Lighter gray for text
                          ),
                        ),
                        const SizedBox(height: 10),
                        ])))
                      ],
                    ),
                        ))])
            ])))
            ],
          ),
        ),
      ),
    );
  }
}
