import 'package:agronexus/domain/models/base_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';

enum TipoInseminacao {
  natural(label: 'Monta Natural', value: 'natural'),
  ia(label: 'Inseminação Artificial', value: 'ia'),
  iatf(label: 'IATF', value: 'iatf');

  final String label;
  final String value;

  const TipoInseminacao({required this.label, required this.value});

  static TipoInseminacao fromString(String value) {
    switch (value) {
      case 'natural':
        return TipoInseminacao.natural;
      case 'ia':
        return TipoInseminacao.ia;
      case 'iatf':
        return TipoInseminacao.iatf;
      default:
        throw Exception('Invalid TipoInseminacao value: $value');
    }
  }
}

enum ResultadoDiagnostico {
  positivo(label: 'Positivo', value: 'positivo'),
  negativo(label: 'Negativo', value: 'negativo'),
  inconclusivo(label: 'Inconclusivo', value: 'inconclusivo');

  final String label;
  final String value;

  const ResultadoDiagnostico({required this.label, required this.value});

  static ResultadoDiagnostico fromString(String value) {
    switch (value) {
      case 'positivo':
        return ResultadoDiagnostico.positivo;
      case 'negativo':
        return ResultadoDiagnostico.negativo;
      case 'inconclusivo':
        return ResultadoDiagnostico.inconclusivo;
      default:
        throw Exception('Invalid ResultadoDiagnostico value: $value');
    }
  }
}

enum ResultadoParto {
  nascidoVivo(label: 'Nascido Vivo', value: 'nascido_vivo'),
  aborto(label: 'Aborto', value: 'aborto'),
  natimorto(label: 'Natimorto', value: 'natimorto');

  final String label;
  final String value;

  const ResultadoParto({required this.label, required this.value});

  static ResultadoParto fromString(String value) {
    switch (value) {
      case 'nascido_vivo':
        return ResultadoParto.nascidoVivo;
      case 'aborto':
        return ResultadoParto.aborto;
      case 'natimorto':
        return ResultadoParto.natimorto;
      default:
        throw Exception('Invalid ResultadoParto value: $value');
    }
  }
}

enum DificuldadeParto {
  normal(label: 'Normal', value: 'normal'),
  assistido(label: 'Assistido', value: 'assistido'),
  cesariana(label: 'Cesariana', value: 'cesariana');

  final String label;
  final String value;

  const DificuldadeParto({required this.label, required this.value});

  static DificuldadeParto fromString(String value) {
    switch (value) {
      case 'normal':
        return DificuldadeParto.normal;
      case 'assistido':
        return DificuldadeParto.assistido;
      case 'cesariana':
        return DificuldadeParto.cesariana;
      default:
        throw Exception('Invalid DificuldadeParto value: $value');
    }
  }
}

class EstacaoMontaEntity extends BaseEntity {
  final String id;
  final String nome;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? observacoes;
  final bool ativa;
  final int totalFemeas;
  final double taxaPrenhez;

  EstacaoMontaEntity({
    required this.id,
    required this.nome,
    required this.dataInicio,
    required this.dataFim,
    this.observacoes,
    required this.ativa,
    required this.totalFemeas,
    required this.taxaPrenhez,
  });

  factory EstacaoMontaEntity.fromJson(Map<String, dynamic> json) {
    return EstacaoMontaEntity(
      id: json['id'],
      nome: json['nome'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      observacoes: json['observacoes'],
      ativa: json['ativa'] ?? true,
      totalFemeas: json['total_femeas'] ?? 0,
      taxaPrenhez: (json['taxa_prenhez'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data_inicio': dataInicio.toIso8601String().split('T')[0],
      'data_fim': dataFim.toIso8601String().split('T')[0],
      'observacoes': observacoes,
      'ativa': ativa,
    };
  }
}

class ProtocoloIATFEntity extends BaseEntity {
  final String id;
  final String nome;
  final String descricao;
  final int duracaoDias;
  final Map<String, dynamic> passosProtocolo;
  final bool ativo;

  ProtocoloIATFEntity({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.duracaoDias,
    required this.passosProtocolo,
    required this.ativo,
  });

  factory ProtocoloIATFEntity.fromJson(Map<String, dynamic> json) {
    return ProtocoloIATFEntity(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      duracaoDias: json['duracao_dias'],
      passosProtocolo: json['passos_protocolo'] ?? {},
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'duracao_dias': duracaoDias,
      'passos_protocolo': passosProtocolo,
      'ativo': ativo,
    };
  }
}

class InseminacaoEntity extends BaseEntity {
  final String id;
  final AnimalEntity animal;
  final DateTime dataInseminacao;
  final TipoInseminacao tipo;
  final AnimalEntity? reprodutor;
  final String? semenUtilizado;
  final ProtocoloIATFEntity? protocoloIatf;
  final EstacaoMontaEntity? estacaoMonta;
  final String? observacoes;
  final DateTime? dataDiagnosticoPrevista;

  InseminacaoEntity({
    required this.id,
    required this.animal,
    required this.dataInseminacao,
    required this.tipo,
    this.reprodutor,
    this.semenUtilizado,
    this.protocoloIatf,
    this.estacaoMonta,
    this.observacoes,
    this.dataDiagnosticoPrevista,
  });

  factory InseminacaoEntity.fromJson(Map<String, dynamic> json) {
    return InseminacaoEntity(
      id: json['id'],
      animal: AnimalEntity.fromJson(json['animal']),
      dataInseminacao: DateTime.parse(json['data_inseminacao']),
      tipo: TipoInseminacao.fromString(json['tipo']),
      reprodutor: json['reprodutor'] != null ? AnimalEntity.fromJson(json['reprodutor']) : null,
      semenUtilizado: json['semen_utilizado'],
      protocoloIatf: json['protocolo_iatf'] != null ? ProtocoloIATFEntity.fromJson(json['protocolo_iatf']) : null,
      estacaoMonta: json['estacao_monta'] != null ? EstacaoMontaEntity.fromJson(json['estacao_monta']) : null,
      observacoes: json['observacoes'],
      dataDiagnosticoPrevista: json['data_diagnostico_prevista'] != null ? DateTime.parse(json['data_diagnostico_prevista']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animal_id': animal.idAnimal,
      'data_inseminacao': dataInseminacao.toIso8601String().split('T')[0],
      'tipo': tipo.value,
      'reprodutor_id': reprodutor?.idAnimal,
      'semen_utilizado': semenUtilizado,
      'protocolo_iatf_id': protocoloIatf?.id,
      'estacao_monta_id': estacaoMonta?.id,
      'observacoes': observacoes,
    };
  }
}

class DiagnosticoGestacaoEntity extends BaseEntity {
  final String id;
  final InseminacaoEntity inseminacao;
  final DateTime dataDiagnostico;
  final ResultadoDiagnostico resultado;
  final String? metodo;
  final String? observacoes;
  final DateTime? dataPartoPrevista;

  DiagnosticoGestacaoEntity({
    required this.id,
    required this.inseminacao,
    required this.dataDiagnostico,
    required this.resultado,
    this.metodo,
    this.observacoes,
    this.dataPartoPrevista,
  });

  factory DiagnosticoGestacaoEntity.fromJson(Map<String, dynamic> json) {
    return DiagnosticoGestacaoEntity(
      id: json['id'],
      inseminacao: InseminacaoEntity.fromJson(json['inseminacao']),
      dataDiagnostico: DateTime.parse(json['data_diagnostico']),
      resultado: ResultadoDiagnostico.fromString(json['resultado']),
      metodo: json['metodo'],
      observacoes: json['observacoes'],
      dataPartoPrevista: json['data_parto_prevista'] != null ? DateTime.parse(json['data_parto_prevista']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inseminacao_id': inseminacao.id,
      'data_diagnostico': dataDiagnostico.toIso8601String().split('T')[0],
      'resultado': resultado.value,
      'metodo': metodo,
      'observacoes': observacoes,
    };
  }
}

class PartoEntity extends BaseEntity {
  final String id;
  final AnimalEntity mae;
  final DateTime dataParto;
  final ResultadoParto resultado;
  final DificuldadeParto dificuldade;
  final AnimalEntity? bezerro;
  final double? pesoNascimento;
  final String? observacoes;

  PartoEntity({
    required this.id,
    required this.mae,
    required this.dataParto,
    required this.resultado,
    required this.dificuldade,
    this.bezerro,
    this.pesoNascimento,
    this.observacoes,
  });

  factory PartoEntity.fromJson(Map<String, dynamic> json) {
    return PartoEntity(
      id: json['id'],
      mae: AnimalEntity.fromJson(json['mae']),
      dataParto: DateTime.parse(json['data_parto']),
      resultado: ResultadoParto.fromString(json['resultado']),
      dificuldade: DificuldadeParto.fromString(json['dificuldade']),
      bezerro: json['bezerro'] != null ? AnimalEntity.fromJson(json['bezerro']) : null,
      pesoNascimento: json['peso_nascimento']?.toDouble(),
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mae_id': mae.idAnimal,
      'data_parto': dataParto.toIso8601String().split('T')[0],
      'resultado': resultado.value,
      'dificuldade': dificuldade.value,
      'bezerro_id': bezerro?.idAnimal,
      'peso_nascimento': pesoNascimento,
      'observacoes': observacoes,
    };
  }
}
