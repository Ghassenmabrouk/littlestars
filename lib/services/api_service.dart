import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Use your machine's local IP for physical devices
  static const String baseUrl = 'http://192.168.1.21/jardin_enfant_ghofrane';
  
  // For Android emulator, use: 'http://10.0.2.2/jardin_enfant_ghofrane'
  // For physical device, use your machine's local IP: 'http://192.168.1.21/jardin_enfant_ghofrane'

  static const String apiPrefix = '$baseUrl/api';

  /// Parent Login
  static Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to login: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Parent Registration
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to register: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Add child
  static Future<Map<String, dynamic>> addChild(String userEmail, Map<String, dynamic> childData) async {
    try {
      final payload = {...childData, 'user_email': userEmail};
      final response = await http.post(
        Uri.parse('$baseUrl/add_child_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to add child: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get attendance summary
  static Future<Map<String, dynamic>> getAttendanceSummary(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child_status_api.php?action=attendance_summary&child_id=$childId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch summary'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get child's today status
  static Future<Map<String, dynamic>> getChildTodayStatus(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child_status_api.php?action=today_status&child_id=$childId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch status'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get activities
  static Future<Map<String, dynamic>> getActivities([int? childId]) async {
    try {
      String url = '$baseUrl/child_status_api.php?action=activities';
      if (childId != null) {
        url += '&child_id=$childId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch activities'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get today status (same as getChildTodayStatus, for compatibility)
  static Future<Map<String, dynamic>> getTodayStatus(int childId) async {
    return getChildTodayStatus(childId);
  }

  /// Get communications for a child
  static Future<Map<String, dynamic>> getCommunications(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child_info_api.php?action=communications&child_id=$childId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch communications'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get activities for a child
  static Future<Map<String, dynamic>> getChildActivities(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child_info_api.php?action=activities&child_id=$childId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch activities'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get payments for a child
  static Future<Map<String, dynamic>> getChildPayments(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child_info_api.php?action=payments&child_id=$childId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch payments'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Record a payment for a bill
  static Future<Map<String, dynamic>> recordPayment({
    required int childId,
    required int billId,
    required double montant,
    required String modePaiement,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/child_info_api.php?action=record_payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': childId,
          'bill_id': billId,
          'montant': montant,
          'mode_paiement': modePaiement,
          'reference': 'APP-${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to record payment',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Process a credit card payment
  static Future<Map<String, dynamic>> processPayment({
    required int childId,
    required int billId,
    required double amount,
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/child_info_api.php?action=process_payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': childId,
          'bill_id': billId,
          'montant': amount,
          'card_number': cardNumber,
          'expiry': expiry,
          'cvv': cvv,
          'cardholder_name': cardholderName,
          'payment_method': 'credit_card',
          'reference': 'APP-${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to process payment',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get emergency contacts
  static Future<Map<String, dynamic>> getEmergencyContacts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child_info_api.php?action=contacts'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch contacts'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get complete child profile
  static Future<Map<String, dynamic>> getChildProfile(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/child_info_api.php?action=profile&child_id=$childId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch child profile'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get attendance history for a child
  static Future<Map<String, dynamic>> getAttendanceHistory(int childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance_api.php?child_id=$childId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch attendance history'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get messages for a user
  static Future<Map<String, dynamic>> getMessages(int userId, String userRole, {int? childId}) async {
    try {
      String url = '$baseUrl/messaging_api.php?user_id=$userId&user_role=$userRole';
      if (childId != null) {
        url += '&child_id=$childId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch messages'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required int senderId,
    required String senderRole,
    required int receiverId,
    required String receiverRole,
    required String message,
    int? childId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messaging_api.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'sender_role': senderRole,
          'receiver_id': receiverId,
          'receiver_role': receiverRole,
          'message': message,
          'child_id': childId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to send message'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Get Notifications
  static Future<Map<String, dynamic>> getNotifications(int parentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications_api.php?parent_id=$parentId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch notifications'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }
}
