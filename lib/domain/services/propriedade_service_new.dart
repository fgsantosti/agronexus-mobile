import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/domain/repositories/remote/propriedade/propriedade_remote_repository.dart';

class PropriedadeServiceNew {
  final PropriedadeRemoteRepository _repository;

  PropriedadeServiceNew(this._repository);

  Future<List<PropriedadeEntity>> getPropriedades({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    return await _repository.getPropriedades(
      limit: limit,
      offset: offset,
      search: search,
    );
  }

  Future<PropriedadeEntity> getPropriedade(String id) async {
    return await _repository.getPropriedade(id);
  }

  Future<PropriedadeEntity> createPropriedade(PropriedadeEntity propriedade) async {
    return await _repository.createPropriedade(propriedade);
  }

  Future<PropriedadeEntity> updatePropriedade(String id, PropriedadeEntity propriedade) async {
    return await _repository.updatePropriedade(id, propriedade);
  }

  Future<void> deletePropriedade(String id) async {
    return await _repository.deletePropriedade(id);
  }
}
