import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';

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

enum Sexo {
  macho(label: 'Macho'),
  femea(label: 'Fêmea');

  final String label;

  const Sexo({required this.label});
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

  String get apiValue {
    switch (this) {
      case Sexo.macho:
        return 'M';
      case Sexo.femea:
        return 'F';
    }
  }
}

class AnimalEntity extends BaseEntity {
  final String idAnimal;
  final String situacao;
  final String dataNascimento;
  final Sexo sexo;
  final AcaoDestino acaoDestino;
  final Status status;
  final String observacao;
  final String lote;
  final String loteNome;
  final String fazendaNome;

  const AnimalEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.idAnimal,
    required this.situacao,
    required this.dataNascimento,
    required this.sexo,
    required this.acaoDestino,
    required this.status,
    required this.observacao,
    required this.lote,
    required this.loteNome,
    required this.fazendaNome,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        idAnimal,
        situacao,
        dataNascimento,
        sexo,
        acaoDestino,
        status,
        observacao,
        lote,
        loteNome,
      ];

  @override
  AnimalEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? idAnimal,
    AgroNexusGetter<String>? situacao,
    AgroNexusGetter<String>? dataNascimento,
    AgroNexusGetter<Sexo>? sexo,
    AgroNexusGetter<AcaoDestino>? acaoDestino,
    AgroNexusGetter<Status>? status,
    AgroNexusGetter<String>? observacao,
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
      idAnimal: idAnimal != null ? idAnimal() : this.idAnimal,
      situacao: situacao != null ? situacao() : this.situacao,
      dataNascimento: dataNascimento != null ? dataNascimento() : this.dataNascimento,
      sexo: sexo != null ? sexo() : this.sexo,
      acaoDestino: acaoDestino != null ? acaoDestino() : this.acaoDestino,
      status: status != null ? status() : this.status,
      observacao: observacao != null ? observacao() : this.observacao,
      lote: lote != null ? lote() : this.lote,
      loteNome: loteNome != null ? loteNome() : this.loteNome,
      fazendaNome: fazendaNome != null ? fazendaNome() : this.fazendaNome,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['id_animal'] = idAnimal;
    data['situacao'] = situacao;
    data['data_nascimento'] = dataNascimento;
    data['sexo'] = sexo.apiValue;
    data['acao_destino'] = acaoDestino.name;
    data['status'] = status.name;
    data['observacao'] = observacao;
    data['lote'] = lote;
    data['lote_nome'] = loteNome;
    data['fazenda_nome'] = fazendaNome;
    return data;
  }

  Map<String, dynamic> toJsonSend() {
    Map<String, dynamic> data = super.toJson();
    data['id_animal'] = idAnimal;
    data['situacao'] = situacao;
    data['data_nascimento'] = dataNascimento;
    data['sexo'] = sexo.apiValue;
    data['acao_destino'] = acaoDestino.name;
    data['status'] = status.name;
    data['observacao'] = observacao;
    data['lote'] = lote;
    data['lote_nome'] = loteNome;
    data['fazenda_nome'] = fazendaNome;
    return data;
  }

  const AnimalEntity.empty()
      : idAnimal = '',
        situacao = '',
        sexo = Sexo.femea,
        acaoDestino = AcaoDestino.leilao,
        status = Status.ativo,
        dataNascimento = '',
        observacao = '',
        lote = '',
        loteNome = '',
        fazendaNome = '';

  AnimalEntity.fromJson(super.json)
      : idAnimal = json['id_animal'],
        situacao = json['situacao'],
        dataNascimento = json['data_nascimento'],
        sexo = Sexo.fromString(json['sexo']),
        acaoDestino = AcaoDestino.fromString(json['acao_destino']),
        status = Status.fromString(json['status']),
        observacao = json['observacao'],
        lote = json['lote'],
        loteNome = json['lote_nome'],
        fazendaNome = json['fazenda_nome'],
        super.fromJson();
}
