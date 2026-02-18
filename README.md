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
## A. Front End
### 0. Include oidc_module github repo (this repo) in your project's pubspec.yaml:
```yaml
dependencies:
  ....
  ....
  oidc_module:
    git:
      url: https://github.com/ENow-Infomine/oidc_module.git
```
### 1. update global.dart with the below:
import 'package:http/http.dart' as http;

// --- ADD THIS LINE ---
// This will be initialized in main.dart and used in all services
late http.Client api; 

// Navigator key to allow IdleManager to show dialogs anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

### 2. update your main.dart logic as per sampleapp/main.dart in this repo

### 3. In your IDE (VS Code or Android Studio), use Global Search and Replace:
    Search for: http.get( -> Replace with: global.api.get(
    Search for: http.post( -> Replace with: global.api.post(
    .... Repeat for other http. methods like put, delete, ...

## B. Springboot back end
### 1 pom.xml (Add if missing)

Add these to your existing <dependencies> section.
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```
### 2 application.properties (Update)

Update the issuer URI to use a placeholder that Kubernetes can override.
code Properties

# Add or update this line
app.keycloak.base-url=${KEYCLOAK_BASE_URL:https://e-now.infomine.in/kc/realms}

### 3 SecurityConfig.java (New or modify existing)

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
