import 'package:agronexus/domain/models/dashboard_entity.dart';
import 'package:agronexus/domain/repositories/local/dashboard/dashboard_local_repository.dart';
import 'package:agronexus/domain/repositories/remote/dashboard/dashboard_remote_repository.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class DashboardService {
  final DashboardRemoteRepository remoteRepository;
  final DashboardLocalRepository localRepository;

  DashboardService({
    required this.remoteRepository,
    required this.localRepository,
  });

  Future<DashboardEntity> getEntity() async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.get();
      return result.getOrElse(() => throw Exception());
    }

    return DashboardEntity.empty();
  }
}
