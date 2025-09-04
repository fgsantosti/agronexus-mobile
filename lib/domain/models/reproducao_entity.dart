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
  final String? propriedadeId;

  EstacaoMontaEntity({
    required this.id,
    required this.nome,
    required this.dataInicio,
    required this.dataFim,
    this.observacoes,
    required this.ativa,
    required this.totalFemeas,
    required this.taxaPrenhez,
    this.propriedadeId,
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
      propriedadeId: json['propriedade_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nome': nome,
      'data_inicio': dataInicio.toIso8601String().split('T')[0],
      'data_fim': dataFim.toIso8601String().split('T')[0],
      'observacoes': observacoes ?? '', // Enviar string vazia ao invés de null
      'ativa': ativa,
    };

    // Só incluir propriedade_id se não estiver vazio
    if (propriedadeId != null && propriedadeId!.isNotEmpty) {
      data['propriedade_id'] = propriedadeId!;
    }

    // Só incluir id se não estiver vazio (para updates)
    if (id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
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
      animal: AnimalEntity.fromInseminacaoJson(json['animal']),
      dataInseminacao: DateTime.parse(json['data_inseminacao']),
      tipo: TipoInseminacao.fromString(json['tipo']),
      reprodutor: json['reprodutor'] != null ? AnimalEntity.fromInseminacaoJson(json['reprodutor']) : null,
      semenUtilizado: json['semen_utilizado'],
      protocoloIatf: json['protocolo_iatf'] != null ? ProtocoloIATFEntity.fromJson(json['protocolo_iatf']) : null,
      estacaoMonta: json['estacao_monta'] != null ? EstacaoMontaEntity.fromJson(json['estacao_monta']) : null,
      observacoes: json['observacoes'],
      dataDiagnosticoPrevista: json['data_diagnostico_prevista'] != null ? DateTime.parse(json['data_diagnostico_prevista']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'animal_id': animal.id,
      'data_inseminacao': dataInseminacao.toIso8601String().split('T')[0],
      'tipo': tipo.value,
    };

    // Adiciona campos opcionais apenas se não forem null
    if (reprodutor != null) {
      json['reprodutor_id'] = reprodutor!.id;
    }
    if (semenUtilizado != null && semenUtilizado!.isNotEmpty) {
      json['semen_utilizado'] = semenUtilizado;
    }
    if (protocoloIatf != null) {
      json['protocolo_iatf_id'] = protocoloIatf!.id;
    }
    if (estacaoMonta != null) {
      json['estacao_monta_id'] = estacaoMonta!.id;
    }
    if (observacoes != null && observacoes!.isNotEmpty) {
      json['observacoes'] = observacoes;
    }

    return json;
  }
}

class DiagnosticoGestacaoEntity extends BaseEntity {
  final String id;
  final InseminacaoEntity inseminacao;
  final DateTime dataDiagnostico;
  final ResultadoDiagnostico resultado;
  final String metodo;
  final String observacoes;
  final DateTime? dataPartoPrevista;

  DiagnosticoGestacaoEntity({
    required this.id,
    required this.inseminacao,
    required this.dataDiagnostico,
    required this.resultado,
    required this.metodo,
    required this.observacoes,
    this.dataPartoPrevista,
  });

  factory DiagnosticoGestacaoEntity.fromJson(Map<String, dynamic> json) {
    return DiagnosticoGestacaoEntity(
      id: json['id'],
      inseminacao: InseminacaoEntity.fromJson(json['inseminacao']),
      dataDiagnostico: DateTime.parse(json['data_diagnostico']),
      resultado: ResultadoDiagnostico.fromString(json['resultado']),
      metodo: json['metodo'] ?? '',
      observacoes: json['observacoes'] ?? '', // Garantir que não seja null
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
    try {
      return PartoEntity(
        id: json['id'] ?? '',
        mae: AnimalEntity.fromJson(json['mae'] ?? {}),
        dataParto: DateTime.parse(json['data_parto'] ?? DateTime.now().toIso8601String()),
        resultado: ResultadoParto.fromString(json['resultado'] ?? 'nascido_vivo'),
        dificuldade: DificuldadeParto.fromString(json['dificuldade'] ?? 'normal'),
        bezerro: json['bezerro'] != null ? AnimalEntity.fromJson(json['bezerro']) : null,
        pesoNascimento: _parseDouble(json['peso_nascimento']),
        observacoes: json['observacoes'] ?? '',
      );
    } catch (e) {
      print('DEBUG - Erro ao fazer parse do PartoEntity: $e');
      print('DEBUG - JSON recebido: $json');
      rethrow;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('DEBUG - Erro ao converter String para double: $value');
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'mae_id': mae.id,
      'data_parto': dataParto.toIso8601String().split('T')[0],
      'resultado': resultado.value,
      'dificuldade': dificuldade.value,
      'bezerro_id': bezerro?.id,
      'peso_nascimento': pesoNascimento,
      'observacoes': observacoes ?? '',
    };
  }
}

class OpcoesCadastroInseminacao {
  final List<AnimalEntity> femeas;
  final List<AnimalEntity> reprodutores;
  final List<ProtocoloIATFEntity> protocolosIatf;
  final List<EstacaoMontaEntity> estacoesMonta;
  final List<TipoInseminacao> tiposInseminacao;

  OpcoesCadastroInseminacao({
    required this.femeas,
    required this.reprodutores,
    required this.protocolosIatf,
    required this.estacoesMonta,
    required this.tiposInseminacao,
  });

  factory OpcoesCadastroInseminacao.fromJson(Map<String, dynamic> json) {
    // Parse fêmeas de forma segura
    final femeas = <AnimalEntity>[];
    if (json['femeas'] != null) {
      for (var item in (json['femeas'] as List)) {
        try {
          femeas.add(AnimalEntity.fromInseminacaoJson(item));
        } catch (e) {
          print('Warning: Skipping invalid femea: $e');
        }
      }
    }

    // Parse reprodutores de forma segura
    final reprodutores = <AnimalEntity>[];
    if (json['reprodutores'] != null) {
      for (var item in (json['reprodutores'] as List)) {
        try {
          reprodutores.add(AnimalEntity.fromInseminacaoJson(item));
        } catch (e) {
          print('Warning: Skipping invalid reprodutor: $e');
        }
      }
    }

    return OpcoesCadastroInseminacao(
      femeas: femeas,
      reprodutores: reprodutores,
      protocolosIatf: (json['protocolos_iatf'] as List? ?? []).map((e) => ProtocoloIATFEntity.fromJson(e)).toList(),
      estacoesMonta: (json['estacoes_monta'] as List? ?? []).map((e) => EstacaoMontaEntity.fromJson(e)).toList(),
      tiposInseminacao: (json['tipos_inseminacao'] as List? ?? []).map((e) => TipoInseminacao.fromString(e['value'])).toList(),
    );
  }
}

// Novos modelos para estação de monta avançada
class LoteSimples {
  final String id;
  final String nome;
  final String descricao;
  final int totalAnimais;
  final int totalFemeas;
  final String? aptidao;
  final String? finalidade;

  LoteSimples({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.totalAnimais,
    required this.totalFemeas,
    this.aptidao,
    this.finalidade,
  });

  factory LoteSimples.fromJson(Map<String, dynamic> json) {
    return LoteSimples(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'] ?? '',
      totalAnimais: json['total_animais'] ?? 0,
      totalFemeas: json['total_femeas'] ?? 0,
      aptidao: json['aptidao'],
      finalidade: json['finalidade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'total_animais': totalAnimais,
      'total_femeas': totalFemeas,
      'aptidao': aptidao,
      'finalidade': finalidade,
    };
  }
}

class EstacaoMontaDetalhe {
  final EstacaoMontaEntity estacao;
  final List<LoteSimples> lotes;
  final int totalFemeas;
  final int totalInseminacoes;
  final int totalDiagnosticos;
  final int totalPartos;
  final double taxaPrenhez;
  final double taxaParto;

  EstacaoMontaDetalhe({
    required this.estacao,
    required this.lotes,
    required this.totalFemeas,
    required this.totalInseminacoes,
    required this.totalDiagnosticos,
    required this.totalPartos,
    required this.taxaPrenhez,
    required this.taxaParto,
  });

  factory EstacaoMontaDetalhe.fromJson(Map<String, dynamic> json) {
    return EstacaoMontaDetalhe(
      estacao: EstacaoMontaEntity.fromJson(json['estacao']),
      lotes: (json['lotes'] as List? ?? []).map((e) => LoteSimples.fromJson(e)).toList(),
      totalFemeas: json['total_femeas'] ?? 0,
      totalInseminacoes: json['total_inseminacoes'] ?? 0,
      totalDiagnosticos: json['total_diagnosticos'] ?? 0,
      totalPartos: json['total_partos'] ?? 0,
      taxaPrenhez: (json['taxa_prenhez'] ?? 0.0).toDouble(),
      taxaParto: (json['taxa_parto'] ?? 0.0).toDouble(),
    );
  }
}

class DashboardEstacao {
  final String estacaoId;
  final String estacaoNome;
  final int totalFemeas;
  final int inseminacoesRealizadas;
  final int diagnosticosRealizados;
  final int partosRealizados;
  final int inseminacoesPendentes;
  final int diagnosticosPendentes;
  final int partosPendentes;
  final double taxaPrenhez;
  final double taxaParto;
  final double progressoEstacao;
  final List<Map<String, dynamic>> evolucaoTemporal;

  DashboardEstacao({
    required this.estacaoId,
    required this.estacaoNome,
    required this.totalFemeas,
    required this.inseminacoesRealizadas,
    required this.diagnosticosRealizados,
    required this.partosRealizados,
    required this.inseminacoesPendentes,
    required this.diagnosticosPendentes,
    required this.partosPendentes,
    required this.taxaPrenhez,
    required this.taxaParto,
    required this.progressoEstacao,
    required this.evolucaoTemporal,
  });

  factory DashboardEstacao.fromJson(Map<String, dynamic> json) {
    return DashboardEstacao(
      estacaoId: json['estacao_id'],
      estacaoNome: json['estacao_nome'],
      totalFemeas: json['total_femeas'] ?? 0,
      inseminacoesRealizadas: json['inseminacoes_realizadas'] ?? 0,
      diagnosticosRealizados: json['diagnosticos_realizados'] ?? 0,
      partosRealizados: json['partos_realizados'] ?? 0,
      inseminacoesPendentes: json['inseminacoes_pendentes'] ?? 0,
      diagnosticosPendentes: json['diagnosticos_pendentes'] ?? 0,
      partosPendentes: json['partos_pendentes'] ?? 0,
      taxaPrenhez: (json['taxa_prenhez'] ?? 0.0).toDouble(),
      taxaParto: (json['taxa_parto'] ?? 0.0).toDouble(),
      progressoEstacao: (json['progresso_estacao'] ?? 0.0).toDouble(),
      evolucaoTemporal: List<Map<String, dynamic>>.from(json['evolucao_temporal'] ?? []),
    );
  }
}
