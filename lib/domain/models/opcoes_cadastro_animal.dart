import 'package:agronexus/domain/models/animal_entity.dart';

class OpcoesCadastroAnimal {
  final List<EspecieAnimal> especies;
  final List<RacaAnimal> racas;
  final List<PropriedadeSimples> propriedades;
  final List<LoteSimples> lotes;
  final List<AnimalEntity> posiveisPais;
  final List<AnimalEntity> possiveisMaes;
  final List<String> categorias;

  const OpcoesCadastroAnimal({
    required this.especies,
    required this.racas,
    required this.propriedades,
    required this.lotes,
    required this.posiveisPais,
    required this.possiveisMaes,
    required this.categorias,
  });

  factory OpcoesCadastroAnimal.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Fazendo parse de espécies...');
      final especies = (json['especies'] as List? ?? []).map((e) {
        try {
          return EspecieAnimal.fromJson(e);
        } catch (ex) {
          print('❌ Erro no parse de espécie: $ex - JSON: $e');
          rethrow;
        }
      }).toList();
      print('✅ Espécies parseadas: ${especies.length}');

      print('🔍 Fazendo parse de raças...');
      final racas = (json['racas'] as List? ?? []).map((e) {
        try {
          return RacaAnimal.fromJson(e);
        } catch (ex) {
          print('❌ Erro no parse de raça: $ex - JSON: $e');
          rethrow;
        }
      }).toList();
      print('✅ Raças parseadas: ${racas.length}');

      print('🔍 Fazendo parse de propriedades...');
      final propriedades = (json['propriedades'] as List? ?? []).map((e) {
        try {
          return PropriedadeSimples.fromJson(e);
        } catch (ex) {
          print('❌ Erro no parse de propriedade: $ex - JSON: $e');
          rethrow;
        }
      }).toList();
      print('✅ Propriedades parseadas: ${propriedades.length}');

      print('🔍 Fazendo parse de lotes...');
      final lotes = (json['lotes'] as List? ?? []).map((e) {
        try {
          return LoteSimples.fromJson(e);
        } catch (ex) {
          print('❌ Erro no parse de lote: $ex - JSON: $e');
          rethrow;
        }
      }).toList();
      print('✅ Lotes parseados: ${lotes.length}');

      print('🔍 Fazendo parse de animais para pais...');
      final posiveisPais = (json['possiveis_pais'] as List? ?? [])
          .map((e) {
            try {
              return AnimalEntity.fromJson(e);
            } catch (ex) {
              print('❌ Erro no parse de animal pai: $ex');
              // Não parar o processo por erro em animal individual
              return null;
            }
          })
          .where((e) => e != null)
          .cast<AnimalEntity>()
          .toList();
      print('✅ Animais pais parseados: ${posiveisPais.length}');

      print('🔍 Fazendo parse de animais para mães...');
      final possiveisMaes = (json['possiveis_maes'] as List? ?? [])
          .map((e) {
            try {
              return AnimalEntity.fromJson(e);
            } catch (ex) {
              print('❌ Erro no parse de animal mãe: $ex');
              // Não parar o processo por erro em animal individual
              return null;
            }
          })
          .where((e) => e != null)
          .cast<AnimalEntity>()
          .toList();
      print('✅ Animais mães parseados: ${possiveisMaes.length}');

      final categorias = (json['categorias'] as List? ?? []).map((e) => e.toString()).toList();
      print('✅ Categorias parseadas: ${categorias.length}');

      return OpcoesCadastroAnimal(
        especies: especies,
        racas: racas,
        propriedades: propriedades,
        lotes: lotes,
        posiveisPais: posiveisPais,
        possiveisMaes: possiveisMaes,
        categorias: categorias,
      );
    } catch (e) {
      print('❌ Erro geral ao fazer parse de OpcoesCadastroAnimal: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'especies': especies.map((e) => e.toJson()).toList(),
      'racas': racas.map((e) => e.toJson()).toList(),
      'propriedades': propriedades.map((e) => e.toJson()).toList(),
      'lotes': lotes.map((e) => e.toJson()).toList(),
      'possiveis_pais': posiveisPais.map((e) => e.toJson()).toList(),
      'possiveis_maes': possiveisMaes.map((e) => e.toJson()).toList(),
      'categorias': categorias,
    };
  }

  const OpcoesCadastroAnimal.empty()
      : especies = const [],
        racas = const [],
        propriedades = const [],
        lotes = const [],
        posiveisPais = const [],
        possiveisMaes = const [],
        categorias = const [];
}
