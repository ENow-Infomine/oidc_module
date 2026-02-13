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
dependencies:
  ....
  ....
  oidc_module:
    git:
      url: https://github.com/ENow-Infomine/oidc_module.git

## 1. update your main.dart else logic of if (userInfo == null):
```dart
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
```

## 2. Usage in your pages:
```dart
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
```
1. Backend: Spring Boot Changes
___________________________________________________________
1.1 pom.xml (Add if missing)

Add these to your existing <dependencies> section.

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
__________________________________________________________
1.2 application.properties (Update)

Update the issuer URI to use a placeholder that Kubernetes can override.
code Properties

# Add or update this line
app.keycloak.base-url=${KEYCLOAK_BASE_URL:https://e-now.infomine.in/kc/realms/master}
__________________________________________________________
1.3 SecurityConfig.java (New or modify existing)

This is where the environment toggle lives. Create this class or update your existing Security configuration.
```java
import org.springframework.security.authentication.AuthenticationManagerResolver;
import org.springframework.security.oauth2.server.resource.authentication.JwtIssuerAuthenticationManagerResolver;
import org.springframework.beans.factory.annotation.Value; // Import this
// ... other imports

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // Inject the property from application.properties / Env Var
    @Value("${app.keycloak.base-url}")
    private String keycloakBaseUrl;

    @Bean
    @Profile("!no-auth")
    public SecurityFilterChain prodFilterChain(HttpSecurity http) throws Exception {
        
        // This resolver dynamically validates any realm under your base URL
        AuthenticationManagerResolver<HttpServletRequest> authenticationManagerResolver = 
            new JwtIssuerAuthenticationManagerResolver(issuer -> {
                if (issuer != null && issuer.startsWith(keycloakBaseUrl)) {
                    return issuer; 
                }
                throw new IllegalArgumentException("Unknown or Unauthorized Issuer: " + issuer);
            });

        http
            .cors(Customizer.withDefaults())
            .authorizeHttpRequests(auth -> auth.anyRequest().authenticated())
            .oauth2ResourceServer(oauth -> oauth.authenticationManagerResolver(authenticationManagerResolver));
        
        return http.build();
    }

    // Dev profile remains the same (permit all)
    @Bean
    @Profile("no-auth")
    public SecurityFilterChain devFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(Customizer.withDefaults())
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
        return http.build();
    }
}
```
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
