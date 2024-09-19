import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practical_task/const/api_url.dart';
import 'package:practical_task/model/product_response_model.dart';

class ProductProvider with ChangeNotifier {

  final List<FilterData?> _filterData = [
    FilterData(
      brands: [],
      categoryName: "All"
    ),
  ];
  List<FilterData?> get filterData => _filterData;

  int _number = 0;
  int get number => _number;

  final List<String> _selectedFilter = [];
  List<String> get selectedFilter => _selectedFilter;

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    final response = await http.get(Uri.parse(ApiRouts.products));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      ProductResponseModel productResponseModel = ProductResponseModel.fromJson(data);
      _products = productResponseModel.products;

      if (products.isNotEmpty) {
        for (var element in products) {
          FilterData? existingCategory = _filterData.firstWhere(
                (cat) => cat?.categoryName == element.category,
            orElse: () => null,
          );

          if (existingCategory != null) {
            if (!existingCategory.brands.contains(element.brand ?? "No Brand")) {
              existingCategory.brands.add(element.brand ?? "No Brand");
            }
          } else {
            _filterData.add(FilterData(
              brands: [element.brand ?? "No Brand"],
              categoryName: element.category,
            ));
          }
        }
      }

    } else {
      throw Exception('Failed to load products');
    }
    _isLoading = false;
    notifyListeners();
  }

  void updateIndex(int index) {
    _number = index;
    notifyListeners();
  }

  List<Product> getProductsData() {
    if(_number > 0) {
      return _products.where((element) => element.category == _filterData[_number]?.categoryName).toList();
    }
    return _products;
  }

  void onSelectFilter(String brand) {
    if(!selectedFilter.contains(brand)) {
      selectedFilter.add(brand);
    } else {
      selectedFilter.remove(brand);
    }
    notifyListeners();
  }
}
