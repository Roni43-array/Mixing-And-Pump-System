import 'package:flutter_test/flutter_test.dart';
import 'package:mixing_pump_ios_scada/main.dart';
import 'package:mixing_pump_ios_scada/services/firebase_scada_service.dart';

void main() {
  testWidgets('Menampilkan kontrol Mixer dan Pump beserta PID',
      (WidgetTester tester) async {
    final service = FirebaseScadaService();
    await service.initialize();

    await tester.pumpWidget(MixingPumpIosApp(scadaService: service));

    expect(find.text('UNIT MIXER AGITATOR'), findsOneWidget);
    expect(find.text('START MIXER'), findsOneWidget);
    expect(find.text('STOP MIXER'), findsOneWidget);

    expect(find.text('UNIT TRANSFER PUMP & PID'), findsOneWidget);
    expect(find.text('START PUMP'), findsOneWidget);
    expect(find.text('STOP PUMP'), findsOneWidget);
    expect(find.text('PRESSURE MONITOR (PV vs SV)'), findsOneWidget);
    expect(find.text('PID CONTROLLER'), findsOneWidget);

    service.dispose();
  });
}
