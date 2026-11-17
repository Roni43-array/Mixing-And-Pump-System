import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'services/firebase_scada_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mengunci orientasi portrait & mengatur status bar terang untuk iOS
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  final scadaService = FirebaseScadaService();
  await scadaService.initialize();

  runApp(MixingPumpIosApp(scadaService: scadaService));
}

class MixingPumpIosApp extends StatefulWidget {
  final FirebaseScadaService scadaService;

  const MixingPumpIosApp({
    super.key,
    required this.scadaService,
  });

  @override
  State<MixingPumpIosApp> createState() => _MixingPumpIosAppState();
}

class _MixingPumpIosAppState extends State<MixingPumpIosApp> {
  @override
  void dispose() {
    widget.scadaService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Mixing & Pump iOS SCADA',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF38BDF8),
        scaffoldBackgroundColor: Color(0xFF0F172A),
        barBackgroundColor: Color(0xFF0F172A),
      ),
      home: DashboardScreen(scadaService: widget.scadaService),
    );
  }
}
