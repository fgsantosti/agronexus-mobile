import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/repositories/local/animal/animal_local_repository.dart';
import 'package:agronexus/domain/repositories/remote/animal/animal_remote_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AnimalService {
  final AnimalRemoteRepository remoteRepository;
  final AnimalLocalRepository localRepository;

  AnimalService({
    required this.remoteRepository,
    required this.localRepository,
  });

  Future<ListBaseEntity<AnimalEntity>> listEntities({
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
      final List<AnimalEntity> data = await localRepository.getAllEntities();
      return ListBaseEntity<AnimalEntity>.empty().copyWith(results: () => data);
    }
  }

  Future<AnimalEntity> createEntity({required AnimalEntity entity}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.create(entity: entity);
      result.fold((l) => throw l, (r) {});
      return result.getOrElse(() => throw Exception());
    }
    localRepository.saveEntity(entity: entity, isSynked: false);
    return entity;
  }

  Future<AnimalEntity> updateEntity({required AnimalEntity entity}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.update(entity: entity);
      result.fold((l) => throw l, (r) {});
      return result.getOrElse(() => throw Exception());
    }
    localRepository.saveEntity(entity: entity, isSynked: false);
    return entity;
  }

  Future<void> deleteEntity({required AnimalEntity entity}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.delete(id: entity.id!);
      result.fold((l) => throw l, (r) {});
    }
  }

  Future<void> sync() async {
    if (await InternetConnection().hasInternetAccess) {
      final List<AnimalEntity> notSynkedEntities =
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

  Future<AnimalEntity> getEntity({required String id}) async {
    bool hasConnetion = await InternetConnection().hasInternetAccess;
    if (hasConnetion == true) {
      final result = await remoteRepository.getById(id: id);
      return result.getOrElse(() => throw Exception());
    }

    return AnimalEntity.empty();
  }
}
