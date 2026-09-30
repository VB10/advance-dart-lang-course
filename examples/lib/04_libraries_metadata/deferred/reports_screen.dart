import 'report_contract.dart';

final class ReportsScreen implements ReportView {
  const ReportsScreen();

  @override
  String render() => 'Reports';
}

ReportView createReportsScreen() => const ReportsScreen();
