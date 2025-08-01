import 'package:agronexus/domain/models/animal_entity.dart';

class EstacaoMonta {
  final String id;
  final String propriedadeId;
  final String nome;
  final DateTime dataInicio;
  final DateTime dataFim;
  final List<String> lotesParticipantes;
  final String? observacoes;
  final bool ativa;

  EstacaoMonta({
    required this.id,
    required this.propriedadeId,
    required this.nome,
    required this.dataInicio,
    required this.dataFim,
    required this.lotesParticipantes,
    this.observacoes,
    required this.ativa,
  });

  factory EstacaoMonta.fromJson(Map<String, dynamic> json) {
    return EstacaoMonta(
      id: json['id'],
      propriedadeId: json['propriedade_id'],
      nome: json['nome'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      lotesParticipantes: List<String>.from(json['lotes_participantes'] ?? []),
      observacoes: json['observacoes'],
      ativa: json['ativa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propriedade_id': propriedadeId,
      'nome': nome,
      'data_inicio': dataInicio.toIso8601String().split('T')[0],
      'data_fim': dataFim.toIso8601String().split('T')[0],
      'lotes_participantes': lotesParticipantes,
      'observacoes': observacoes,
      'ativa': ativa,
    };
  }
}

class ProtocoloIATF {
  final String id;
  final String propriedadeId;
  final String nome;
  final String descricao;
  final int duracaoDias;
  final Map<String, dynamic> passosProtocolo;
  final bool ativo;

  ProtocoloIATF({
    required this.id,
    required this.propriedadeId,
    required this.nome,
    required this.descricao,
    required this.duracaoDias,
    required this.passosProtocolo,
    required this.ativo,
  });

  factory ProtocoloIATF.fromJson(Map<String, dynamic> json) {
    return ProtocoloIATF(
      id: json['id'],
      propriedadeId: json['propriedade_id'],
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
      'propriedade_id': propriedadeId,
      'nome': nome,
      'descricao': descricao,
      'duracao_dias': duracaoDias,
      'passos_protocolo': passosProtocolo,
      'ativo': ativo,
    };
  }
}

enum TipoInseminacao { natural, ia, iatf }

class Inseminacao {
  final String id;
  final String animalId;
  final String manejoId;
  final DateTime dataInseminacao;
  final TipoInseminacao tipo;
  final String? reprodutorId;
  final String? semenUtilizado;
  final String? protocoloIatfId;
  final String? estacaoMontaId;
  final String? observacoes;

  // Dados calculados
  AnimalEntity? animal;
  AnimalEntity? reprodutor;
  ProtocoloIATF? protocoloIatf;
  EstacaoMonta? estacaoMonta;

  Inseminacao({
    required this.id,
    required this.animalId,
    required this.manejoId,
    required this.dataInseminacao,
    required this.tipo,
    this.reprodutorId,
    this.semenUtilizado,
    this.protocoloIatfId,
    this.estacaoMontaId,
    this.observacoes,
    this.animal,
    this.reprodutor,
    this.protocoloIatf,
    this.estacaoMonta,
  });

  factory Inseminacao.fromJson(Map<String, dynamic> json) {
    return Inseminacao(
      id: json['id'],
      animalId: json['animal_id'],
      manejoId: json['manejo_id'],
      dataInseminacao: DateTime.parse(json['data_inseminacao']),
      tipo: TipoInseminacao.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoInseminacao.natural,
      ),
      reprodutorId: json['reprodutor_id'],
      semenUtilizado: json['semen_utilizado'],
      protocoloIatfId: json['protocolo_iatf_id'],
      estacaoMontaId: json['estacao_monta_id'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_id': animalId,
      'manejo_id': manejoId,
      'data_inseminacao': dataInseminacao.toIso8601String().split('T')[0],
      'tipo': tipo.name,
      'reprodutor_id': reprodutorId,
      'semen_utilizado': semenUtilizado,
      'protocolo_iatf_id': protocoloIatfId,
      'estacao_monta_id': estacaoMontaId,
      'observacoes': observacoes,
    };
  }

  DateTime get dataDiagnosticoPrevista {
    return dataInseminacao.add(Duration(days: 35));
  }

  String get tipoDisplay {
    switch (tipo) {
      case TipoInseminacao.natural:
        return 'Monta Natural';
      case TipoInseminacao.ia:
        return 'Inseminação Artificial';
      case TipoInseminacao.iatf:
        return 'IATF';
    }
  }
}

enum ResultadoDiagnostico { positivo, negativo, inconclusivo }

class DiagnosticoGestacao {
  final String id;
  final String inseminacaoId;
  final String manejoId;
  final DateTime dataDiagnostico;
  final ResultadoDiagnostico resultado;
  final String? metodo;
  final String? observacoes;

  // Dados relacionados
  Inseminacao? inseminacao;

  DiagnosticoGestacao({
    required this.id,
    required this.inseminacaoId,
    required this.manejoId,
    required this.dataDiagnostico,
    required this.resultado,
    this.metodo,
    this.observacoes,
    this.inseminacao,
  });

  factory DiagnosticoGestacao.fromJson(Map<String, dynamic> json) {
    return DiagnosticoGestacao(
      id: json['id'],
      inseminacaoId: json['inseminacao_id'],
      manejoId: json['manejo_id'],
      dataDiagnostico: DateTime.parse(json['data_diagnostico']),
      resultado: ResultadoDiagnostico.values.firstWhere(
        (e) => e.name == json['resultado'],
        orElse: () => ResultadoDiagnostico.inconclusivo,
      ),
      metodo: json['metodo'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inseminacao_id': inseminacaoId,
      'manejo_id': manejoId,
      'data_diagnostico': dataDiagnostico.toIso8601String().split('T')[0],
      'resultado': resultado.name,
      'metodo': metodo,
      'observacoes': observacoes,
    };
  }

  DateTime? get dataPartoPrevista {
    if (resultado == ResultadoDiagnostico.positivo && inseminacao != null) {
      return inseminacao!.dataInseminacao.add(Duration(days: 285)); // Gestação bovina
    }
    return null;
  }

  String get resultadoDisplay {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return 'Prenha';
      case ResultadoDiagnostico.negativo:
        return 'Vazia';
      case ResultadoDiagnostico.inconclusivo:
        return 'Inconclusivo';
    }
  }
}

enum ResultadoParto { nascido_vivo, aborto, natimorto }

enum DificuldadeParto { normal, assistido, cesariana }

class Parto {
  final String id;
  final String maeId;
  final String manejoId;
  final DateTime dataParto;
  final ResultadoParto resultado;
  final DificuldadeParto dificuldade;
  final int numeroFilhotes;
  final List<String> filhotesIds;
  final String? bezerroId;
  final double? pesoNascimento;
  final String? observacoes;

  // Dados relacionados
  AnimalEntity? mae;
  List<AnimalEntity>? filhotes;
  AnimalEntity? bezerro;

  Parto({
    required this.id,
    required this.maeId,
    required this.manejoId,
    required this.dataParto,
    required this.resultado,
    required this.dificuldade,
    required this.numeroFilhotes,
    required this.filhotesIds,
    this.bezerroId,
    this.pesoNascimento,
    this.observacoes,
    this.mae,
    this.filhotes,
    this.bezerro,
  });

  factory Parto.fromJson(Map<String, dynamic> json) {
    return Parto(
      id: json['id'],
      maeId: json['mae_id'],
      manejoId: json['manejo_id'],
      dataParto: DateTime.parse(json['data_parto']),
      resultado: ResultadoParto.values.firstWhere(
        (e) => e.name == json['resultado'],
        orElse: () => ResultadoParto.nascido_vivo,
      ),
      dificuldade: DificuldadeParto.values.firstWhere(
        (e) => e.name == json['dificuldade'],
        orElse: () => DificuldadeParto.normal,
      ),
      numeroFilhotes: json['numero_filhotes'] ?? 1,
      filhotesIds: List<String>.from(json['filhotes'] ?? []),
      bezerroId: json['bezerro_id'],
      pesoNascimento: json['peso_nascimento']?.toDouble(),
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mae_id': maeId,
      'manejo_id': manejoId,
      'data_parto': dataParto.toIso8601String().split('T')[0],
      'resultado': resultado.name,
      'dificuldade': dificuldade.name,
      'numero_filhotes': numeroFilhotes,
      'filhotes': filhotesIds,
      'bezerro_id': bezerroId,
      'peso_nascimento': pesoNascimento,
      'observacoes': observacoes,
    };
  }

  String get resultadoDisplay {
    switch (resultado) {
      case ResultadoParto.nascido_vivo:
        return 'Nascido Vivo';
      case ResultadoParto.aborto:
        return 'Aborto';
      case ResultadoParto.natimorto:
        return 'Natimorto';
    }
  }

  String get dificuldadeDisplay {
    switch (dificuldade) {
      case DificuldadeParto.normal:
        return 'Normal';
      case DificuldadeParto.assistido:
        return 'Assistido';
      case DificuldadeParto.cesariana:
        return 'Cesariana';
    }
  }
}
