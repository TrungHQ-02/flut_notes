import 'package:flut_notes/services/auth/auth_exceptions.dart';
import 'package:flut_notes/services/auth/auth_provider.dart';
import 'package:flut_notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock', () {
    final provider = MockAuthProvider();
    test(
      'Should not be initialized to begin with',
      () => {expect(provider.isInitialized, false)},
    );

    test(
      'Cannot log out if not initialized',
      () {
        expect(
            provider.logOut(), throwsA(const TypeMatcher<NotInitException>()));
      },
    );

    test(
      'Should be able to init',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
    );

    test(
      'User should be null after init',
      () => expect(provider.currentUser, null),
    );

    test(
      'Should be able to init in less than 2 secs',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    // test(
    //   'Create user should be delegate to Login function',
    //   () {
    //     final badEmailUser = provider.createUser(
    //       email: 'foo@bar.com',
    //       password: 'anyPassword',
    //     );

    //     expect(
    //         badEmailUser,
    //         throwsA(
    //           const TypeMatcher<InvalidLoginCredentialsAuthException>(),
    //         ));
    //     final badPasswordUser = provider.createUser(
    //       email: 'email@bar.com',
    //       password: '123456',
    //     );

    //     expect(
    //         badPasswordUser,
    //         throwsA(
    //           const TypeMatcher<InvalidLoginCredentialsAuthException>(),
    //         ));
    //     final validUser = provider.createUser(
    //       email: 'email@bar.com',
    //       password: '123123',
    //     );

    //     expect(provider.currentUser, validUser);
    //   },
    // );

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;

      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
  });
}

class NotInitException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  AuthUser? _user;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser?> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitException();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      return logIn(
        email: email,
        password: password,
      );
    }
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser?> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) {
      throw NotInitException();
    } else {
      if (email == "foo@bar.com" || password == "123456") {
        throw InvalidLoginCredentialsAuthException();
      }
      const user = AuthUser(isEmailVerified: false, email: 'foo@bar.com');
      _user = user;

      return Future.value(user);
    }
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) {
      throw NotInitException();
    }
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) {
      throw NotInitException();
    }

    const newUser = AuthUser(isEmailVerified: true, email: 'foo@bar.com');
    _user = newUser;
  }
}
