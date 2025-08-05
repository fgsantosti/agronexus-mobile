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
    return OpcoesCadastroAnimal(
      especies: (json['especies'] as List? ?? []).map((e) => EspecieAnimal.fromJson(e)).toList(),
      racas: (json['racas'] as List? ?? []).map((e) => RacaAnimal.fromJson(e)).toList(),
      propriedades: (json['propriedades'] as List? ?? []).map((e) => PropriedadeSimples.fromJson(e)).toList(),
      lotes: (json['lotes'] as List? ?? []).map((e) => LoteSimples.fromJson(e)).toList(),
      posiveisPais: (json['possiveis_pais'] as List? ?? []).map((e) => AnimalEntity.fromJson(e)).toList(),
      possiveisMaes: (json['possiveis_maes'] as List? ?? []).map((e) => AnimalEntity.fromJson(e)).toList(),
      categorias: (json['categorias'] as List? ?? []).map((e) => e.toString()).toList(),
    );
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
