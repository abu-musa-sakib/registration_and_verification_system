// lib/model/context_provider.dart
import 'package:flutter/material.dart';

class ContextProvider {
  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static BuildContext? getContext() {
    return _context;
  }

  static bool hasContext() {
    return _context != null;
  }
}
