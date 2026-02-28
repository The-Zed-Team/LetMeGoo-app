import 'package:equatable/equatable.dart';
import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/report/domain/entities/report.dart';
import 'package:letmegoo/features/report/domain/repositories/report_repository.dart';

/// Use case to mark a report as solved
class MarkReportAsSolved implements UseCase<Report, MarkReportAsSolvedParams> {
  final ReportRepository repository;

  MarkReportAsSolved(this.repository);

  @override
  Future<Report> call(MarkReportAsSolvedParams params) async {
    return await repository.markReportAsSolved(params.reportId);
  }
}

class MarkReportAsSolvedParams extends Equatable {
  final String reportId;

  const MarkReportAsSolvedParams({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}
