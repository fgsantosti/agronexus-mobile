import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_events.dart';
import 'package:agronexus/presentation/bloc/lote/lote_state.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/presentation/bloc/area/area_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_event.dart';
import 'package:agronexus/presentation/bloc/area/area_state.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';
import 'package:agronexus/presentation/widgets/form_submit_protection_mixin.dart';

class EditarLoteScreen extends StatefulWidget {
  final LoteEntity lote;

  const EditarLoteScreen({
    super.key,
    required this.lote,
  });

  @override
  State<EditarLoteScreen> createState() => _EditarLoteScreenState();
}

class _EditarLoteScreenState extends State<EditarLoteScreen> with FormSubmitProtectionMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers para campos de texto
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _criterioAgrupamentoController = TextEditingController();

  String? _aptidao;
  String? _finalidade;
  String? _sistemaCriacao;
  bool _ativo = true;

  // Opções dos dropdowns
  final List<Map<String, String>> _aptidaoOptions = [
    {'value': 'corte', 'label': 'Corte'},
    {'value': 'leite', 'label': 'Leite'},
    {'value': 'dupla_aptidao', 'label': 'Dupla Aptidão'},
  ];

  final List<Map<String, String>> _finalidadeOptions = [
    {'value': 'cria', 'label': 'Cria'},
    {'value': 'recria', 'label': 'Recria'},
    {'value': 'engorda', 'label': 'Engorda'},
  ];

  final List<Map<String, String>> _sistemaCriacaoOptions = [
    {'value': 'intensivo', 'label': 'Intensivo'},
    {'value': 'extensivo', 'label': 'Extensivo'},
    {'value': 'semi_extensivo', 'label': 'Semi-Extensivo'},
  ];

  List<AreaEntity> _areasDisponiveis = [];
  AreaEntity? _areaSelecionada;
  bool _loadingAreas = false;

  @override
  void initState() {
    super.initState();
    _preencherCamposComDadosExistentes();
    if (widget.lote.propriedadeId.isNotEmpty) {
      context.read<AreaBloc>().add(LoadAreasEvent(propriedadeId: widget.lote.propriedadeId));
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _criterioAgrupamentoController.dispose();
    super.dispose();
  }

  void _preencherCamposComDadosExistentes() {
    final lote = widget.lote;

    _nomeController.text = lote.nome;
    _descricaoController.text = lote.descricao;
    _criterioAgrupamentoController.text = lote.criterioAgrupamento;
    // propriedadeId não é editável, será mostrado apenas no TextFormField disabled
    _aptidao = lote.aptidao;
    _finalidade = lote.finalidade;
    _sistemaCriacao = lote.sistemaCriacao;
    _ativo = lote.ativo;
    _areaSelecionada = null; // será atribuída quando areas carregarem se id combinar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(
        title: 'Editar Lote',
        showSaveButton: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoteBloc, LoteState>(
            listener: (context, state) {
              if (state is LoteUpdated) {
                FormSnackBar.showSuccess(context, 'Lote atualizado com sucesso!');
                safeNavigateBack();
              }

              if (state is LoteError) {
                FormSnackBar.showError(context, state.message);
                resetProtection();
              }

              if (state is LoteLoading) {
                // Não precisa setar loading, o mixin já controla
              }
            },
          ),
          BlocListener<AreaBloc, AreaState>(
            listener: (context, state) {
              if (state is AreaLoading) {
                setState(() => _loadingAreas = true);
              } else if (state is AreasLoaded) {
                setState(() {
                  _areasDisponiveis = state.areas;
                  _loadingAreas = false;
                  if (widget.lote.areaAtualId != null) {
                    try {
                      _areaSelecionada = _areasDisponiveis.firstWhere((a) => a.id == widget.lote.areaAtualId);
                    } catch (_) {}
                  }
                });
              } else if (state is AreaError) {
                setState(() => _loadingAreas = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao carregar áreas: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações básicas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações Básicas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Lote *',
                            hintText: 'Ex: Lote Bezerros 2024',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            hintText: 'Descrição do lote',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _criterioAgrupamentoController,
                          decoration: const InputDecoration(
                            labelText: 'Critério de Agrupamento',
                            hintText: 'Ex: Bezerros desmamados em 2024',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: widget.lote.propriedade?.nome ?? 'Propriedade não encontrada',
                          decoration: const InputDecoration(
                            labelText: 'Propriedade',
                            hintText: 'Nome da propriedade',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home_work),
                          ),
                          enabled: false, // Não permite editar a propriedade
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Lote Ativo'),
                          subtitle: const Text('Define se o lote está em uso'),
                          value: _ativo,
                          onChanged: (value) {
                            setState(() {
                              _ativo = value;
                            });
                          },
                          activeColor: Colors.green.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Características do lote
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Características do Lote',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _aptidao,
                          decoration: const InputDecoration(
                            labelText: 'Aptidão',
                            border: OutlineInputBorder(),
                          ),
                          items: _aptidaoOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _aptidao = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _finalidade,
                          decoration: const InputDecoration(
                            labelText: 'Finalidade',
                            border: OutlineInputBorder(),
                          ),
                          items: _finalidadeOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _finalidade = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _sistemaCriacao,
                          decoration: const InputDecoration(
                            labelText: 'Sistema de Criação',
                            border: OutlineInputBorder(),
                          ),
                          items: _sistemaCriacaoOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _sistemaCriacao = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Área Atual (opcional)
                        DropdownButtonFormField<AreaEntity>(
                          value: _areaSelecionada,
                          decoration: const InputDecoration(
                            labelText: 'Área Atual (opcional)',
                            hintText: 'Selecione a área onde o lote está',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.map),
                          ),
                          items: _areasDisponiveis
                              .map((area) => DropdownMenuItem(
                                    value: area,
                                    child: Text('${area.nome} (${area.tipo})'),
                                  ))
                              .toList(),
                          onChanged: _loadingAreas
                              ? null
                              : (value) {
                                  setState(() => _areaSelecionada = value);
                                },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                FormPrimaryButton(
                  text: 'Salvar Alterações',
                  onPressed: _atualizarLote,
                  isLoading: isSaving,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _atualizarLote() {
    if (!canSubmit()) return;

    if (!_formKey.currentState!.validate()) {
      resetProtection();
      return;
    }

    markAsSubmitting();

    print('🔍 Debug - propriedadeId original: ${widget.lote.propriedadeId}');
    print('🔍 Debug - propriedade original: ${widget.lote.propriedade?.nome}');

    // Fallback para garantir que enviamos um UUID válido
    final propriedadeIdEfetivo = widget.lote.propriedadeId.isNotEmpty ? widget.lote.propriedadeId : (widget.lote.propriedade?.id ?? '');

    if (propriedadeIdEfetivo.isEmpty) {
      // Não deve prosseguir sem UUID – evita 400 desnecessário
      FormSnackBar.showError(context, 'Propriedade inválida: ID não encontrado.');
      resetProtection();
      return;
    }

    final loteAtualizado = widget.lote.copyWith(
      nome: () => _nomeController.text.trim(),
      descricao: () => _descricaoController.text.trim(),
      criterioAgrupamento: () => _criterioAgrupamentoController.text.trim(),
      propriedadeId: () => propriedadeIdEfetivo,
      aptidao: () => _aptidao,
      finalidade: () => _finalidade,
      sistemaCriacao: () => _sistemaCriacao,
      ativo: () => _ativo,
      areaAtualId: () => _areaSelecionada?.id,
    );

    print('🔍 Debug - propriedadeId efetivo usado: $propriedadeIdEfetivo');
    print('🔍 Debug - toJson: ${loteAtualizado.toJson()}');

    context.read<LoteBloc>().add(UpdateLoteEvent(loteAtualizado));
  }
}
