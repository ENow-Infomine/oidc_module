import 'package:http/http.dart' as http;
import 'package:openid_client/openid_client.dart';

import 'oidc_client_singleton.dart';

class AuthorizedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Credential? credential;

  AuthorizedClient(this.credential);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (credential != null) {
      var response;
      try {
        // Refresh check with 60-second buffer
        response = await credential!.getTokenResponse();
      } catch (e) {
        // If we reach here, the Refresh Token is likely expired or revoked
        print("Refresh Token Expired or Session Invalid: $e");
        
        // TRIGGER LOGOUT
        // This clears local state and redirects to Keycloak to kill the cookie
        OIDCClient.getInstance("", "").logOut(); 
        
        // Throw an error to stop the current API call from proceeding
        throw Exception("Session Expired");        
      }
        
        if (response.expiresAt!.difference(DateTime.now()).inSeconds < 60) {
          response = await credential!.getTokenResponse(true);
        }
        request.headers['Authorization'] = 'Bearer ${response.accessToken}';
      
    }
    return _inner.send(request);
  }
}