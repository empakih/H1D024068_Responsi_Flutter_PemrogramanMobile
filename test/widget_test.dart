import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart';

void main() {
  testWidgets('WeatherApp renders HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    expect(find.text('Jakarta'), findsOneWidget);
  });
}
