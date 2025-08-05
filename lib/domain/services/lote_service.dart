import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/domain/repositories/remote/lote/lote_remote_repository.dart';

class LoteService {
  final LoteRemoteRepository _repository;

  LoteService(this._repository);

  Future<List<LoteEntity>> getLotes({String? search}) async {
    return await _repository.getLotes(search: search);
  }

  Future<LoteEntity> getLoteById(String id) async {
    return await _repository.getLoteById(id);
  }

  Future<LoteEntity> createLote(LoteEntity lote) async {
    return await _repository.createLote(lote);
  }

  Future<LoteEntity> updateLote(String id, LoteEntity lote) async {
    return await _repository.updateLote(id, lote);
  }

  Future<void> deleteLote(String id) async {
    return await _repository.deleteLote(id);
  }
}
