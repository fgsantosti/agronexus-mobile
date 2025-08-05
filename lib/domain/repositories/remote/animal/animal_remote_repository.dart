import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/opcoes_cadastro_animal.dart';

abstract class AnimalRemoteRepository {
  Future<List<AnimalEntity>> getAnimais({
    int limit = 20,
    int offset = 0,
    String? search,
    String? especieId,
    String? status,
    String? propriedadeId,
  });

  Future<AnimalEntity> getAnimal(String id);

  Future<AnimalEntity> createAnimal(AnimalEntity animal);

  Future<AnimalEntity> updateAnimal(String id, AnimalEntity animal);

  Future<void> deleteAnimal(String id);

  Future<OpcoesCadastroAnimal> getOpcoesCadastro();

  Future<List<RacaAnimal>> getRacasByEspecie(String especieId);

  Future<List<String>> getCategoriasByEspecie(String especieId);
}
