import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/repositories/remote/propriedade/propriedade_remote_repository.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class PropriedadeService {
  final PropriedadeRemoteRepository remoteRepository;

  PropriedadeService({
    required this.remoteRepository,
  });

  Future<ListBaseEntity<PropriedadeEntity>> listEntities({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (hasConnection == true) {
      final data = await remoteRepository.list(
          limit: limit, offset: offset, search: search);
      return data.getOrElse(() => throw Exception());
    } else {
      // Se não há conexão, retorna lista vazia
      return ListBaseEntity<PropriedadeEntity>.empty();
    }
  }

  Future<PropriedadeEntity> createEntity({required PropriedadeEntity entity}) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (hasConnection == true) {
      final result = await remoteRepository.create(entity: entity);
      result.fold((l) => throw l, (r) {});
      return result.getOrElse(() => throw Exception());
    }
    throw Exception('Sem conexão com a internet');
  }

  Future<PropriedadeEntity> updateEntity({required PropriedadeEntity entity}) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (hasConnection == true) {
      final result = await remoteRepository.update(entity: entity);
      result.fold((l) => throw l, (r) {});
      return result.getOrElse(() => throw Exception());
    }
    throw Exception('Sem conexão com a internet');
  }

  Future<PropriedadeEntity> getEntity({required String id}) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (hasConnection == true) {
      final result = await remoteRepository.get(id: id);
      result.fold((l) => throw l, (r) {});
      return result.getOrElse(() => throw Exception());
    }
    throw Exception('Sem conexão com a internet');
  }

  Future<void> deleteEntity({required String id}) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (hasConnection == true) {
      final result = await remoteRepository.delete(id: id);
      result.fold((l) => throw l, (r) {});
    } else {
      throw Exception('Sem conexão com a internet');
    }
  }
}
