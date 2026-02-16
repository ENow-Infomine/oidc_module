import 'package:flutter/material.dart';
import 'package:oidc_module/oidc_module.dart';
import 'business_unit_role_mapping/business_unit_role_mapping.dart';
import 'shared/global.dart' as global;
// Import your screens...

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Singleton
  var oidcClient = OIDCClient.getInstance(
    "API_CLIENTID_URL_PLACEHOLDER", 
    "API_CLIENTSEC_URL_PLACEHOLDER"
  );
  
  // 2. Blocking Login Check
  Map<String, dynamic>? userInfo = await oidcClient.getJsonUserInfo();

  if (userInfo == null) {
    oidcClient.authenticate();
  } else {
    // 3. INITIALIZE GLOBAL API CLIENT (The Secure Wrapper)
    global.api = oidcClient.createHttpClient();

    runApp(MyApp(userInfo: userInfo, oidcClient: oidcClient));
  }
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  final OIDCClient oidcClient;

  const MyApp({super.key, required this.userInfo, required this.oidcClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: global.navigatorKey, // Uses the global key
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true), 
      // 4. Wrap the home screen with IdleManager
      home: IdleManager(
        idleDuration: const Duration(minutes: 14),
        warningDuration: const Duration(seconds: 60),
        onLogout: () => oidcClient.logOut(),
        child: const BusinessUnitRoleMapping(), // No props needed
      ),
    );
  }
}