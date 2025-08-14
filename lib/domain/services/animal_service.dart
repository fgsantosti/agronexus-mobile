import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/opcoes_cadastro_animal.dart';
import 'package:agronexus/domain/repositories/remote/animal/animal_remote_repository.dart';

class AnimalService {
  final AnimalRemoteRepository _repository;

  AnimalService(this._repository);

  Future<List<AnimalEntity>> getAnimais({
    int limit = 20,
    int offset = 0,
    String? search,
    String? especieId,
    String? status,
    String? propriedadeId,
  }) async {
    return await _repository.getAnimais(
      limit: limit,
      offset: offset,
      search: search,
      especieId: especieId,
      status: status,
      propriedadeId: propriedadeId,
    );
  }

  Future<AnimalEntity> getAnimal(String id) async {
    return await _repository.getAnimal(id);
  }

  Future<AnimalEntity> createAnimal(AnimalEntity animal) async {
    return await _repository.createAnimal(animal);
  }

  Future<AnimalEntity> updateAnimal(String id, AnimalEntity animal) async {
    return await _repository.updateAnimal(id, animal);
  }

  Future<void> deleteAnimal(String id) async {
    return await _repository.deleteAnimal(id);
  }

  Future<OpcoesCadastroAnimal> getOpcoesCadastro() async {
    return await _repository.getOpcoesCadastro();
  }

  Future<List<RacaAnimal>> getRacasByEspecie(String especieId) async {
    return await _repository.getRacasByEspecie(especieId);
  }

  Future<List<String>> getCategoriasByEspecie(String especieId) async {
    return await _repository.getCategoriasByEspecie(especieId);
  }

  Future<List<AnimalEntity>> getFilhosDaMae(String maeId, {String? status = 'ativo'}) async {
    return await _repository.getFilhosDaMae(maeId, status: status);
  }
}
