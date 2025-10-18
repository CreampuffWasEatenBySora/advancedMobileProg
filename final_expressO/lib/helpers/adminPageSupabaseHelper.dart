import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSupabaseHelper {
  final SupabaseClient client = Supabase.instance.client;

  Future<bool> isConnected() async {
    try {
      final response = await client.from('Products').select().limit(1);
      return response.isNotEmpty;
    } catch (e) {
      print("Connection error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAll(
      String table, String? searchTerm, String? searchColumn) async {
    try {
      var query = client.from(table).select().isFilter('deleted_at', null);

      // If a search term and column are provided, apply a filter
      if (searchTerm != null && searchColumn != null) {
        query = query.ilike(searchColumn, '%$searchTerm%');
      }

      final response = await query;

      print("functname: getAll");
      print(response);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("GetAll error: $e");
      return [];
    }
  }

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

  Future<Map<String, dynamic>> insert(
      String table, Map<String, dynamic> data) async {
    try {
      final response = await client.from(table).insert(data).select().single();
      print('INSERT ROW');

      print(response);

      return {
        'status': 'success',
        'message': 'Insert successful',
        'data': response,
      };
    } catch (e) {
      print("Insert error: $e");

      return {
        'status': 'error',
        'message': e.toString(),
        'data': null,
      };
    }
  }

  Future<String?> uploadProductImage(File file, String productID) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath =
        'files/${productID}_$timestamp.jpg'; // folder + unique filename
    print('UPLOADING IMAGE (overwrite mode)');

    try {
      final response = await client.storage.from('product_images').upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true), // 👈 allow overwrite
          );

      print('Storage response: $response');

      // Get the public URL
      final publicUrl =
          client.storage.from('product_images').getPublicUrl(filePath);

      return publicUrl;
    } on StorageException catch (e) {
      print('Storage error: ${e.message}');
      return null;
    } catch (e) {
      print('Unknown error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersForUser(int? userId) async {
    try {
      var query = client
          .from('new_orderoverview')
          .select()
          .not('total_price', 'is', null);

      // If a search term and column are provided, apply a filter
      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query;

      print("functname:getOrders");
      print(response);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("GetAll error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrderupdates(int orderID) async {
    try {
      var query = client.from('Order_updates').select().eq('order_id', orderID);

      final response = await query;

      print("functname:getOrder Updates");
      print(response);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("GetAll error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> update(String table, String idColumn, String id,
      Map<String, dynamic> data) async {
    try {
      print('UPDATING ROW: $table where $idColumn=$id');

      final rowId = int.tryParse(id);
      if (rowId == null) {
        return {
          'status': 'error',
          'message': 'Invalid ID format: $id',
          'data': null,
        };
      }

      // 1️⃣ Existence check
      final existing = await client
          .from(table)
          .select()
          .eq(idColumn, rowId)
          .maybeSingle(); // returns null if no row

      if (existing == null) {
        return {
          'status': 'error',
          'message': 'No row found with $idColumn = $id',
          'data': null,
        };
      }

      print(existing);
      // 2️⃣ Update
      final response = await client
          .from(table)
          .update(data)
          .eq(idColumn, rowId)
          .select()
          .single();

      print('UPDATE RESPONSE: $response');

      return {
        'status': 'success',
        'message': 'Update successful',
        'data': response,
      };
    } catch (e) {
      print("Update error: $e");
      return {
        'status': 'error',
        'message': e.toString(),
        'data': null,
      };
    }
  }

  Future<bool> delete(String table, String idColumn, dynamic id) async {
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();

      await client
          .from(table)
          .update({'deleted_at': timestamp}).eq(idColumn, id);
      return true;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }

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

  void unsubscribe(RealtimeChannel channel) {
    client.removeChannel(channel);
  }
}

Future<File?> fileFromSupabase(String publicUrl, {String? filename}) async {
  try {
    final response = await http.get(Uri.parse(publicUrl));
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final name = filename ?? publicUrl.split('/').last;
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      print('Download failed: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error downloading file: $e');
    return null;
  }
}
