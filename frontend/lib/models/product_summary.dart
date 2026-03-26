class ProductSummary {
  final String id;
  final String imageUrl;
  final String brand;
  final String title;
  final double originalPrice;
  final double price;
  final int discountPercentage;

  const ProductSummary({
    required this.id,
    required this.imageUrl,
    required this.brand,
    required this.title,
    required this.originalPrice,
    required this.price,
    required this.discountPercentage,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      brand: json['brand'] as String,
      title: json['title'] as String,
      originalPrice: (json['original_price'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      discountPercentage: json['discount_percentage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'brand': brand,
      'title': title,
      'original_price': originalPrice,
      'price': price,
      'discount_percentage': discountPercentage,
    };
  }

  static const String selectColumns =
      'id, image_url, brand, title, original_price, price, discount_percentage';
}
