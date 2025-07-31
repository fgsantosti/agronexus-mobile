import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/domain/repositories/local/lote/lote_local_repository.dart';
import 'package:agronexus/domain/repositories/remote/lote/lote_remote_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class LoteService {
  final LoteRemoteRepository remoteRepository;
  final LoteLocalRepository localRepository;

  LoteService({
    required this.remoteRepository,
    required this.localRepository,
  });

  Future<ListBaseEntity<LoteEntity>> listEntities({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final data = await remoteRepository.list(
          limit: limit, offset: offset, search: search);
      return data.getOrElse(() => throw Exception());
    } else {
      final List<LoteEntity> data = await localRepository.getAllEntities();
      return ListBaseEntity<LoteEntity>.empty().copyWith(results: () => data);
    }
  }

  Future<LoteEntity> createEntity({required LoteEntity entity}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.create(entity: entity);
      result.fold((l) => throw l, (r) {});
      return result.getOrElse(() => throw Exception());
    }
    localRepository.saveEntity(entity: entity, isSynked: false);
    return entity;
  }

  Future<LoteEntity> updateEntity({required LoteEntity entity}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.update(entity: entity);
      result.fold((l) => throw l, (r) {});
      return result.getOrElse(() => throw Exception());
    }
    localRepository.saveEntity(entity: entity, isSynked: false);
    return entity;
  }

  Future<void> deleteEntity({required LoteEntity entity}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.delete(id: entity.id!);
      result.fold((l) => throw l, (r) {});
    }
  }

  Future<void> sync() async {
    if (await InternetConnection().hasInternetAccess) {
      final List<LoteEntity> notSynkedEntities =
          await localRepository.getNotSynkedEntities();
      if (notSynkedEntities.isEmpty) return;
      for (int index = 0; index < notSynkedEntities.length; index++) {
        final result = await remoteRepository.create(
          entity: notSynkedEntities[index],
        );
        try {
          result.fold(
            (l) => throw l,
            (r) {
              notSynkedEntities.removeAt(index);
              localRepository.saveEntities(
                entities: notSynkedEntities,
                isSynked: false,
              );
            },
          );
        } catch (e) {
          if (kDebugMode) print(e);
        }
      }
    }
  }

  Future<LoteEntity> getEntity({required String id}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.getById(id: id);
      return result.getOrElse(() => throw Exception());
    }

    return LoteEntity.empty();
  }
}
