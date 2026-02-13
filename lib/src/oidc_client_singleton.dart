import 'dart:math';
import 'dart:html';
import 'package:openid_client/openid_client.dart';

class OIDCClient {
  static OIDCClient? _instance;

  OIDCClient._internal(this._clientId, this._clientSecret);

  final String _clientId;
  final String _clientSecret;
  final Uri discoveryUri = Uri.parse("API_REALMS_URL_PLACEHOLDER");
  var scopes = ['openid', 'profile', 'basic', 'email', 'offline_access'];

  //Client? _client;
  Credential? _credential;

  static OIDCClient getInstance(String clientId, String clientSecret) {
    _instance ??= OIDCClient._internal(clientId, clientSecret);
    return _instance!;
  }

  Future<UserInfo?> getUserInfo() async {
    print("Inside getUserInfo()");
    await _getRedirectResult();
    if (_credential != null) {
      //print('print1');
      return _credential!.getUserInfo();
    } else {
      return null;
    }
  }

  Future<void> _getRedirectResult() async {
    print("Inside getRedirctReslst()");
    var responseUrl = window.sessionStorage["auth_callback_response_url"];

    if (responseUrl != null) {
      var codeVerifier = window.sessionStorage["auth_code_verifier"];
      var state = window.sessionStorage["auth_state"];

      Client? client;
      client = await _getClient();

      var flow = Flow.authorizationCodeWithPKCE(
        client!,
        scopes: scopes,
        codeVerifier: codeVerifier,
        state: state,
      );
      flow.redirectUri = Uri.parse(
          '${window.location.protocol}//${window.location.host}${window.location.pathname}');

      // handle callback
      //try {
      var responseUri = Uri.parse(responseUrl);
      print("Before flow.callback");
      _credential = await flow.callback(responseUri.queryParameters);
      print("Inside getRedirctReslst() : after credentials : $_credential");
      _cleanupStorage();
      //}
    }
  }

  Future<Client?> _getClient() async {
    var issuer = await Issuer.discover(discoveryUri);
    return Client(issuer, _clientId, clientSecret: _clientSecret);
  }

  String _randomString(int length) {
    var r = Random.secure();
    var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Iterable.generate(length, (_) => chars[r.nextInt(chars.length)])
        .join();
  }

  void authenticate() async {
    var codeVerifier = _randomString(50);
    var state = _randomString(20);
    //var responseUrl;

    Client? client;
    client = await _getClient();

    var flow = Flow.authorizationCodeWithPKCE(
      client!,
      scopes: scopes,
      codeVerifier: codeVerifier,
      state: state,
    );
    print("Inside authenticate() : after authorizationCodeWithPKCE");
    flow.redirectUri = Uri.parse(
        '${window.location.protocol}//${window.location.host}${window.location.pathname}');
    print("Inside authenticate() : flow.redirectUri : $flow.redirectUri");

    // redirect to auth server
    window.sessionStorage["auth_code_verifier"] = codeVerifier;
    window.sessionStorage["auth_state"] = state;
    var authorizationUrl = flow.authenticationUri;
    window.location.href = authorizationUrl.toString();
    print("Inside responseUrl == null block");
    throw "Authenticating...";
  }

  Future<void> logOut() async {
    print("Inside logOut");
    final logOutURI = _credential!.generateLogoutUrl().toString();
    _cleanupStorage();
    //print("logOutUri in 2nd app: $logOutURI");
    window.open(logOutURI, '_self');
  }

  void _cleanupStorage() {
    window.sessionStorage.remove("auth_code_verifier");
    window.sessionStorage.remove("auth_callback_response_url");
    window.sessionStorage.remove("auth_state");
  }
}
