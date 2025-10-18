import 'dart:convert';
import 'dart:io';

class SupabaseProduct {
  final int? id;
  final int? prodId;
  final bool? included;
  final String name;
  final num price;
  final String variation;
  final String category;
  final String? img;
  // final Map<String, dynamic>? variation;
  final int quantity;

  const SupabaseProduct({
    this.id,
    this.included,
    this.prodId,
    required this.price,
    required this.variation,
    required this.name,
    required this.category,
    this.img,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'included': included as bool ? 1 : 0,
      'variation': variation,
      'prodId': prodId,
      'name': name,
      'category': category,
      'img_path': img,
      'quantity': quantity,
    };
  }

  factory SupabaseProduct.fromMap(Map<String, dynamic> map) {
    return SupabaseProduct(
      price: map['price'] as num,
      variation: map['variation'] as String,
      id: map['id'] as int?,
      included: map['included'] as int == 1,
      prodId: map['prodId'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      img: map['img_path'] as String?,
      quantity: map['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
