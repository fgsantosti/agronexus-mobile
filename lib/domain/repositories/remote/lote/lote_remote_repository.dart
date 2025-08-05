import 'package:agronexus/domain/models/lote_entity.dart';

abstract class LoteRemoteRepository {
  Future<List<LoteEntity>> getLotes({String? search});
  Future<LoteEntity> getLoteById(String id);
  Future<LoteEntity> createLote(LoteEntity lote);
  Future<LoteEntity> updateLote(String id, LoteEntity lote);
  Future<void> deleteLote(String id);
}
