import 'package:agronexus/domain/models/fazenda_entity.dart';

abstract class FazendaLocalRepository {
  Future<void> saveEntity({
    required FazendaEntity entity,
    required bool isSynked,
  });
  Future<void> saveEntities({
    required List<FazendaEntity> entities,
    required bool isSynked,
  });
  Future<List<FazendaEntity>> getAllEntities();
  Future<List<FazendaEntity>> getSynkedEntities();
  Future<List<FazendaEntity>> getNotSynkedEntities();
  Future<void> deleteSynkedEntities();
  Future<void> deleteNotSynkedEntities();
  Future<void> deleteAllEntities();
}
