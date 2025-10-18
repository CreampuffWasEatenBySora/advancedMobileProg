import 'package:firebase_nexus/helpers/local_database_helper.dart';
import 'package:firebase_nexus/helpers/supabase_helper.dart';
import 'package:firebase_nexus/models/product.dart';
import 'package:firebase_nexus/models/supabaseProduct.dart';
import 'package:firebase_nexus/providers/userProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSupabaseHelper {
  final SupabaseClient _client = Supabase.instance.client;
  final mainhelper = SupabaseHelper();
  final sqlFlite = SQLFliteDatabaseHelper();
  final userProvider = UserProvider();
  Map<String, dynamic>? currentUser; // <-- store signed-in user

  Future<bool> isConnected() async {
    try {
      final response = await _client.from('Products').select().limit(1);
      return response.isNotEmpty;
    } catch (e) {
      print("Connection error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      // 🔹 Stage 1: Quick DB validation
      final existingUser =
          await _client.from('Users').select().eq('email', email).maybeSingle();

      if (existingUser == null) {
        return {'success': false, 'message': 'Email not found'};
      }

      if (existingUser['password'] != password) {
        return {'success': false, 'message': 'Invalid password'};
      }

      // 🔹 Stage 2: Actual Supabase Auth
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Failed to sign in with Supabase Auth',
        };
      }

      // 🔹 Stage 3: Cache and return user data

      await userProvider.setUser(existingUser);
      return {
        'success': true,
        'message': 'User logged in successfully!',
        'data': existingUser,
      };
    } catch (e) {
      print('Sign-in error: $e');
      return {
        'success': false,
        'message': 'Something went wrong on our end, try again later.',
      };
    }
  }

  Future<Map<String, dynamic>> signUp(
    String email,
    String password,
    String address,
    String uname,
    String pnum,
  ) async {
    try {
      // 🔹 Stage 1: Validate first
      final existingUser = await _client
          .from('Users')
          .select('id')
          .or('email.eq.$email,phone_number.eq.$pnum')
          .maybeSingle();

      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Email or phone number already in use',
        };
      }

      // 🔹 Stage 2: Register in Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Failed to register with Supabase Auth',
        };
      }

      // 🔹 Stage 3: Create user record in custom table
      final response = await _client
          .from('Users')
          .insert({
            'email': email,
            'password': password,
            'address': address,
            'role': 0,
            'username': uname,
            'phone_number': pnum,
          })
          .select()
          .single();

      print(response);
      await userProvider.setUser(response);

      return {
        'success': true,
        'message': 'Account created successfully!',
        'data': response,
      };
    } catch (e) {
      print('Sign-up error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  // 🔹 Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategs() async {
    try {
      print("functname start: getCategs");
      var query =
          _client.from("Categories").select().isFilter('deleted_at', null);
      final response = await query;
      print("functname: getCategs");

      print(response);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("GetAll error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductsForUser(
      String? searchTerm) async {
    try {
      var query = _client.from('product_overview').select();

      // If a search term and column are provided, apply a filter

      if (searchTerm != null) {
        query = query.or('name.ilike.%$searchTerm%,desc.ilike.%$searchTerm%');
      }

      query = query.not('status', 'eq', 'Inactive');

      final response = await query;

      print("functname: getAll");
      print(response);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("GetAll error: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersForUser(int userId) async {
    try {
      var query = _client.from('new_orderoverview').select().eq('user_id', userId);

      final response = await query;

      print("functname:getOrders");
      print(response);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("GetAll error: $e");
      return [];
    }
  }

  Future<List<SupabaseProduct>> getCart() async {
    return sqlFlite.getCart();
  }

  Future<Map<String, dynamic>?> getById(
      String table, String idColumn, dynamic id) async {
    try {
      final response =
          await _client.from(table).select().eq(idColumn, id).maybeSingle();
      return response;
    } catch (e) {
      print("GetById error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkCoupon(String code) async {
    try {
      final response = await _client
          .from('Discounts')
          .select()
          .eq('code', code)
          .isFilter('deleted_at', null)
          .maybeSingle();
      return {
        'success': true,
        'message': 'coupon found!',
        'data': response,
      };
    } catch (e) {
      print("GetById error: $e");
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>?> insert(
      String table, Map<String, dynamic> data) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      print("Insert error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> insertOrder(
      Map<String, dynamic> orderData) async {
    try {
      final response = await _client.rpc('create_order_with_items', params: {
        'p_user_id': orderData['user_id'],
        'p_payment_method': orderData['payment_method'],
        'p_discount_id': orderData['discount_id'],
        'p_items': orderData['items'], // must be a List<Map<String, dynamic>>
      });

      return {
        'success': true,
        'message': 'Order created successfully.',
        'data': response,
      };
    } catch (e) {
      print('⚠️ Transaction failed: $e');
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>?> update(String table, String idColumn,
      dynamic id, Map<String, dynamic> data) async {
    try {
      final response = await _client
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

  Future<bool> delete(String table, String idColumn, dynamic id) async {
    try {
      await _client.from(table).delete().eq(idColumn, id);
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
    final channel = _client.channel('public:$table');

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
    _client.removeChannel(channel);
  }
}
