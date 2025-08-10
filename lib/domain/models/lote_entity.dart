import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart'; // Para PropriedadeSimples
import 'package:agronexus/domain/models/area_entity.dart';

class LoteEntity extends BaseEntity {
  final String nome;
  final String descricao;
  final String criterioAgrupamento;
  final String propriedadeId;
  final PropriedadeSimples? propriedade;
  final String? areaAtualId;
  final AreaEntity? areaAtual;
  final String? aptidao; // restaurado
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
    this.propriedade,
    this.areaAtualId,
    this.areaAtual,
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
        propriedade = null,
        areaAtualId = null,
        areaAtual = null,
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
        propriedade,
        areaAtualId,
        areaAtual,
        aptidao,
        finalidade,
        sistemaCriacao,
        ativo,
        totalAnimais,
        totalUa,
        pesoMedio,
        gmdMedio,
      ];

  // copyWith não existe em BaseEntity; removido @override
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
    AgroNexusGetter<PropriedadeSimples?>? propriedade,
    AgroNexusGetter<String?>? areaAtualId,
    AgroNexusGetter<AreaEntity?>? areaAtual,
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
      propriedade: propriedade != null ? propriedade() : this.propriedade,
      areaAtualId: areaAtualId != null ? areaAtualId() : this.areaAtualId,
      areaAtual: areaAtual != null ? areaAtual() : this.areaAtual,
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
    final data = super.toJson();
    data['nome'] = nome;
    data['descricao'] = descricao;
    data['criterio_agrupamento'] = criterioAgrupamento;
    final effectivePropriedadeId = propriedadeId.isNotEmpty ? propriedadeId : (propriedade?.id ?? '');
    data['propriedade_id'] = effectivePropriedadeId;
    if (areaAtualId != null) data['area_atual_id'] = areaAtualId; // mantém envio por ID
    if (aptidao != null) data['aptidao'] = aptidao;
    if (finalidade != null) data['finalidade'] = finalidade;
    if (sistemaCriacao != null) data['sistema_criacao'] = sistemaCriacao;
    data['ativo'] = ativo;
    return data;
  }

  factory LoteEntity.fromJson(Map<String, dynamic> json) {
    return LoteEntity(
      id: json['id'],
      createdById: json['created_by'],
      modifiedById: json['modified_by'],
      createdAt: json['created_at'],
      modifiedAt: json['modified_at'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'] ?? '',
      criterioAgrupamento: json['criterio_agrupamento'] ?? '',
      propriedadeId: (json['propriedade_id'] ?? json['propriedade']?['id'] ?? ''),
      propriedade: json['propriedade'] != null ? PropriedadeSimples.fromJson(json['propriedade']) : null,
      areaAtualId: json['area_atual_id'],
      areaAtual: json['area_atual'] != null ? AreaEntity.fromJson(json['area_atual']) : null,
      aptidao: (json['aptidao'] as String?)?.isNotEmpty == true ? json['aptidao'] : null,
      finalidade: (json['finalidade'] as String?)?.isNotEmpty == true ? json['finalidade'] : null,
      sistemaCriacao: (json['sistema_criacao'] as String?)?.isNotEmpty == true ? json['sistema_criacao'] : null,
      ativo: json['ativo'] ?? true,
      totalAnimais: json['total_animais'] ?? 0,
      totalUa: json['total_ua'] != null ? (json['total_ua'] as num).toDouble() : null,
      pesoMedio: json['peso_medio'] != null ? (json['peso_medio'] as num).toDouble() : null,
      gmdMedio: json['gmd_medio'] != null ? (json['gmd_medio'] as num).toDouble() : null,
    );
  }
}
