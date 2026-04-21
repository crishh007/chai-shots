import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    const String port = '5000';
    
    // 1. Web
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }
    
    // 2. Mobile/Desktop
    const String myLocalIp = '10.0.2.2'; 
    
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:$port/api';
      } else if (Platform.isIOS) {
        return 'http://localhost:$port/api';
      }
    } catch (_) {
      // Fallback if Platform throws
    }
    
    // Default fallback
    return 'http://$myLocalIp:$port/api';
  }
}
