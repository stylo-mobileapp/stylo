import 'package:frontend/models/product_summary.dart';
import 'package:frontend/models/variant.dart';

class Product extends ProductSummary {
  final String category;
  final String gender;
  final String? sku;
  final String url;
  final Map<String, Variant>? variants;
  final List<String> allSizes;
  final List<String> availableSizes;
  final String? textSearch;
  final String source;
  final bool availability;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required super.id,
    required super.imageUrl,
    required super.brand,
    required super.title,
    required super.originalPrice,
    required super.price,
    required super.discountPercentage,
    required this.category,
    required this.gender,
    this.sku,
    required this.url,
    this.variants,
    required this.allSizes,
    required this.availableSizes,
    this.textSearch,
    required this.source,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      brand: json['brand'] as String,
      title: json['title'] as String,
      originalPrice: (json['original_price'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      discountPercentage: json['discount_percentage'] as int,
      category: json['category'] as String,
      gender: json['gender'] as String,
      sku: json['sku'] as String?,
      url: json['url'] as String,
      variants: json['variants'] != null
          ? (json['variants'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                Variant.fromJson(value as Map<String, dynamic>),
              ),
            )
          : null,
      allSizes: List<String>.from(json['all_sizes'] as List),
      availableSizes: List<String>.from(json['available_sizes'] as List),
      textSearch: json['text_search'] as String?,
      source: json['source'] as String,
      availability: json['availability'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'category': category,
      'gender': gender,
      'sku': sku,
      'url': url,
      'variants': variants?.map((key, value) => MapEntry(key, value.toJson())),
      'all_sizes': allSizes,
      'available_sizes': availableSizes,
      'text_search': textSearch,
      'source': source,
      'availability': availability,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
