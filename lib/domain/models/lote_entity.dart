import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';

class LoteEntity extends BaseEntity {
  final String nomeLote;
  final String dataEntrada;
  final String observacao;
  final String fazenda;
  final bool ativa;
  final int totalAnimais;

  const LoteEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.nomeLote,
    required this.dataEntrada,
    required this.observacao,
    required this.fazenda,
    required this.ativa,
    required this.totalAnimais,
  });

  const LoteEntity.empty()
      : nomeLote = "",
        dataEntrada = '',
        observacao = '',
        fazenda = "",
        ativa = true,
        totalAnimais = 0;

  @override
  List<Object?> get props => [
        ...super.props,
        nomeLote,
        dataEntrada,
        observacao,
        fazenda,
        ativa,
        totalAnimais,
      ];

  @override
  LoteEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? nomeLote,
    AgroNexusGetter<String>? dataEntrada,
    AgroNexusGetter<String>? observacao,
    AgroNexusGetter<String>? fazenda,
    AgroNexusGetter<bool>? ativa,
    AgroNexusGetter<int>? totalAnimais,
  }) {
    return LoteEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      nomeLote: nomeLote != null ? nomeLote() : this.nomeLote,
      dataEntrada: dataEntrada != null ? dataEntrada() : this.dataEntrada,
      observacao: observacao != null ? observacao() : this.observacao,
      fazenda: fazenda != null ? fazenda() : this.fazenda,
      ativa: ativa != null ? ativa() : this.ativa,
      totalAnimais: totalAnimais != null ? totalAnimais() : this.totalAnimais,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['nome_lote'] = nomeLote;
    data['data_entrada'] = dataEntrada;
    data['observacao'] = observacao;
    data['fazenda'] = fazenda;
    data['ativa'] = ativa;
    data['total_animais'] = totalAnimais;
    return data;
  }

  LoteEntity.fromJson(super.json)
      : nomeLote = json['nome_lote'] ?? "",
        dataEntrada = json['data_entrada'] ?? "",
        observacao = json['observacao'] ?? "",
        fazenda = json['fazenda'] ?? "",
        ativa = json['ativa'] ?? true,
        totalAnimais = json['total_animais'] ?? 0,
        super.fromJson();
}
