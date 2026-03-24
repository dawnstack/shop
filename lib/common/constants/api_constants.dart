import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _scheme = 'http';
  static const int _port = 8080;
  static const String _apiPrefix = '/api';

  static String get host {
    if (kIsWeb) {
      return 'localhost';
    }
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static String get baseUrl => '$_scheme://$host:$_port$_apiPrefix';
}
