import 'package:agronexus/domain/models/animal_entity.dart';

abstract class AnimalLocalRepository {
  Future<void> saveEntity({
    required AnimalEntity entity,
    required bool isSynked,
  });
  Future<void> saveEntities({
    required List<AnimalEntity> entities,
    required bool isSynked,
  });
  Future<List<AnimalEntity>> getAllEntities();
  Future<List<AnimalEntity>> getSynkedEntities();
  Future<List<AnimalEntity>> getNotSynkedEntities();
  Future<void> deleteSynkedEntities();
  Future<void> deleteNotSynkedEntities();
  Future<void> deleteAllEntities();
}
