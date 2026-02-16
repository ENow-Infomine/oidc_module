import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// --- YOUR EXISTING GLOBALS. Few sample vars provided below ---
String orgId = "";
String applicationId = "";
// ... other existing variables ...

// --- ADD THIS LINE ---
// This will be initialized in main.dart and used in all services
late http.Client api; 

// Navigator key to allow IdleManager to show dialogs anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();