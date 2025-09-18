import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';

enum StatusAnimal {
  ativo(label: 'Ativo', value: 'ativo'),
  vendido(label: 'Vendido', value: 'vendido'),
  morto(label: 'Morto', value: 'morto'),
  descartado(label: 'Descartado', value: 'descartado');

  final String label;
  final String value;

  const StatusAnimal({required this.label, required this.value});

  static StatusAnimal fromString(String value) {
    final lowerValue = value.toLowerCase();
    switch (lowerValue) {
      case 'ativo':
        return StatusAnimal.ativo;
      case 'vendido':
        return StatusAnimal.vendido;
      case 'morto':
        return StatusAnimal.morto;
      case 'descartado':
        return StatusAnimal.descartado;
      default:
        print('Warning: Unknown StatusAnimal value: $value, defaulting to ativo');
        return StatusAnimal.ativo; // Valor padrão ao invés de erro
    }
  }
}

enum Sexo {
  macho(label: 'Macho', value: 'M'),
  femea(label: 'Fêmea', value: 'F');

  final String label;
  final String value;

  const Sexo({required this.label, required this.value});

  static Sexo fromString(String value) {
    switch (value) {
      case 'M':
        return Sexo.macho;
      case 'F':
        return Sexo.femea;
      default:
        throw Exception('Invalid Sexo value: $value');
    }
  }

  String get apiValue => value;
}

enum OrigemAnimal {
  proprio(label: 'Próprio', value: 'proprio'),
  compra(label: 'Compra', value: 'compra'),
  leilao(label: 'Leilão', value: 'leilao'),
  doacao(label: 'Doação', value: 'doacao'),
  parceria(label: 'Parceria', value: 'parceria');

  final String label;
  final String value;

  const OrigemAnimal({required this.label, required this.value});

  static OrigemAnimal fromString(String value) {
    if (value.isEmpty) {
      print('Warning: OrigemAnimal value is empty, defaulting to proprio');
      return OrigemAnimal.proprio;
    }

    final lowerValue = value.toLowerCase();
    switch (lowerValue) {
      case 'proprio':
      case 'próprio':
        return OrigemAnimal.proprio;
      case 'compra':
        return OrigemAnimal.compra;
      case 'leilao':
      case 'leilão':
        return OrigemAnimal.leilao;
      case 'doacao':
      case 'doação':
        return OrigemAnimal.doacao;
      case 'parceria':
        return OrigemAnimal.parceria;
      // Aceitar variações de fazenda como próprio
      case 'fazenda a':
      case 'fazenda b':
      case 'fazenda c':
      case 'fazenda':
        return OrigemAnimal.proprio;
      default:
        print('Warning: Unknown OrigemAnimal value: $value, defaulting to proprio');
        return OrigemAnimal.proprio; // Valor padrão ao invés de erro
    }
  }
}

enum CategoriaAnimal {
  // Bovinos
  bezerro(label: 'Bezerro', value: 'bezerro'),
  bezerra(label: 'Bezerra', value: 'bezerra'),
  novilho(label: 'Novilho', value: 'novilho'),
  novilha(label: 'Novilha', value: 'novilha'),
  touro(label: 'Touro', value: 'touro'),
  vaca(label: 'Vaca', value: 'vaca'),

  // Caprinos
  cabrito(label: 'Cabrito', value: 'cabrito'),
  cabrita(label: 'Cabrita', value: 'cabrita'),
  bodeJovem(label: 'Bode Jovem', value: 'bode_jovem'),
  cabraJovem(label: 'Cabra Jovem', value: 'cabra_jovem'),
  bode(label: 'Bode', value: 'bode'),
  cabra(label: 'Cabra', value: 'cabra'),

  // Ovinos
  cordeiro(label: 'Cordeiro', value: 'cordeiro'),
  cordeira(label: 'Cordeira', value: 'cordeira'),
  carneiroJovem(label: 'Carneiro Jovem', value: 'carneiro_jovem'),
  ovelhaJovem(label: 'Ovelha Jovem', value: 'ovelha_jovem'),
  carneiro(label: 'Carneiro', value: 'carneiro'),
  ovelha(label: 'Ovelha', value: 'ovelha'),

  // Equinos
  cavalo(label: 'Cavalo', value: 'cavalo'),
  egua(label: 'Égua', value: 'egua'),
  potro(label: 'Potro', value: 'potro'),

  // Suínos
  porco(label: 'Porco', value: 'porco'),
  leitao(label: 'Leitão', value: 'leitao');

  final String label;
  final String value;

  const CategoriaAnimal({required this.label, required this.value});

  static CategoriaAnimal fromString(String value) {
    final lowerValue = value.toLowerCase();
    switch (lowerValue) {
      // Bovinos
      case 'bezerro':
        return CategoriaAnimal.bezerro;
      case 'bezerra':
        return CategoriaAnimal.bezerra;
      case 'novilho':
        return CategoriaAnimal.novilho;
      case 'novilha':
        return CategoriaAnimal.novilha;
      case 'touro':
        return CategoriaAnimal.touro;
      case 'vaca':
        return CategoriaAnimal.vaca;

      // Caprinos
      case 'cabrito':
        return CategoriaAnimal.cabrito;
      case 'cabrita':
        return CategoriaAnimal.cabrita;
      case 'bode_jovem':
        return CategoriaAnimal.bodeJovem;
      case 'cabra_jovem':
        return CategoriaAnimal.cabraJovem;
      case 'bode':
        return CategoriaAnimal.bode;
      case 'cabra':
        return CategoriaAnimal.cabra;

      // Ovinos
      case 'cordeiro':
        return CategoriaAnimal.cordeiro;
      case 'cordeira':
        return CategoriaAnimal.cordeira;
      case 'carneiro_jovem':
        return CategoriaAnimal.carneiroJovem;
      case 'ovelha_jovem':
        return CategoriaAnimal.ovelhaJovem;
      case 'carneiro':
        return CategoriaAnimal.carneiro;
      case 'ovelha':
        return CategoriaAnimal.ovelha;

      // Equinos
      case 'cavalo':
        return CategoriaAnimal.cavalo;
      case 'egua':
        return CategoriaAnimal.egua;
      case 'potro':
        return CategoriaAnimal.potro;

      // Suínos
      case 'porco':
        return CategoriaAnimal.porco;
      case 'leitao':
        return CategoriaAnimal.leitao;

      default:
        print('Warning: Unknown CategoriaAnimal value: $value, defaulting to bezerro');
        return CategoriaAnimal.bezerro; // Valor padrão ao invés de erro
    }
  }
}

class EspecieAnimal {
  final String id;
  final String nome;
  final String nomeDisplay;
  final double pesoUaReferencia;
  final int periodoGestacaoDias;
  final int idadePrimeiraCoberturasMeses;
  final bool ativo;

  const EspecieAnimal({
    required this.id,
    required this.nome,
    required this.nomeDisplay,
    required this.pesoUaReferencia,
    required this.periodoGestacaoDias,
    required this.idadePrimeiraCoberturasMeses,
    required this.ativo,
  });

  factory EspecieAnimal.fromJson(Map<String, dynamic> json) {
    try {
      return EspecieAnimal(
        id: json['id'] ?? '',
        nome: json['nome'] ?? '',
        nomeDisplay: json['nome_display'] ?? '',
        pesoUaReferencia: _parseDoubleEspecie(json['peso_ua_referencia']),
        periodoGestacaoDias: json['periodo_gestacao_dias'] ?? 0,
        idadePrimeiraCoberturasMeses: json['idade_primeira_cobertura_meses'] ?? 0,
        ativo: json['ativo'] ?? true,
      );
    } catch (e) {
      print('❌ Erro ao fazer parse de EspecieAnimal: $e');
      print('❌ JSON problemático: $json');
      rethrow;
    }
  }

  static double _parseDoubleEspecie(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'nome_display': nomeDisplay,
      'peso_ua_referencia': pesoUaReferencia,
      'periodo_gestacao_dias': periodoGestacaoDias,
      'idade_primeira_cobertura_meses': idadePrimeiraCoberturasMeses,
      'ativo': ativo,
    };
  }
}

class RacaAnimal {
  final String id;
  final String nome;
  final String? origem;
  final String? caracteristicas;
  final double? pesoMedioAdultoKg;
  final EspecieAnimal especie;
  final bool ativo;

  const RacaAnimal({
    required this.id,
    required this.nome,
    this.origem,
    this.caracteristicas,
    this.pesoMedioAdultoKg,
    required this.especie,
    required this.ativo,
  });

  factory RacaAnimal.fromJson(Map<String, dynamic> json) {
    try {
      return RacaAnimal(
        id: json['id'] ?? '',
        nome: json['nome'] ?? '',
        origem: json['origem'],
        caracteristicas: json['caracteristicas'],
        pesoMedioAdultoKg: _parseDoubleRaca(json['peso_medio_adulto_kg']),
        especie: _parseEspecieAnimalFromRaca(json['especie']),
        ativo: json['ativo'] ?? true,
      );
    } catch (e) {
      print('❌ Erro ao fazer parse de RacaAnimal: $e');
      print('❌ JSON problemático: $json');
      rethrow;
    }
  }

  static double? _parseDoubleRaca(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static EspecieAnimal _parseEspecieAnimalFromRaca(dynamic value) {
    if (value == null) {
      // Retorna uma espécie padrão se não encontrar
      return const EspecieAnimal(
        id: '',
        nome: '',
        nomeDisplay: '',
        pesoUaReferencia: 0.0,
        periodoGestacaoDias: 0,
        idadePrimeiraCoberturasMeses: 0,
        ativo: true,
      );
    }

    if (value is Map<String, dynamic>) {
      try {
        return EspecieAnimal.fromJson(value);
      } catch (e) {
        print('Erro ao fazer parse de EspecieAnimal na RacaAnimal: $e');
        return const EspecieAnimal(
          id: '',
          nome: '',
          nomeDisplay: '',
          pesoUaReferencia: 0.0,
          periodoGestacaoDias: 0,
          idadePrimeiraCoberturasMeses: 0,
          ativo: true,
        );
      }
    }

    if (value is String) {
      // Se for uma string (ID), cria uma espécie básica apenas com o ID
      return EspecieAnimal(
        id: value,
        nome: '',
        nomeDisplay: '',
        pesoUaReferencia: 0.0,
        periodoGestacaoDias: 0,
        idadePrimeiraCoberturasMeses: 0,
        ativo: true,
      );
    }

    return const EspecieAnimal(
      id: '',
      nome: '',
      nomeDisplay: '',
      pesoUaReferencia: 0.0,
      periodoGestacaoDias: 0,
      idadePrimeiraCoberturasMeses: 0,
      ativo: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'origem': origem,
      'caracteristicas': caracteristicas,
      'peso_medio_adulto_kg': pesoMedioAdultoKg,
      'especie': especie.toJson(),
      'ativo': ativo,
    };
  }
}

class PropriedadeSimples {
  final String id;
  final String nome;

  const PropriedadeSimples({
    required this.id,
    required this.nome,
  });

  factory PropriedadeSimples.fromJson(Map<String, dynamic> json) {
    try {
      return PropriedadeSimples(
        id: json['id'] ?? '',
        nome: json['nome'] ?? '',
      );
    } catch (e) {
      print('❌ Erro ao fazer parse de PropriedadeSimples: $e');
      print('❌ JSON problemático: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}

class LoteSimples {
  final String id;
  final String nome;

  const LoteSimples({
    required this.id,
    required this.nome,
  });

  factory LoteSimples.fromJson(Map<String, dynamic> json) {
    try {
      return LoteSimples(
        id: json['id'] ?? '',
        nome: json['nome'] ?? '',
      );
    } catch (e) {
      print('❌ Erro ao fazer parse de LoteSimples: $e');
      print('❌ JSON problemático: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}

// Legado - manter para compatibilidade
enum AcaoDestino {
  leilao(label: 'Leilão'),
  venda(label: 'Venda'),
  abate(label: 'Abate'),
  permanece(label: 'Permanece na fazenda');

  final String label;

  const AcaoDestino({required this.label});
  static AcaoDestino fromString(String value) {
    switch (value) {
      case 'leilao':
        return AcaoDestino.leilao;
      case 'venda':
        return AcaoDestino.venda;
      case 'abate':
        return AcaoDestino.abate;
      case 'permanece':
        return AcaoDestino.permanece;
      default:
        throw Exception('Invalid AcaoDestino value: $value');
    }
  }
}

enum Status {
  ativo(label: 'Ativo'),
  inativo(label: 'Inativo');

  final String label;

  const Status({required this.label});
  static Status fromString(String value) {
    switch (value) {
      case 'on':
        return Status.ativo;
      case 'off':
        return Status.inativo;
      default:
        throw Exception('Invalid Status value: $value');
    }
  }
}

class AnimalEntity extends BaseEntity {
  // Identificação básica
  final String identificacaoUnica;
  final String? nomeRegistro;
  final Sexo sexo;
  final String dataNascimento;
  final CategoriaAnimal categoria;
  final StatusAnimal status;

  // Espécie e raça
  final EspecieAnimal? especie;
  final RacaAnimal? raca;

  // Propriedade e lote
  final PropriedadeSimples? propriedade;
  final LoteSimples? loteAtual;

  // Genealogia
  final AnimalEntity? pai;
  final AnimalEntity? mae;

  // Dados comerciais
  final String? dataCompra;
  final double? valorCompra;
  final OrigemAnimal? origem;
  final String? dataVenda;
  final double? valorVenda;
  final String? destino;

  // Dados de morte
  final String? dataMorte;
  final String? causaMorte;

  // Observações
  final String? observacoes;

  // Campos legados para compatibilidade
  final String idAnimal;
  final String situacao;
  final AcaoDestino acaoDestino;
  final String lote;
  final String loteNome;
  final String fazendaNome;

  const AnimalEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    // Campos principais
    required this.identificacaoUnica,
    this.nomeRegistro,
    required this.sexo,
    required this.dataNascimento,
    required this.categoria,
    required this.status,
    this.especie,
    this.raca,
    this.propriedade,
    this.loteAtual,
    this.pai,
    this.mae,
    this.dataCompra,
    this.valorCompra,
    this.origem,
    this.dataVenda,
    this.valorVenda,
    this.destino,
    this.dataMorte,
    this.causaMorte,
    this.observacoes,
    // Campos legados
    required this.idAnimal,
    required this.situacao,
    required this.acaoDestino,
    required this.lote,
    required this.loteNome,
    required this.fazendaNome,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        identificacaoUnica,
        nomeRegistro,
        sexo,
        dataNascimento,
        categoria,
        status,
        especie,
        raca,
        propriedade,
        loteAtual,
        pai,
        mae,
        dataCompra,
        valorCompra,
        origem,
        dataVenda,
        valorVenda,
        destino,
        dataMorte,
        causaMorte,
        observacoes,
        // Legados
        idAnimal,
        situacao,
        acaoDestino,
        lote,
        loteNome,
        fazendaNome,
      ];

  @override
  AnimalEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? identificacaoUnica,
    AgroNexusGetter<String?>? nomeRegistro,
    AgroNexusGetter<Sexo>? sexo,
    AgroNexusGetter<String>? dataNascimento,
    AgroNexusGetter<CategoriaAnimal>? categoria,
    AgroNexusGetter<StatusAnimal>? status,
    AgroNexusGetter<EspecieAnimal?>? especie,
    AgroNexusGetter<RacaAnimal?>? raca,
    AgroNexusGetter<PropriedadeSimples?>? propriedade,
    AgroNexusGetter<LoteSimples?>? loteAtual,
    AgroNexusGetter<AnimalEntity?>? pai,
    AgroNexusGetter<AnimalEntity?>? mae,
    AgroNexusGetter<String?>? dataCompra,
    AgroNexusGetter<double?>? valorCompra,
    AgroNexusGetter<OrigemAnimal?>? origem,
    AgroNexusGetter<String?>? dataVenda,
    AgroNexusGetter<double?>? valorVenda,
    AgroNexusGetter<String?>? destino,
    AgroNexusGetter<String?>? dataMorte,
    AgroNexusGetter<String?>? causaMorte,
    AgroNexusGetter<String?>? observacoes,
    // Legados
    AgroNexusGetter<String>? idAnimal,
    AgroNexusGetter<String>? situacao,
    AgroNexusGetter<AcaoDestino>? acaoDestino,
    AgroNexusGetter<String>? lote,
    AgroNexusGetter<String>? loteNome,
    AgroNexusGetter<String>? fazendaNome,
  }) {
    return AnimalEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      identificacaoUnica: identificacaoUnica != null ? identificacaoUnica() : this.identificacaoUnica,
      nomeRegistro: nomeRegistro != null ? nomeRegistro() : this.nomeRegistro,
      sexo: sexo != null ? sexo() : this.sexo,
      dataNascimento: dataNascimento != null ? dataNascimento() : this.dataNascimento,
      categoria: categoria != null ? categoria() : this.categoria,
      status: status != null ? status() : this.status,
      especie: especie != null ? especie() : this.especie,
      raca: raca != null ? raca() : this.raca,
      propriedade: propriedade != null ? propriedade() : this.propriedade,
      loteAtual: loteAtual != null ? loteAtual() : this.loteAtual,
      pai: pai != null ? pai() : this.pai,
      mae: mae != null ? mae() : this.mae,
      dataCompra: dataCompra != null ? dataCompra() : this.dataCompra,
      valorCompra: valorCompra != null ? valorCompra() : this.valorCompra,
      origem: origem != null ? origem() : this.origem,
      dataVenda: dataVenda != null ? dataVenda() : this.dataVenda,
      valorVenda: valorVenda != null ? valorVenda() : this.valorVenda,
      destino: destino != null ? destino() : this.destino,
      dataMorte: dataMorte != null ? dataMorte() : this.dataMorte,
      causaMorte: causaMorte != null ? causaMorte() : this.causaMorte,
      observacoes: observacoes != null ? observacoes() : this.observacoes,
      // Legados
      idAnimal: idAnimal != null ? idAnimal() : this.idAnimal,
      situacao: situacao != null ? situacao() : this.situacao,
      acaoDestino: acaoDestino != null ? acaoDestino() : this.acaoDestino,
      lote: lote != null ? lote() : this.lote,
      loteNome: loteNome != null ? loteNome() : this.loteNome,
      fazendaNome: fazendaNome != null ? fazendaNome() : this.fazendaNome,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['identificacao_unica'] = identificacaoUnica;
    data['nome_registro'] = nomeRegistro;
    data['sexo'] = sexo.value;
    data['data_nascimento'] = dataNascimento;
    data['categoria'] = categoria.value;
    data['status'] = status.value;
    data['especie'] = especie?.id;
    data['raca'] = raca?.id;
    data['propriedade'] = propriedade?.id;
    data['lote_atual'] = loteAtual?.id;
    data['pai'] = pai?.id;
    data['mae'] = mae?.id;
    data['data_compra'] = dataCompra;
    data['valor_compra'] = valorCompra;
    data['origem'] = origem?.value;
    data['data_venda'] = dataVenda;
    data['valor_venda'] = valorVenda;
    data['destino'] = destino;
    data['data_morte'] = dataMorte;
    data['causa_morte'] = causaMorte;
    data['observacoes'] = observacoes;

    // Campos legados
    data['id_animal'] = idAnimal;
    data['situacao'] = situacao;
    data['acao_destino'] = acaoDestino.name;
    data['lote'] = lote;
    data['lote_nome'] = loteNome;
    data['fazenda_nome'] = fazendaNome;
    return data;
  }

  Map<String, dynamic> toJsonSend() {
    final data = <String, dynamic>{
      'identificacao_unica': identificacaoUnica,
      'sexo': sexo.value,
      'data_nascimento': dataNascimento,
      'categoria': categoria.value,
      'status': status.value,
      'propriedade_id': propriedade?.id,
      'especie_id': especie?.id,
    };

    // Campos opcionais - só adiciona se não for nulo
    if (nomeRegistro != null && nomeRegistro!.isNotEmpty) {
      data['nome_registro'] = nomeRegistro;
    }

    if (raca?.id != null) {
      data['raca_id'] = raca!.id;
    }

    if (loteAtual?.id != null) {
      data['lote_atual_id'] = loteAtual!.id;
    }

    if (pai?.id != null) {
      data['pai_id'] = pai!.id;
    }

    if (mae?.id != null) {
      data['mae_id'] = mae!.id;
    }

    if (dataCompra != null) {
      data['data_compra'] = dataCompra;
    }

    if (valorCompra != null) {
      data['valor_compra'] = valorCompra;
    }

    if (origem != null) {
      data['origem'] = origem!.value;
    }

    if (dataVenda != null) {
      data['data_venda'] = dataVenda;
    }

    if (valorVenda != null) {
      data['valor_venda'] = valorVenda;
    }

    if (destino != null && destino!.isNotEmpty) {
      data['destino'] = destino;
    }

    if (dataMorte != null) {
      data['data_morte'] = dataMorte;
    }

    if (causaMorte != null && causaMorte!.isNotEmpty) {
      data['causa_morte'] = causaMorte;
    }

    if (observacoes != null && observacoes!.isNotEmpty) {
      data['observacoes'] = observacoes;
    }

    return data;
  }

  const AnimalEntity.empty()
      : identificacaoUnica = '',
        nomeRegistro = null,
        sexo = Sexo.femea,
        dataNascimento = '',
        categoria = CategoriaAnimal.bezerro,
        status = StatusAnimal.ativo,
        especie = null,
        raca = null,
        propriedade = null,
        loteAtual = null,
        pai = null,
        mae = null,
        dataCompra = null,
        valorCompra = null,
        origem = null,
        dataVenda = null,
        valorVenda = null,
        destino = null,
        dataMorte = null,
        causaMorte = null,
        observacoes = null,
        // Legados
        idAnimal = '',
        situacao = '',
        acaoDestino = AcaoDestino.permanece,
        lote = '',
        loteNome = '',
        fazendaNome = '';

  factory AnimalEntity.fromJson(Map<String, dynamic> json) {
    return AnimalEntity(
      id: json['id']?.toString(),
      createdById: json['created_by']?.toString(),
      modifiedById: json['modified_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      modifiedAt: json['modified_at']?.toString(),
      identificacaoUnica: json['identificacao_unica'] ?? '',
      nomeRegistro: json['nome_registro'],
      sexo: Sexo.fromString(json['sexo'] ?? 'F'),
      dataNascimento: json['data_nascimento'] ?? '',
      categoria: CategoriaAnimal.fromString(json['categoria'] ?? 'bezerro'),
      status: StatusAnimal.fromString(json['status'] ?? 'ativo'),
      especie: _parseEspecieAnimal(json['especie']),
      raca: _parseRacaAnimal(json['raca']),
      propriedade: _parsePropriedadeSimples(json['propriedade']),
      loteAtual: _parseLoteSimples(json['lote_atual']),
      pai: _parseAnimalEntity(json['pai']),
      mae: _parseAnimalEntity(json['mae']),
      dataCompra: json['data_compra'],
      valorCompra: _parseDouble(json['valor_compra']),
      origem: json['origem'] != null && json['origem'].toString().isNotEmpty ? OrigemAnimal.fromString(json['origem']) : null,
      dataVenda: json['data_venda'],
      valorVenda: _parseDouble(json['valor_venda']),
      destino: json['destino'],
      dataMorte: json['data_morte'],
      causaMorte: json['causa_morte'],
      observacoes: json['observacoes'],
      // Campos legados para compatibilidade
      idAnimal: json['id_animal'] ?? json['identificacao_unica'] ?? '',
      situacao: json['situacao'] ?? json['categoria'] ?? '',
      acaoDestino: AcaoDestino.fromString(json['acao_destino'] ?? 'permanece'),
      lote: json['lote'] ?? '',
      loteNome: json['lote_nome'] ?? '',
      fazendaNome: json['fazenda_nome'] ?? '',
    );
  }

  // Helper method para converter valores para double de forma segura
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper methods para parsing seguro de objetos aninhados
  static EspecieAnimal? _parseEspecieAnimal(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      try {
        return EspecieAnimal.fromJson(value);
      } catch (e) {
        print('Erro ao fazer parse de EspecieAnimal: $e');
        return null;
      }
    }
    return null;
  }

  static RacaAnimal? _parseRacaAnimal(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      try {
        return RacaAnimal.fromJson(value);
      } catch (e) {
        print('Erro ao fazer parse de RacaAnimal: $e');
        return null;
      }
    }
    return null;
  }

  static AnimalEntity? _parseAnimalEntity(dynamic value) {
    if (value == null) return null;

    // Se for uma string, ignore (provavelmente StringRelatedField do Django)
    if (value is String) return null;

    // Se for um Map, tenta fazer o parse
    if (value is Map<String, dynamic>) {
      try {
        // Para pai/mãe, a API retorna dados limitados, então criamos um AnimalEntity reduzido
        return AnimalEntity(
          id: value['id']?.toString(),
          identificacaoUnica: value['identificacao_unica'] ?? '',
          nomeRegistro: value['nome_registro'],
          sexo: Sexo.fromString(value['sexo'] ?? 'F'),
          dataNascimento: '', // Não disponível nos dados reduzidos
          categoria: CategoriaAnimal.fromString(value['categoria'] ?? 'bezerro'),
          status: StatusAnimal.ativo, // Padrão
          // Campos legados necessários
          idAnimal: value['identificacao_unica'] ?? '',
          situacao: value['categoria'] ?? '',
          acaoDestino: AcaoDestino.permanece,
          lote: '',
          loteNome: '',
          fazendaNome: '',
        );
      } catch (e) {
        print('Erro ao fazer parse de AnimalEntity (pai/mãe): $e');
        return null;
      }
    }

    return null;
  }

  static PropriedadeSimples? _parsePropriedadeSimples(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      try {
        return PropriedadeSimples.fromJson(value);
      } catch (e) {
        print('Erro ao fazer parse de PropriedadeSimples: $e');
        return null;
      }
    }
    return null;
  }

  static LoteSimples? _parseLoteSimples(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      try {
        return LoteSimples.fromJson(value);
      } catch (e) {
        print('Erro ao fazer parse de LoteSimples: $e');
        return null;
      }
    }
    return null;
  }

  // Factory method específico para respostas da API de inseminação
  factory AnimalEntity.fromInseminacaoJson(Map<String, dynamic> json) {
    return AnimalEntity(
      id: json['id'],
      identificacaoUnica: json['identificacao_unica'] ?? '',
      nomeRegistro: json['nome_registro'],
      sexo: Sexo.fromString(json['sexo'] ?? 'F'),
      dataNascimento: '',
      categoria: CategoriaAnimal.fromString(json['categoria'] ?? 'bezerro'),
      status: StatusAnimal.fromString(json['status'] ?? 'ativo'),
      observacoes: '',
      // Campos legados
      idAnimal: json['identificacao_unica'] ?? '',
      situacao: json['categoria'] ?? '',
      acaoDestino: AcaoDestino.permanece,
      lote: '',
      loteNome: '',
      fazendaNome: '',
    );
  }
}
