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

  /// Carrega todos os animais para exportação, sem limitação de paginação
  Future<List<AnimalEntity>> getAllAnimaisForExport({
    String? search,
    String? especieId,
    String? status,
    String? propriedadeId,
  });

  Future<List<RacaAnimal>> getRacasByEspecie(String especieId);

  Future<List<String>> getCategoriasByEspecie(String especieId);

  /// Busca animais fêmeas para seleção como mães
  Future<List<AnimalEntity>> getFemeas({
    String? propriedadeId,
    String? especieId,
    String? status = 'ativo',
  });

  /// Busca animais machos para seleção como pais/reprodutores
  Future<List<AnimalEntity>> getMachos({
    String? propriedadeId,
    String? especieId,
    String? status = 'ativo',
  });

  /// Busca animais filhos de uma mãe específica
  Future<List<AnimalEntity>> getFilhosDaMae(String maeId, {String? status = 'ativo'});
}
