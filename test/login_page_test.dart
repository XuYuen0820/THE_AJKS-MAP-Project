import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_app/features/auth/forgot_password_view.dart';
import 'package:map_app/features/auth/login_view.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(home: LoginView());
  }

  group('LoginView widget tests', () {
    testWidgets('shows email, password, and login controls', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byKey(const Key('exora_logo')), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.text('Stay signed in until you log out'), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('header text is centered', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final title = tester.widget<Text>(find.text('Login'));
      final subtitle = tester.widget<Text>(find.text('Welcome To Exora!'));

      expect(title.textAlign, TextAlign.center);
      expect(subtitle.textAlign, TextAlign.center);
    });

    testWidgets('password visibility button toggles password visibility', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      var passwordField = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byKey(const Key('password_toggle_button')));
      await tester.pump();

      passwordField = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(passwordField.obscureText, isFalse);
    });

    testWidgets('empty submission shows email and password errors', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('forgot password opens the Firebase reset email screen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('forgot_password_button')));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordView), findsOneWidget);
      expect(find.byKey(const Key('reset_email_field')), findsOneWidget);
      expect(find.byKey(const Key('send_reset_email_button')), findsOneWidget);
    });
  });
}
