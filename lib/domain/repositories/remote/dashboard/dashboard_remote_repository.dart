import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/domain/models/dashboard_entity.dart';
import 'package:dartz/dartz.dart';

abstract class DashboardRemoteRepository {
  Future<Either<AgroNexusException, DashboardEntity>> get();
}
