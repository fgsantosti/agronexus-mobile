import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class UserRemoteRepository {
  Future<Either<AgroNexusException, ListBaseEntity<UserEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? profile,
    String? search,
  });
  Future<Either<AgroNexusException, UserEntity>> getById(String id);
  Future<Either<AgroNexusException, UserEntity>> create({
    required UserEntity entity,
    required String password,
    required String password2,
  });
  Future<Either<AgroNexusException, UserEntity>> update({
    required UserEntity entity,
  });
  Future<Either<AgroNexusException, void>> delete({required String id});
  Future<Either<AgroNexusException, UserEntity>> getSelfUser();
  Future<Either<AgroNexusException, Map<String, dynamic>>> updatePassword({
    required String lastPassword,
    required String password,
    required String password2,
  });
}
