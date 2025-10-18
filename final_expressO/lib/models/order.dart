import 'product.dart';

class Order {
  final int id;
  final int userId;
  final String paymentMethod;
  final String email;
  final String username;
  final String address;
  final String phone_number;
  final String status;
  final double totalPrice;
  final double discounted;
  final String created_at;
  final List<Product> items;
  final Map<String, dynamic>? discount;

  Order({
    required this.id,
    required this.userId,
    required this.email,
    required this.username,
    required this.address,
    required this.phone_number,
    required this.paymentMethod,
    required this.status,
    required this.totalPrice,
    required this.discounted,
    required this.items,
    required this.created_at,
    this.discount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List<dynamic>? ?? [];
    final products = itemsData.map((i) {
      return Product(
        id: i['item_id'],
        name: i['name'],
        img: i['img'],
        price: (i['price'] as num).toDouble(),
        quantity: i['quantity'],
        size: i['size'] ?? '',
      );
    }).toList();

    return Order(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      address: json['address'],
      phone_number: json['phone_number'],
      userId: json['user_id'],
      paymentMethod: json['payment_method'],
      status: json['Status'] ?? 'Unknown',
      totalPrice: (json['total_price'] as num).toDouble(),
      discounted: (json['discounted'] as num).toDouble(),
      discount: json['discount'],
      created_at: json['created_at'],
      items: products,
    );
  }
}
