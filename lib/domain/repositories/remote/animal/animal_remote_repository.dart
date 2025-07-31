import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AnimalRemoteRepository {
  Future<Either<AgroNexusException, ListBaseEntity<AnimalEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? search,
  });
  Future<Either<AgroNexusException, AnimalEntity>> getById({
    required String id,
  });
  Future<Either<AgroNexusException, AnimalEntity>> create({
    required AnimalEntity entity,
  });
  Future<Either<AgroNexusException, AnimalEntity>> update({
    required AnimalEntity entity,
  });
  Future<Either<AgroNexusException, Map<String, dynamic>>> delete({
    required String id,
  });
}
