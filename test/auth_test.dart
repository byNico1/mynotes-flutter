import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("AuthService Mockup", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to start", () {
      expect(provider.isInitialized, false);
    });

    test("Throw error if log out begore initialization", () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitialzedException>()));
    });
    test("Should be able to initialize", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test("User should be null after initialization", () async {
      expect(provider.currentUser, null);
    });

    test("Should be able to initialize in less than 2 secs", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
    test("Create user should delegate to logIn function", () async {
      final badEmail =
          provider.createUser(email: "foo@bar.com", password: "123");

      expect(badEmail,
          throwsA(const TypeMatcher<InvalidCredentialsAuthException>()));

      final badPassword =
          provider.createUser(email: "mail@example.com", password: "123");

      expect(badPassword,
          throwsA(const TypeMatcher<InvalidCredentialsAuthException>()));

      final user = await provider.createUser(
          email: "foo@example.com", password: "123456");

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("Logged in user should be able to get verified", () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("Should be able to log out and log in", () async {
      await provider.logOut();
      expect(provider.currentUser, null);

      final user =
          await provider.logIn(email: "email@email.com", password: "12345");
      expect(user, isNotNull);
    });
  });
}

class NotInitialzedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  AuthUser? _user;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitialzedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitialzedException();
    await Future.delayed(const Duration(seconds: 1));
    if (email == "foo") throw InvalidEmailAuthException();
    if (email == "foo@bar.com") throw InvalidCredentialsAuthException();
    if (password == "123") throw InvalidCredentialsAuthException();
    final user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitialzedException();
    await Future.delayed(const Duration(seconds: 1));
    if (_user != null) {
      _user = null;
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitialzedException();
    await Future.delayed(const Duration(seconds: 1));
    if (_user != null) {
      const newUser = AuthUser(isEmailVerified: true);
      _user = newUser;
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
