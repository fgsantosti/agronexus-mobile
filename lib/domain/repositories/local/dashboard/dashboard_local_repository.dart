import 'package:agronexus/domain/models/dashboard_entity.dart';

abstract class DashboardLocalRepository {
  Future<void> saveEntity({
    required DashboardEntity entity,
    required bool isSynked,
  });
  Future<void> saveEntities({
    required List<DashboardEntity> entities,
    required bool isSynked,
  });
  Future<List<DashboardEntity>> getAllEntities();
  Future<List<DashboardEntity>> getSynkedEntities();
  Future<List<DashboardEntity>> getNotSynkedEntities();
  Future<void> deleteSynkedEntities();
  Future<void> deleteNotSynkedEntities();
  Future<void> deleteAllEntities();
}
