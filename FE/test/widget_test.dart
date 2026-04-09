import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_otp_app/main.dart';

void main() {
  testWidgets('App initializes and shows login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoOtpApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Login screen shows email field', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoOtpApp());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
  });

  testWidgets('Login form validates empty email', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoOtpApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your email'), findsOneWidget);
  });
}
