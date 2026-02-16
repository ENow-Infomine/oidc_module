import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:oidc_module/oidc_module.dart';
import 'package:enow/shared/styling.dart' as styling;
import 'package:enow/shared/global.dart' as global;
import 'package:enow/authentication/adminMainFrames.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Singleton (Placeholders injected at runtime by entrypoint.sh)
  var oidcClient = OIDCClient.getInstance(
    "API_CLIENTID_URL_PLACEHOLDER", 
    "API_CLIENTSEC_URL_PLACEHOLDER"
  );
  
  // Blocking Authentication check
  final Map<String, dynamic>? userInfo = await oidcClient.getJsonUserInfo();

  if (userInfo == null) {
    oidcClient.authenticate();
  } else {
    runApp(
      MultiProvider(
        providers: [
          Provider<OIDCClient>.value(value: oidcClient),
          Provider<Map<String, dynamic>>.value(value: userInfo),
          // Provides the AuthorizedClient globally
          Provider<http.Client>(create: (_) => oidcClient.createHttpClient()),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eNow Digital Platform',
      navigatorKey: global.navigatorKey,
      theme: _buildThemeData(context),
      debugShowCheckedModeBanner: false,
      home: IdleManager(
        idleDuration: const Duration(minutes: 14),
        warningDuration: const Duration(seconds: 60),
        onLogout: () => context.read<OIDCClient>().logOut(),
        child: const riskAdminMainConfiguration(), // Clean constructor
      ),
    );
  }

  ThemeData _buildThemeData(BuildContext context) {
    // Note: Use your existing theme logic here...
    return ThemeData(useMaterial3: true /* ... */);
  }
}