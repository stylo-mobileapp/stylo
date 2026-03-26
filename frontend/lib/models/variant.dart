class Variant {
  final double price;
  final bool availability;

  const Variant({required this.price, required this.availability});

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      price: (json['price'] as num).toDouble(),
      availability: json['availability'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'price': price, 'availability': availability};
  }
}
