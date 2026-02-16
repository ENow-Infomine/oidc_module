import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:oidc_module/oidc_module.dart';

class riskAdminMainConfiguration extends StatelessWidget {
  const riskAdminMainConfiguration({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch dependencies from Provider context
    final userInfo = context.watch<Map<String, dynamic>>();
    final oidcClient = context.read<OIDCClient>();
    final client = context.read<http.Client>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${userInfo['preferred_username'] ?? 'User'}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => oidcClient.logOut(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logged in as: ${userInfo['email']}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // This call automatically includes the Bearer token!
                final response = await client.get(Uri.parse("https://api.myapp.com/data"));
                print(response.body);
              },
              child: const Text("Fetch Secure Data"),
            ),
          ],
        ),
      ),
    );
  }
}