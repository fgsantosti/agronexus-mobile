import 'package:agronexus/domain/models/lote_entity.dart';

abstract class LoteLocalRepository {
  Future<void> saveEntity({
    required LoteEntity entity,
    required bool isSynked,
  });
  Future<void> saveEntities({
    required List<LoteEntity> entities,
    required bool isSynked,
  });
  Future<List<LoteEntity>> getAllEntities();
  Future<List<LoteEntity>> getSynkedEntities();
  Future<List<LoteEntity>> getNotSynkedEntities();
  Future<void> deleteSynkedEntities();
  Future<void> deleteNotSynkedEntities();
  Future<void> deleteAllEntities();
}
