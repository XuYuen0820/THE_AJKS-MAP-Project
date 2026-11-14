import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_app/pages/admin_page.dart';
import 'package:map_app/pages/invigilator_page.dart';
import 'package:map_app/pages/login_page.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(home: LoginPage());
  }

  group('LoginPage Widget Tests', () {
    testWidgets('Renders all essential components accurately', (
      WidgetTester tester,
    ) async {
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

    testWidgets('Password visibility toggle toggles obscure state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final passwordFieldBefore = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(passwordFieldBefore.obscureText, isTrue);

      await tester.tap(find.byKey(const Key('password_toggle_button')));
      await tester.pump();

      final passwordFieldAfter = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(passwordFieldAfter.obscureText, isFalse);
    });

    testWidgets('Remember me checkbox toggles state on tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      Checkbox checkbox = tester.widget(
        find.byKey(const Key('remember_me_checkbox')),
      );
      expect(checkbox.value, isFalse);

      await tester.tap(find.byKey(const Key('remember_me_checkbox')));
      await tester.pump();

      checkbox = tester.widget(find.byKey(const Key('remember_me_checkbox')));
      expect(checkbox.value, isTrue);
    });

    testWidgets('Empty submission triggers validation errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Please enter your Staff ID'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets(
      'Admin login (admin123/admin123) displays Success view and navigates to AdminPage',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Enter admin test credentials
        await tester.enterText(
          find.byKey(const Key('staff_id_field')),
          'admin123',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'admin123',
        );
        await tester.pump();

        // Tap Log In
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();

        // Wait for login Future.delayed(500ms)
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        // Verify Success view is displayed
        expect(find.byKey(const Key('success_card')), findsOneWidget);
        expect(find.text('Success!'), findsOneWidget);
        expect(
          find.text(
            'Congratulations! You have been successfully authenticated',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('continue_button')), findsOneWidget);

        // Tap Continue button
        await tester.tap(find.byKey(const Key('continue_button')));
        await tester.pumpAndSettle();

        // Verify navigated to AdminPage
        expect(find.byType(AdminPage), findsOneWidget);
        expect(find.text('MR ALI BIN BAKAR'), findsOneWidget);
        expect(find.text('ADMIN'), findsOneWidget);
        expect(
          find.byKey(const Key('admin_action_qr_scanner')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('admin_action_attendance_analysis')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('admin_action_attendance_report')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('admin_action_invigilator_management')),
          findsOneWidget,
        );
        expect(find.text('Upcoming Exam'), findsOneWidget);
        expect(find.text('SECJ3553'), findsOneWidget);

        // Test Logout
        await tester.scrollUntilVisible(
          find.byKey(const Key('logout_button')),
          200,
        );
        await tester.tap(find.byKey(const Key('logout_button')));
        await tester.pumpAndSettle();

        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
      },
    );

    testWidgets(
      'Invigilator login (staff123/staff123) displays Success view and navigates to InvigilatorPage',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Enter staff test credentials
        await tester.enterText(
          find.byKey(const Key('staff_id_field')),
          'staff123',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'staff123',
        );
        await tester.pump();

        // Tap Log In
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pump();

        // Wait for login Future.delayed(500ms)
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        // Verify Success view is displayed
        expect(find.byKey(const Key('success_card')), findsOneWidget);
        expect(find.text('Success!'), findsOneWidget);
        expect(
          find.text(
            'Congratulations! You have been successfully authenticated',
          ),
          findsOneWidget,
        );

        // Tap Continue button
        await tester.tap(find.byKey(const Key('continue_button')));
        await tester.pumpAndSettle();

        // Verify navigated to InvigilatorPage
        expect(find.byType(InvigilatorPage), findsOneWidget);
        expect(find.text('DR TAN BEE LAN'), findsOneWidget);
        expect(find.text('INVIGILATOR'), findsOneWidget);
        expect(
          find.byKey(const Key('invigilator_action_qr_scanner')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('invigilator_action_attendance_analysis')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('invigilator_action_attendance_report')),
          findsOneWidget,
        );
        // Invigilator does not have Invigilator Management
        expect(
          find.byKey(const Key('admin_action_invigilator_management')),
          findsNothing,
        );

        // Test Logout
        await tester.scrollUntilVisible(
          find.byKey(const Key('logout_button')),
          200,
        );
        await tester.tap(find.byKey(const Key('logout_button')));
        await tester.pumpAndSettle();

        expect(find.byType(LoginPage), findsOneWidget);
      },
    );

    testWidgets('Invalid credentials show error SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('staff_id_field')),
        'wrong_user',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrong_pass',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify error snackbar appears and success card is NOT displayed
      expect(find.byKey(const Key('success_card')), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
