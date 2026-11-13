import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_app/pages/login_page.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: LoginPage(),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('Renders all essential components accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify Logo
      expect(find.byKey(const Key('exora_logo')), findsOneWidget);
      expect(find.byKey(const Key('app_icon')), findsOneWidget);
      expect(find.byKey(const Key('logo_text')), findsOneWidget);

      // Verify Headers
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Welcome To Exora!'), findsOneWidget);

      // Verify Form fields & buttons
      expect(find.byKey(const Key('staff_id_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('remember_me_checkbox')), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('Header texts are center-aligned', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final titleText = tester.widget<Text>(find.text('Login'));
      final subtitleText = tester.widget<Text>(find.text('Welcome To Exora!'));

      expect(titleText.textAlign, TextAlign.center);
      expect(subtitleText.textAlign, TextAlign.center);
    });

    testWidgets('Password visibility toggle toggles obscure state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final passwordFieldBefore =
          tester.widget<EditableText>(find.byType(EditableText).last);
      expect(passwordFieldBefore.obscureText, isTrue);

      await tester.tap(find.byKey(const Key('password_toggle_button')));
      await tester.pump();

      final passwordFieldAfter =
          tester.widget<EditableText>(find.byType(EditableText).last);
      expect(passwordFieldAfter.obscureText, isFalse);
    });

    testWidgets('Remember me checkbox toggles state on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      Checkbox checkbox = tester.widget(find.byKey(const Key('remember_me_checkbox')));
      expect(checkbox.value, isFalse);

      await tester.tap(find.byKey(const Key('remember_me_checkbox')));
      await tester.pump();

      checkbox = tester.widget(find.byKey(const Key('remember_me_checkbox')));
      expect(checkbox.value, isTrue);
    });

    testWidgets('Empty submission triggers validation errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Please enter your Staff ID'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });
}
