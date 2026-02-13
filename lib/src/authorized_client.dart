import 'package:http/http.dart' as http;
import 'package:openid_client/openid_client.dart';

class AuthorizedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Credential? credential;

  AuthorizedClient(this.credential);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (credential != null) {
      try {
        // Proactive Refresh with 60s Buffer
        var response = await credential!.getTokenResponse();
        if (response.expiresAt!.difference(DateTime.now()).inSeconds < 60) {
          response = await credential!.getTokenResponse(true);
        }
        request.headers['Authorization'] = 'Bearer ${response.accessToken}';
      } catch (e) {
        // In "no-auth" dev mode, this might fail but we let the request proceed
        print("Auth header skipped: $e");
      }
    }
    return _inner.send(request);
  }
}