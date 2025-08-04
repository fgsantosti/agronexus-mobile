import 'package:agronexus/domain/models/propriedade_entity.dart';

abstract class PropriedadeRemoteRepository {
  Future<List<PropriedadeEntity>> getPropriedades({
    int limit = 20,
    int offset = 0,
    String? search,
  });
  Future<PropriedadeEntity> getPropriedade(String id);
  Future<PropriedadeEntity> createPropriedade(PropriedadeEntity propriedade);
  Future<PropriedadeEntity> updatePropriedade(String id, PropriedadeEntity propriedade);
  Future<void> deletePropriedade(String id);
}
