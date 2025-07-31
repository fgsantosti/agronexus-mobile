import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:dartz/dartz.dart';

abstract class FazendaRemoteRepository {
  Future<Either<AgroNexusException, ListBaseEntity<FazendaEntity>>> list({
    int limit = 20,
    int offset = 0,
    String? search,
  });
  Future<Either<AgroNexusException, FazendaEntity>> getById({
    required String id,
  });
  Future<Either<AgroNexusException, FazendaEntity>> create({
    required FazendaEntity entity,
  });
  Future<Either<AgroNexusException, FazendaEntity>> update({
    required FazendaEntity entity,
  });
  Future<Either<AgroNexusException, Map<String, dynamic>>> delete({
    required String id,
  });
}
