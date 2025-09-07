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
        super.fromJson(json);
}
