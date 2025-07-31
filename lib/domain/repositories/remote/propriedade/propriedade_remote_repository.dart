import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:dartz/dartz.dart';

abstract class PropriedadeRemoteRepository {
  Future<Either<AgroNexusException, ListBaseEntity<PropriedadeEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? search,
  });
  Future<Either<AgroNexusException, PropriedadeEntity>> get({
    required String id,
  });
  Future<Either<AgroNexusException, PropriedadeEntity>> create({
    required PropriedadeEntity entity,
  });
  Future<Either<AgroNexusException, PropriedadeEntity>> update({
    required PropriedadeEntity entity,
  });
  Future<Either<AgroNexusException, Map<String, dynamic>>> delete({
    required String id,
  });
}
