import 'package:agronexus/domain/models/area_entity.dart';

abstract class AreaRemoteRepository {
  Future<List<AreaEntity>> getAreas({String? propriedadeId});
  Future<AreaEntity> createArea(AreaEntity area);
  Future<AreaEntity> updateArea(String id, AreaEntity area);
  Future<void> deleteArea(String id);
}
