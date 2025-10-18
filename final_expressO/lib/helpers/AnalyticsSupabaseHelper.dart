import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

// Summary container returned to the UI with all analytics widgets.
class AdminAnalyticsReport {
  final int totalOrders;
  final double totalSales;
  final int totalCustomers;
  final List<AdminTopProductStat> topProducts;
  final List<AdminFailedOrderInfo> failedOrders;
  final List<AdminCustomerCancellationStat> topCancellingCustomers;
  final List<AdminCategoryStat> categoryStats;

  AdminAnalyticsReport({
    required this.totalOrders,
    required this.totalSales,
    required this.totalCustomers,
    required this.topProducts,
    required this.failedOrders,
    required this.topCancellingCustomers,
    required this.categoryStats,
  });
}

// Aggregated totals per category for the donut chart.
class AdminCategoryStat {
  final int categoryId;
  final String? categoryName;
  final int itemCount; // total items sold (sum of quantities)
  final double grossSales;

  AdminCategoryStat({
    required this.categoryId,
    required this.categoryName,
    required this.itemCount,
    required this.grossSales,
  });
}

// Aggregated totals per product for the top-selling list.
class AdminTopProductStat {
  final int productId;
  final String name;
  final String? imageUrl;
  final int quantitySold;
  final double grossSales;

  AdminTopProductStat({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.quantitySold,
    required this.grossSales,
  });
}

// Captures cancelled/rejected order details for the failed orders tab.
class AdminFailedOrderInfo {
  final String orderId;
  final String customerName;
  final String status;
  final double total;
  final DateTime createdAt;
  final String itemsSummary;

  AdminFailedOrderInfo({
    required this.orderId,
    required this.customerName,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.itemsSummary,
  });
}

// Tracks customers who repeatedly cancel orders.
class AdminCustomerCancellationStat {
  final int userId;
  final String customerName;
  final int cancelledCount;

  AdminCustomerCancellationStat({
    required this.userId,
    required this.customerName,
    required this.cancelledCount,
  });
}

// Pending order summary for orders that are "Pending".
class AdminPendingOrderSummary {
  final String orderId;
  final String customerName;
  final double total;
  final DateTime createdAt;
  final String itemsSummary;

  AdminPendingOrderSummary({
    required this.orderId,
    required this.customerName,
    required this.total,
    required this.createdAt,
    required this.itemsSummary,
  });
}

// Centralized Supabase helper used by admin pages.
class AdminSupabaseHelper {
  final SupabaseClient client = Supabase.instance.client;

  // Quick connectivity check to ensure Supabase is reachable.
  Future<bool> isConnected() async {
    try {
      final response = await client.from('Products').select().limit(1);
      return response.isNotEmpty;
    } catch (e) {
      print("Connection error: $e");
      return false;
    }
  }

  // Generic fetch of every row in a table.
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    try {
      final response = await client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("GetAll error: $e");
      return [];
    }
  }

  // Retrieve a single row by its primary key.
  Future<Map<String, dynamic>?> getById(
      String table, String idColumn, dynamic id) async {
    try {
      final response =
          await client.from(table).select().eq(idColumn, id).maybeSingle();
      return response;
    } catch (e) {
      print("GetById error: $e");
      return null;
    }
  }

  // Insert a new record and return the inserted row.
  Future<Map<String, dynamic>?> insert(
      String table, Map<String, dynamic> data) async {
    try {
      final response = await client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      print("Insert error: $e");
      return null;
    }
  }

  // Uploads a product image to Supabase storage and returns the public URL.
  Future<String?> uploadProductImage(File file, String productID) async {
    final filePath = 'files/$productID.png'; // folder + filename

    try {
      final response = await client.storage
          .from('product_images') // 👈 bucket name
          .upload(filePath, file);

      // Get a public URL if the bucket is public
      final publicUrl =
          client.storage.from('product_images').getPublicUrl(filePath);

      return publicUrl; // return the URL so you can store it in DB
    } on StorageException catch (e) {
      print('Storage error: ${e.message}');
      return null;
    } catch (e) {
      print('Unknown error: $e');
      return null;
    }
  }

  // Wrapper that builds the product payload and saves it to Supabase.
  Future<Map<String, dynamic>> addNewProduct(
    String name,
    String desc,
    String categoryId,
    String stock,
    String basePrice,
    File? file,
  ) async {
    try {
      final int? catId = int.tryParse(categoryId);
      final int parsedStock = int.tryParse(stock) ?? 0;
      final double parsedPrice = double.tryParse(basePrice) ?? 0;

      String? imageUrl;
      if (file != null) {
        imageUrl = await uploadProductImage(file, name.replaceAll(' ', '_'));
      }

      final product = {
        'name': name,
        'desc': desc,
        'cat_id': catId,
        'stock': parsedStock,
        'status': 'active',
        'img': imageUrl,
        'variations': [
          {
            'name': 'default',
            'price': parsedPrice,
          }
        ],
      };

      await insert('Products', product);

      return {
        'success': true,
        'message': 'Product saved successfully!',
      };
    } catch (e) {
      print('addNewProduct error: $e');
      return {
        'success': false,
        'message': 'Something went wrong, please try again.',
      };
    }
  }

  // Update any table row, returning the updated record.
  Future<Map<String, dynamic>?> update(String table, String idColumn,
      dynamic id, Map<String, dynamic> data) async {
    try {
      final response = await client
          .from(table)
          .update(data)
          .eq(idColumn, id)
          .select()
          .single();
      return response;
    } catch (e) {
      print("Update error: $e");
      return null;
    }
  }

  // Delete a row from Supabase by id.
  Future<bool> delete(String table, String idColumn, dynamic id) async {
    try {
      await client.from(table).delete().eq(idColumn, id);
      return true;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }

  // Opens a realtime channel that listens for inserts/updates/deletes.
  RealtimeChannel listenToTable(
    String table, {
    void Function(Map<String, dynamic> payload)? onInsert,
    void Function(Map<String, dynamic> payload)? onUpdate,
    void Function(Map<String, dynamic> payload)? onDelete,
  }) {
    final channel = client.channel('public:$table');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: (payload) {
            if (onInsert != null) onInsert(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: (payload) {
            if (onUpdate != null) onUpdate(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: (payload) {
            if (onDelete != null) onDelete(payload.oldRecord);
          },
        )
        .subscribe();

    return channel;
  }

  // Stops listening to a realtime channel.
  void unsubscribe(RealtimeChannel channel) {
    client.removeChannel(channel);
  }

  // Normalizes the various formats Supabase may return for JSON variations.
  List<Map<String, dynamic>> _normalizeVariations(dynamic raw) {
    try {
      if (raw == null) return [];
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map<Map<String, dynamic>>((e) {
            if (e is Map) return Map<String, dynamic>.from(e);
            return {};
          }).toList();
        }
        return [];
      } else if (raw is List) {
        return raw.map<Map<String, dynamic>>((e) {
          if (e is Map) return Map<String, dynamic>.from(e);
          if (e is String) {
            try {
              final parsed = jsonDecode(e);
              if (parsed is Map) return Map<String, dynamic>.from(parsed);
            } catch (_) {}
          }
          return {};
        }).toList();
      } else if (raw is Map) {
        // sometimes Supabase returns a single map
        return [Map<String, dynamic>.from(raw)];
      }
    } catch (_) {}
    return [];
  }

  // Tries to match a price based on the requested size, falling back gracefully.
  double _resolveVariationPrice(dynamic rawVariations, String? size) {
    final variations = _normalizeVariations(rawVariations);
    if (variations.isNotEmpty) {
      final normalizedSize = size?.toString().toLowerCase();
      for (final variant in variations) {
        final variantName = (variant['name']?.toString().toLowerCase());
        final price = variant['price'];
        if (normalizedSize != null && variantName == normalizedSize) {
          if (price is num) return price.toDouble();
          if (price is String) return double.tryParse(price) ?? 0;
        }
      }
      // fallback to first variant price
      final firstPrice = variations.first['price'];
      if (firstPrice is num) return firstPrice.toDouble();
      if (firstPrice is String) return double.tryParse(firstPrice) ?? 0;
    }
    return 0;
  }

  // Attempts to parse any supported date representation from Supabase.
  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Formats statuses for display (capitalized) while analytics uses lowercase checks.
  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    final normalized = status.trim().toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  // Fetches analytics: totals, top products, failed orders, category breakdowns.
  Future<AdminAnalyticsReport> fetchAnalyticsReport() async {
    try {
      final int ordersCount = await client.from('Orders').count();
      final int itemsCount = await client.from('Order_items').count();
      final int productsCount = await client.from('Products').count();
      print(
          'DEBUG counts -> Orders: $ordersCount, Order_items: $itemsCount, Products: $productsCount');

      // raw small select to see if Orders returns any rows
      final rawOrdersTest =
          await client.from('Orders').select('id, created_at').limit(5);
      print('DEBUG rawOrdersTest length: ${(rawOrdersTest as List).length}');
      if ((rawOrdersTest as List).isNotEmpty)
        print('DEBUG rawOrdersTest sample: ${rawOrdersTest.first}');

      // test nested join from Order_items -> Products
      final joinTest = await client
          .from('Order_items')
          .select(
              'id, order_id, quantity, item:Products(id, name, cat_id, variations)')
          .limit(5);
      print('DEBUG joinTest length: ${(joinTest as List).length}');
      if ((joinTest as List).isNotEmpty)
        print('DEBUG joinTest sample: ${joinTest.first}');
      // fetch categories map to get category names (optional, but helpful)
      final rawCategories = await client.from('Categories').select('id,name');
      final Map<int, String> categoriesById = {};
      if (rawCategories is List) {
        for (final c in rawCategories) {
          final cid = (c['id'] as num?)?.toInt();
          final cname = c['name'] as String?;
          if (cid != null) categoriesById[cid] = cname ?? 'Category #$cid';
        }
      }

      // Pull orders with nested items, products, and status updates.
      final rawOrders = await client.from('Orders').select('''
            id,
            created_at,
            user_id,
            Users(id, username, email, role),
            Order_items(
              id,
              quantity,
              size,
              item_id,
              item:Products(id, name, img, variations, cat_id)
            ),
            Order_updates(status, created_at)
          ''').order('created_at');

      final orders = (rawOrders as List<dynamic>).cast<Map<String, dynamic>>();
      print('fetchAnalyticsReport -> total orders fetched: ${orders.length}');
      if (orders.isNotEmpty) {
        print('fetchAnalyticsReport -> sample order: ${orders.first}');
      }

      final Set<int> customerIds = {};
      double totalSales = 0;
      final List<AdminFailedOrderInfo> failedOrders = [];
      final Map<int, Map<String, dynamic>> productAccumulator = {};
      final Map<int, Map<String, dynamic>> cancellationAccumulator = {};
      final Map<int, Map<String, dynamic>> categoryAccumulator = {};

      int successfulOrdersCount = 0;

      for (final order in orders) {
        final int? userId = (order['user_id'] as num?)?.toInt();
        final userData = order['Users'] as Map<String, dynamic>?;
        final roleValue = (userData?['role'] as num?)?.toInt();
        final isBuyer = roleValue == 0;

        // Resolve the customer and latest order status.
        final updates = (order['Order_updates'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
          ..sort((a, b) => (_parseDate(a['created_at']) ??
                  DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(_parseDate(b['created_at']) ??
                  DateTime.fromMillisecondsSinceEpoch(0)));
        final rawStatus =
            updates.isEmpty ? null : updates.last['status'] as String?;
        final trimmedStatus = rawStatus?.toString().trim();
        final normalizedStatus = trimmedStatus?.toLowerCase() ?? '';
        final bool isCompleted = normalizedStatus == 'completed';
        final bool isCancelled = normalizedStatus == 'cancelled';
        final bool isRejected = normalizedStatus == 'rejected';
        final bool isFailed = isCancelled || isRejected;
        final bool includeInStats = isCompleted;
        final statusLabel = _formatStatus(trimmedStatus);

        final items = (order['Order_items'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();

        double orderTotal = 0;
        final List<String> itemNames = [];

        // Aggregate order totals, product stats, and category stats.
        for (final item in items) {
          final qty = (item['quantity'] as num?)?.toInt() ?? 0;
          if (qty == 0) continue;

          final size = item['size'] as String?;
          final productData = item['item'] as Map<String, dynamic>?;
          final productId = (productData?['id'] as num?)?.toInt() ??
              (item['item_id'] as num?)?.toInt();
          final productName = productData?['name'] as String? ?? 'Unknown';
          final imageUrl = productData?['img'] as String?;
          final catId = (productData?['cat_id'] as num?)?.toInt();

          // Resolve unit price more robustly
          double unitPrice =
              _resolveVariationPrice(productData?['variations'], size);
          // fallback: variant not found or variations empty -> try a 'price' key on productData
          if (unitPrice == 0) {
            final maybePrice = productData?['price'];
            if (maybePrice is num) unitPrice = maybePrice.toDouble();
            if (maybePrice is String)
              unitPrice = double.tryParse(maybePrice) ?? unitPrice;
          }

          final lineTotal = unitPrice * qty;
          print(
            'Item debug -> order ${order['id']}, productId: $productId, qty: $qty, unitPrice: $unitPrice, '
            'lineTotal: $lineTotal, size: $size, variations: ${productData?['variations']}',
          );
          orderTotal += lineTotal;
          itemNames.add(productName);

          if (productId != null && includeInStats) {
            final entry = productAccumulator.putIfAbsent(productId, () {
              return {
                'name': productName,
                'imageUrl': imageUrl,
                'quantity': 0,
                'sales': 0.0,
              };
            });
            entry['quantity'] = (entry['quantity'] as int) + qty;
            entry['sales'] = (entry['sales'] as double) + lineTotal;
          }

          if (catId != null && includeInStats) {
            final catEntry = categoryAccumulator.putIfAbsent(catId, () {
              return {
                'name': categoriesById[catId] ?? 'Category #$catId',
                'quantity': 0,
                'sales': 0.0,
              };
            });
            catEntry['quantity'] = (catEntry['quantity'] as int) + qty;
            catEntry['sales'] = (catEntry['sales'] as double) + lineTotal;
          }
        } // end items loop

        final customerLabel = userData?['username'] ??
            userData?['email'] ??
            (userId != null ? 'Customer #$userId' : 'Unknown Customer');

        // Build failed order cards or completed-order metrics.
        if (isFailed) {
          if (isCancelled && userId != null) {
            final entry = cancellationAccumulator.putIfAbsent(userId, () {
              return {
                'name': customerLabel,
                'count': 0,
              };
            });
            entry['count'] = (entry['count'] as int) + 1;
          }

          failedOrders.add(AdminFailedOrderInfo(
            orderId: order['id'].toString(),
            customerName: customerLabel,
            status: statusLabel,
            total: orderTotal,
            createdAt: _parseDate(order['created_at']) ?? DateTime.now(),
            itemsSummary: itemNames.take(3).join(', '),
          ));
        } else if (isCompleted) {
          totalSales += orderTotal;
          successfulOrdersCount++;
        }

        if (isBuyer && userId != null) customerIds.add(userId);
      } // end orders loop

      // Convert raw accumulator maps into typed summaries.
      // produce topProducts list
      final topProducts = productAccumulator.entries
          .map((entry) => AdminTopProductStat(
                productId: entry.key,
                name: entry.value['name'] as String,
                imageUrl: entry.value['imageUrl'] as String?,
                quantitySold: entry.value['quantity'] as int,
                grossSales: entry.value['sales'] as double,
              ))
          .toList()
        ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

      // produce category stats list
      final categoryStats = categoryAccumulator.entries
          .map((e) => AdminCategoryStat(
                categoryId: e.key,
                categoryName: e.value['name'] as String?,
                itemCount: e.value['quantity'] as int,
                grossSales: e.value['sales'] as double,
              ))
          .toList()
        ..sort((a, b) => b.itemCount.compareTo(a.itemCount));

      // top cancelling customers
      final topCustomers = cancellationAccumulator.entries
          .map((entry) => AdminCustomerCancellationStat(
                userId: entry.key,
                customerName: entry.value['name'] as String,
                cancelledCount: entry.value['count'] as int,
              ))
          .toList()
        ..sort((a, b) => b.cancelledCount.compareTo(a.cancelledCount));

      int totalCustomers = customerIds.length;
      try {
        // get exact user count for role 0
        final int count = await client.from('Users').count().eq('role', 0);
        totalCustomers = count;
      } catch (e) {
        print('User count fallback error: $e');
      }

      print('Final category accumulator: $categoryAccumulator');
      print('Successful orders counted: $successfulOrdersCount');
      print('Total sales computed: $totalSales');

      // Return the final report consumed by the analytics screen.
      return AdminAnalyticsReport(
        totalOrders: successfulOrdersCount, // now successful orders count
        totalSales: totalSales,
        totalCustomers: totalCustomers,
        topProducts: topProducts.take(5).toList(),
        failedOrders: failedOrders,
        topCancellingCustomers: topCustomers.take(5).toList(),
        categoryStats: categoryStats,
      );
    } catch (e) {
      print('fetchAnalyticsReport error: $e');
      rethrow;
    }
  }

  // Fetches pending orders that are "Pending".
  Future<List<AdminPendingOrderSummary>> fetchPendingOrdersForApproval() async {
    try {
      final rawOrders = await client.from('Orders').select('''
            id,
            created_at,
            user_id,
            Users(id, username, email),
            Order_items(
              quantity,
              size,
              item:Products(id, name, variations)
            ),
            Order_updates(status, created_at)
          ''').order('created_at');

      final orders = (rawOrders as List<dynamic>).cast<Map<String, dynamic>>();
      final List<AdminPendingOrderSummary> pending = [];

      for (final order in orders) {
        final updates = (order['Order_updates'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()
          ..sort((a, b) => (_parseDate(a['created_at']) ??
                  DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(_parseDate(b['created_at']) ??
                  DateTime.fromMillisecondsSinceEpoch(0)));

        final rawStatus =
            updates.isEmpty ? null : updates.last['status'] as String?;
        final normalizedStatus = rawStatus?.toString().trim().toLowerCase() ?? '';
        if (normalizedStatus != 'Pending') continue;

        final userData = order['Users'] as Map<String, dynamic>?;
        final int? userId = (order['user_id'] as num?)?.toInt();
        final customerLabel = userData?['username'] ??
            userData?['email'] ??
            (userId != null ? 'Customer #$userId' : 'Unknown Customer');

        final items = (order['Order_items'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        double orderTotal = 0;
        final List<String> itemNames = [];

        for (final item in items) {
          final qty = (item['quantity'] as num?)?.toInt() ?? 0;
          if (qty == 0) continue;

          final size = item['size'] as String?;
          final productData = item['item'] as Map<String, dynamic>?;
          final productName = (productData?['name'] as String?) ?? 'Unknown';

          double unitPrice =
              _resolveVariationPrice(productData?['variations'], size);
          if (unitPrice == 0) {
            final maybePrice = productData?['price'];
            if (maybePrice is num) unitPrice = maybePrice.toDouble();
            if (maybePrice is String) {
              unitPrice = double.tryParse(maybePrice) ?? unitPrice;
            }
          }

          orderTotal += unitPrice * qty;
          itemNames.add(productName);
        }

        pending.add(AdminPendingOrderSummary(
          orderId: order['id'].toString(),
          customerName: customerLabel,
          total: orderTotal,
          createdAt: _parseDate(order['created_at']) ?? DateTime.now(),
          itemsSummary: itemNames.isEmpty
              ? 'No items captured'
              : itemNames.take(3).join(', '),
        ));
      }

      pending.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return pending;
    } catch (e) {
      print('fetchPendingOrdersForApproval error: $e');
      rethrow;
    }
  }
}
