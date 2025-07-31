import 'package:agronexus/domain/models/user_entity.dart';

abstract class UserLocalRepository {
  Future<void> saveSelfEntity(UserEntity user);
  Future<UserEntity> getSelfEntity();
  Future<void> deleteSelfEntity();
  Future<void> saveAllEntities(List<UserEntity> user);
  Future<List<UserEntity>> getAllEntities();
  Future<void> deleteAllEntities();
}
