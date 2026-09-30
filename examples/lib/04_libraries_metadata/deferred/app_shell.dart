import 'report_contract.dart';
import 'reports_screen.dart' deferred as reports;

Future<ReportView> openReports() async {
  await reports.loadLibrary(); // Safe to call repeatedly; loads once.
  return reports.createReportsScreen();
}
