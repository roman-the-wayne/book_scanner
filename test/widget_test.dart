import 'package:book_scanner/core/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_scanner/core/di/injection_container.dart' as di;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: '.env');
    await di.init();
  });

  testWidgets('App router smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));

    // Verify bottom navigation items exist.
    expect(find.text('Поиск по фото'), findsOneWidget);
    expect(find.text('Библиотека'), findsOneWidget);
  });
}
