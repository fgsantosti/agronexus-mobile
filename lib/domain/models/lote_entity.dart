import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';

class LoteEntity extends BaseEntity {
  final String nome;
  final String descricao;
  final String criterioAgrupamento;
  final String propriedadeId;
  final String? areaAtualId;
  final String? aptidao;
  final String? finalidade;
  final String? sistemaCriacao;
  final bool ativo;
  final int totalAnimais;
  final double? totalUa;
  final double? pesoMedio;
  final double? gmdMedio;

  const LoteEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.nome,
    required this.descricao,
    required this.criterioAgrupamento,
    required this.propriedadeId,
    this.areaAtualId,
    this.aptidao,
    this.finalidade,
    this.sistemaCriacao,
    required this.ativo,
    this.totalAnimais = 0,
    this.totalUa,
    this.pesoMedio,
    this.gmdMedio,
  });

  const LoteEntity.empty()
      : nome = "",
        descricao = '',
        criterioAgrupamento = '',
        propriedadeId = "",
        areaAtualId = null,
        aptidao = null,
        finalidade = null,
        sistemaCriacao = null,
        ativo = true,
        totalAnimais = 0,
        totalUa = null,
        pesoMedio = null,
        gmdMedio = null;

  @override
  List<Object?> get props => [
        ...super.props,
        nome,
        descricao,
        criterioAgrupamento,
        propriedadeId,
        areaAtualId,
        aptidao,
        finalidade,
        sistemaCriacao,
        ativo,
        totalAnimais,
        totalUa,
        pesoMedio,
        gmdMedio,
      ];

  @override
  LoteEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? nome,
    AgroNexusGetter<String>? descricao,
    AgroNexusGetter<String>? criterioAgrupamento,
    AgroNexusGetter<String>? propriedadeId,
    AgroNexusGetter<String?>? areaAtualId,
    AgroNexusGetter<String?>? aptidao,
    AgroNexusGetter<String?>? finalidade,
    AgroNexusGetter<String?>? sistemaCriacao,
    AgroNexusGetter<bool>? ativo,
    AgroNexusGetter<int>? totalAnimais,
    AgroNexusGetter<double?>? totalUa,
    AgroNexusGetter<double?>? pesoMedio,
    AgroNexusGetter<double?>? gmdMedio,
  }) {
    return LoteEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      nome: nome != null ? nome() : this.nome,
      descricao: descricao != null ? descricao() : this.descricao,
      criterioAgrupamento: criterioAgrupamento != null ? criterioAgrupamento() : this.criterioAgrupamento,
      propriedadeId: propriedadeId != null ? propriedadeId() : this.propriedadeId,
      areaAtualId: areaAtualId != null ? areaAtualId() : this.areaAtualId,
      aptidao: aptidao != null ? aptidao() : this.aptidao,
      finalidade: finalidade != null ? finalidade() : this.finalidade,
      sistemaCriacao: sistemaCriacao != null ? sistemaCriacao() : this.sistemaCriacao,
      ativo: ativo != null ? ativo() : this.ativo,
      totalAnimais: totalAnimais != null ? totalAnimais() : this.totalAnimais,
      totalUa: totalUa != null ? totalUa() : this.totalUa,
      pesoMedio: pesoMedio != null ? pesoMedio() : this.pesoMedio,
      gmdMedio: gmdMedio != null ? gmdMedio() : this.gmdMedio,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['nome'] = nome;
    data['descricao'] = descricao;
    data['criterio_agrupamento'] = criterioAgrupamento;
    data['propriedade_id'] = propriedadeId;
    if (areaAtualId != null) data['area_atual_id'] = areaAtualId;
    if (aptidao != null) data['aptidao'] = aptidao;
    if (finalidade != null) data['finalidade'] = finalidade;
    if (sistemaCriacao != null) data['sistema_criacao'] = sistemaCriacao;
    data['ativo'] = ativo;
    return data;
  }

  LoteEntity.fromJson(super.json)
      : nome = json['nome'] ?? "",
        descricao = json['descricao'] ?? "",
        criterioAgrupamento = json['criterio_agrupamento'] ?? "",
        propriedadeId = json['propriedade_id'] ?? "",
        areaAtualId = json['area_atual_id'],
        aptidao = json['aptidao'],
        finalidade = json['finalidade'],
        sistemaCriacao = json['sistema_criacao'],
        ativo = json['ativo'] ?? true,
        totalAnimais = json['total_animais'] ?? 0,
        totalUa = json['total_ua']?.toDouble(),
        pesoMedio = json['peso_medio']?.toDouble(),
        gmdMedio = json['gmd_medio']?.toDouble(),
        super.fromJson();
}
