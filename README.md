<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

## 0. Include this repo in your project's pubspec.yaml:
  oidc_module:
    git:
      url: https://github.com/ENow-Infomine/oidc_module.git

## 1. update your main.dart else logic of if (userInfo == null):

// Initialize the AuthorizedClient using the credential from your singleton
    final authClient = AuthorizedClient(oidcClient.credential);

    runApp(
      MultiProvider(
        providers: [
          // Provide the client so any page can use it
          Provider<http.Client>.value(value: authClient),
          // Also provide userInfo if you need it for the UI
          Provider<UserInfo>.value(value: userInfo),
        ],
        child: MyApp(),
      ),
    );
  }

## 2. Usage in your pages:
class YourPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the client (it will be an instance of AuthorizedClient)
    final client = Provider.of<http.Client>(context);

    return ElevatedButton(
      onPressed: () async {
        // This call automatically includes the Bearer token and handles refresh!
        final response = await client.get(Uri.parse("https://api.myapp.com/user/profile"));
        print(response.body);
      },
      child: Text("Load Profile"),
    );
  }
}

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
