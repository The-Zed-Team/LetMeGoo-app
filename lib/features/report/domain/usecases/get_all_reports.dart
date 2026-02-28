import 'package:letmegoo/core/usecases/usecase.dart';
import 'package:letmegoo/features/report/domain/entities/report.dart';
import 'package:letmegoo/features/report/domain/repositories/report_repository.dart';

/// Use case to get all reports for the current user
class GetAllReports implements UseCase<List<Report>, NoParams> {
  final ReportRepository repository;

  GetAllReports(this.repository);

  @override
  Future<List<Report>> call(NoParams params) async {
    return await repository.getAllReports();
  }
}
