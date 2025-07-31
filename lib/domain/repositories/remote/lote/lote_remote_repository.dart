import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:dartz/dartz.dart';

abstract class LoteRemoteRepository {
  Future<Either<AgroNexusException, ListBaseEntity<LoteEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? search,
  });
  Future<Either<AgroNexusException, LoteEntity>> getById({
    required String id,
  });
  Future<Either<AgroNexusException, LoteEntity>> create({
    required LoteEntity entity,
  });
  Future<Either<AgroNexusException, LoteEntity>> update({
    required LoteEntity entity,
  });
  Future<Either<AgroNexusException, Map<String, dynamic>>> delete({
    required String id,
  });
}
