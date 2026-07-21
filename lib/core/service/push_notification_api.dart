// core/services/push_notification_api.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:Odit_CRM/core/constant/push_notification_config.dart';

class PushNotificationApi {
  PushNotificationApi._();

  static Future<void> sendPush({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final cleanTokens = tokens.where((t) => t.trim().isNotEmpty).toList();
    if (cleanTokens.isEmpty) {
      log('[PushNotificationApi] no valid FCM token(s), skipping');
      return;
    }

    final uri = Uri.parse('${PushNotificationConfig.baseUrl}/send-push');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-api-secret': PushNotificationConfig.apiSecret,
            },
            body: jsonEncode({
              'tokens': cleanTokens,
              'title': title,
              'body': body,
              if (data != null) 'data': data,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        log('[PushNotificationApi] failed (${response.statusCode}): ${response.body}');
        return;
      }
      log('[PushNotificationApi] sent: ${response.body}');
    } catch (e) {
      log('[PushNotificationApi] error: $e');
    }
  }
}