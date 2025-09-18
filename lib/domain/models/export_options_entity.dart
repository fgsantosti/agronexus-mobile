import 'package:agronexus/domain/models/base_entity.dart';
import 'package:agronexus/config/utils.dart';

enum ExportFormat {
  xlsx(label: 'Excel (.xlsx)', value: 'xlsx'),
  csv(label: 'CSV (.csv)', value: 'csv');

  final String label;
  final String value;
  const ExportFormat({required this.label, required this.value});

  static ExportFormat fromString(String value) {
    switch (value) {
      case 'xlsx':
        return ExportFormat.xlsx;
      case 'csv':
        return ExportFormat.csv;
      default:
        throw Exception('Invalid ExportFormat value: $value');
    }
  }
}

class ExportOptionsEntity extends BaseEntity {
  final ExportFormat format;
  final bool includeInactives;
  final String? fazendaId;
  final List<String> selectedFields;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  // Novos campos para integração com API
  final bool incluirGenealogia;
  final bool incluirEstatisticas;
  final String formatoData;
  final String? propriedadeId;
  final String? especieId;
  final String? status;
  final String? search;

  const ExportOptionsEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.format,
    required this.includeInactives,
    this.fazendaId,
    required this.selectedFields,
    this.dataInicio,
    this.dataFim,
    this.incluirGenealogia = true,
    this.incluirEstatisticas = true,
    this.formatoData = 'dd/MM/yyyy',
    this.propriedadeId,
    this.especieId,
    this.status,
    this.search,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        format,
        includeInactives,
        fazendaId,
        selectedFields,
        dataInicio,
        dataFim,
        incluirGenealogia,
        incluirEstatisticas,
        formatoData,
        propriedadeId,
        especieId,
        status,
        search,
      ];

  ExportOptionsEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<ExportFormat>? format,
    AgroNexusGetter<bool>? includeInactives,
    AgroNexusGetter<String?>? fazendaId,
    AgroNexusGetter<List<String>>? selectedFields,
    AgroNexusGetter<DateTime?>? dataInicio,
    AgroNexusGetter<DateTime?>? dataFim,
    AgroNexusGetter<bool>? incluirGenealogia,
    AgroNexusGetter<bool>? incluirEstatisticas,
    AgroNexusGetter<String>? formatoData,
    AgroNexusGetter<String?>? propriedadeId,
    AgroNexusGetter<String?>? especieId,
    AgroNexusGetter<String?>? status,
    AgroNexusGetter<String?>? search,
  }) {
    return ExportOptionsEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      format: format != null ? format() : this.format,
      includeInactives: includeInactives != null ? includeInactives() : this.includeInactives,
      fazendaId: fazendaId != null ? fazendaId() : this.fazendaId,
      selectedFields: selectedFields != null ? selectedFields() : this.selectedFields,
      dataInicio: dataInicio != null ? dataInicio() : this.dataInicio,
      dataFim: dataFim != null ? dataFim() : this.dataFim,
      incluirGenealogia: incluirGenealogia != null ? incluirGenealogia() : this.incluirGenealogia,
      incluirEstatisticas: incluirEstatisticas != null ? incluirEstatisticas() : this.incluirEstatisticas,
      formatoData: formatoData != null ? formatoData() : this.formatoData,
      propriedadeId: propriedadeId != null ? propriedadeId() : this.propriedadeId,
      especieId: especieId != null ? especieId() : this.especieId,
      status: status != null ? status() : this.status,
      search: search != null ? search() : this.search,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'format': format.value,
      'include_inactives': includeInactives,
      'fazenda_id': fazendaId,
      'selected_fields': selectedFields,
      'data_inicio': dataInicio?.toIso8601String(),
      'data_fim': dataFim?.toIso8601String(),
      'incluir_genealogia': incluirGenealogia,
      'incluir_estatisticas': incluirEstatisticas,
      'formato_data': formatoData,
      'propriedade_id': propriedadeId,
      'especie_id': especieId,
      'status': status,
      'search': search,
    });
    return data;
  }

  ExportOptionsEntity.fromJson(Map<String, dynamic> json)
      : format = ExportFormat.fromString(json['format'] ?? 'xlsx'),
        includeInactives = json['include_inactives'] ?? false,
        fazendaId = json['fazenda_id'],
        selectedFields = List<String>.from(json['selected_fields'] ?? []),
        dataInicio = json['data_inicio'] != null ? DateTime.parse(json['data_inicio']) : null,
        dataFim = json['data_fim'] != null ? DateTime.parse(json['data_fim']) : null,
        incluirGenealogia = json['incluir_genealogia'] ?? true,
        incluirEstatisticas = json['incluir_estatisticas'] ?? true,
        formatoData = json['formato_data'] ?? 'dd/MM/yyyy',
        propriedadeId = json['propriedade_id'],
        especieId = json['especie_id'],
        status = json['status'],
        search = json['search'],
        super.fromJson(json);
}
