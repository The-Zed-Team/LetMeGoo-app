import 'package:equatable/equatable.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/report/domain/repositories/report_repository.dart';

/// Use case to flag a report
class FlagReport implements UseCase<bool, FlagReportParams> {
  final ReportRepository repository;

  FlagReport(this.repository);

  @override
  Future<bool> call(FlagReportParams params) async {
    return await repository.flagReport(params.reportId);
  }
}

class FlagReportParams extends Equatable {
  final String reportId;

  const FlagReportParams({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}
