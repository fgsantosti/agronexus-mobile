import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/domain/repositories/remote/area/area_remote_repository.dart';

class AreaService {
  final AreaRemoteRepository _repository;
  AreaService(this._repository);

  Future<List<AreaEntity>> getAreas({String? propriedadeId}) {
    return _repository.getAreas(propriedadeId: propriedadeId);
  }

  Future<AreaEntity> createArea(AreaEntity area) {
    return _repository.createArea(area);
  }

  Future<AreaEntity> updateArea(String id, AreaEntity area) {
    return _repository.updateArea(id, area);
  }

  Future<void> deleteArea(String id) {
    return _repository.deleteArea(id);
  }
}
