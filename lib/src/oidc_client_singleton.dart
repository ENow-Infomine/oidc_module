import 'dart:math';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:openid_client/openid_client.dart';
import 'authorized_client.dart';

class OIDCClient {
  static OIDCClient? _instance;

  OIDCClient._internal(this._clientId, this._clientSecret);

  final String _clientId;
  final String _clientSecret;
  
  // Placeholder replaced by entrypoint.sh at runtime in MicroK8s
  final Uri discoveryUri = Uri.parse("API_REALMS_URL_PLACEHOLDER");
  
  final List<String> scopes = ['openid', 'profile', 'email', 'offline_access'];
  Credential? credential;

  static OIDCClient getInstance(String clientId, String clientSecret) {
    _instance ??= OIDCClient._internal(clientId, clientSecret);
    return _instance!;
  }

  /// Encapsulates library types by returning a standard Map
  Future<UserInfo?> getJsonUserInfo() async {
    await _getRedirectResult();
    if (credential != null) {
      final info = await credential!.getUserInfo();
      return info;
    }
    return null;
  }

  /// Factory for the specialized HTTP client
  http.Client createHttpClient() {
    return AuthorizedClient(credential);
  }

  Future<void> _getRedirectResult() async {
    var responseUrl = html.window.sessionStorage["auth_callback_response_url"];
    if (responseUrl != null) {
      var codeVerifier = html.window.sessionStorage["auth_code_verifier"];
      var state = html.window.sessionStorage["auth_state"];
      
      var issuer = await Issuer.discover(discoveryUri);
      var client = Client(issuer, _clientId, clientSecret: _clientSecret);

      var flow = Flow.authorizationCodeWithPKCE(
        client,
        scopes: scopes,
        codeVerifier: codeVerifier,
        state: state,
      )..redirectUri = Uri.parse(
          '${html.window.location.protocol}//${html.window.location.host}${html.window.location.pathname}');

      var responseUri = Uri.parse(responseUrl);
      credential = await flow.callback(responseUri.queryParameters);
      _cleanupStorage();
    }
  }

  void authenticate() async {
    var codeVerifier = _randomString(50);
    var state = _randomString(20);
    
    var issuer = await Issuer.discover(discoveryUri);
    var client = Client(issuer, _clientId, clientSecret: _clientSecret);

    var flow = Flow.authorizationCodeWithPKCE(
      client,
      scopes: scopes,
      codeVerifier: codeVerifier,
      state: state,
    )..redirectUri = Uri.parse(
        '${html.window.location.protocol}//${html.window.location.host}${html.window.location.pathname}');

    html.window.sessionStorage["auth_code_verifier"] = codeVerifier;
    html.window.sessionStorage["auth_state"] = state;
    html.window.location.href = flow.authenticationUri.toString();
    throw "Authenticating...";
  }

  void logOut() {
    if (credential == null) {
      // If no credential, just go to the home page to trigger login
      html.window.location.assign(html.window.location.origin);
      return;
    }
    final logoutUrl = credential!.generateLogoutUrl(
      redirectUri: Uri.parse('${html.window.location.origin}${html.window.location.pathname}'),
    );
    _cleanupStorage();
    html.window.location.assign(logoutUrl.toString());
  }

  void _cleanupStorage() {
    html.window.sessionStorage.remove("auth_code_verifier");
    html.window.sessionStorage.remove("auth_callback_response_url");
    html.window.sessionStorage.remove("auth_state");
  }

  String _randomString(int length) {
    var r = Random.secure();
    const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Iterable.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }
}