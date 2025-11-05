import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_events.dart';
import 'package:agronexus/presentation/bloc/lote/lote_state.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart'; // Para PropriedadeSimples
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/presentation/bloc/area/area_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_event.dart';
import 'package:agronexus/presentation/bloc/area/area_state.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';
import 'package:agronexus/presentation/widgets/form_submit_protection_mixin.dart';

class CadastroLoteScreen extends StatefulWidget {
  final String? propriedadeId;
  final LoteEntity? loteInicial;

  const CadastroLoteScreen({super.key, this.propriedadeId, this.loteInicial});

  @override
  State<CadastroLoteScreen> createState() => _CadastroLoteScreenState();
}

class _CadastroLoteScreenState extends State<CadastroLoteScreen> with FormSubmitProtectionMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers para campos de texto
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _criterioAgrupamentoController = TextEditingController();

  // Propriedade e área selecionadas
  PropriedadeEntity? _propriedadeSelecionada;
  AreaEntity? _areaSelecionada;
  List<PropriedadeEntity> _propriedadesDisponiveis = [];
  List<AreaEntity> _areasDisponiveis = [];
  bool _loadingPropriedades = false;
  bool _loadingAreas = false;

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

  @override
  void initState() {
    super.initState();
    // Preencher campos se edição
    if (widget.loteInicial != null) {
      final l = widget.loteInicial!;
      _nomeController.text = l.nome;
      _descricaoController.text = l.descricao;
      _criterioAgrupamentoController.text = l.criterioAgrupamento;
      _aptidao = l.aptidao;
      _finalidade = l.finalidade;
      _sistemaCriacao = l.sistemaCriacao;
      _ativo = l.ativo;
    }
    _carregarPropriedades();
  }

  void _carregarPropriedades() {
    setState(() => _loadingPropriedades = true);
    context.read<PropriedadeBlocNew>().add(const LoadPropriedadesEvent());
  }

  void _carregarAreas(String propriedadeId) {
    setState(() {
      _loadingAreas = true;
      _areasDisponiveis = [];
      _areaSelecionada = null;
    });
    context.read<AreaBloc>().add(LoadAreasEvent(propriedadeId: propriedadeId));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _criterioAgrupamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(
        title: widget.loteInicial == null ? 'Novo Lote' : 'Editar Lote',
        showSaveButton: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoteBloc, LoteState>(
            listener: (context, state) {
              if (state is LoteCreated) {
                FormSnackBar.showSuccess(context, 'Lote cadastrado com sucesso!');
                safeNavigateBack();
              }

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
          BlocListener<PropriedadeBlocNew, PropriedadeState>(
            listener: (context, state) {
              if (state is PropriedadesLoaded) {
                setState(() {
                  _propriedadesDisponiveis = state.propriedades;
                  _loadingPropriedades = false;

                  // Prioridade: edição -> propriedade passada -> nenhuma
                  if (widget.loteInicial != null) {
                    try {
                      _propriedadeSelecionada = _propriedadesDisponiveis.firstWhere((p) => p.id == widget.loteInicial!.propriedadeId);
                      if (_propriedadeSelecionada != null) {
                        _carregarAreas(_propriedadeSelecionada!.id!);
                      }
                    } catch (_) {}
                  } else if (widget.propriedadeId != null) {
                    try {
                      _propriedadeSelecionada = _propriedadesDisponiveis.firstWhere((p) => p.id == widget.propriedadeId);
                      if (_propriedadeSelecionada != null) {
                        _carregarAreas(_propriedadeSelecionada!.id!);
                      }
                    } catch (_) {}
                  }
                });
              }

              if (state is PropriedadeError) {
                setState(() => _loadingPropriedades = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao carregar propriedades: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<AreaBloc, AreaState>(
            listener: (context, state) {
              if (state is AreasLoaded) {
                setState(() {
                  _areasDisponiveis = state.areas;
                  _loadingAreas = false;
                  if (widget.loteInicial != null && widget.loteInicial!.areaAtualId != null) {
                    try {
                      _areaSelecionada = _areasDisponiveis.firstWhere((a) => a.id == widget.loteInicial!.areaAtualId);
                    } catch (_) {}
                  }
                });
              } else if (state is AreaError) {
                setState(() => _loadingAreas = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao carregar áreas: ${state.message}')),
                );
              } else if (state is AreaLoading) {
                setState(() => _loadingAreas = true);
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
                            hintText: 'Descrição detalhada do lote',
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
                        // Dropdown de Propriedades
                        DropdownButtonFormField<PropriedadeEntity>(
                          value: _propriedadeSelecionada,
                          decoration: const InputDecoration(
                            labelText: 'Propriedade *',
                            hintText: 'Selecione uma propriedade',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home_work),
                          ),
                          items: _propriedadesDisponiveis.map((propriedade) {
                            return DropdownMenuItem(
                              value: propriedade,
                              child: Text(propriedade.nome),
                            );
                          }).toList(),
                          onChanged: _loadingPropriedades
                              ? null
                              : (value) {
                                  setState(() {
                                    _propriedadeSelecionada = value;
                                    if (value != null) {
                                      _carregarAreas(value.id!);
                                    } else {
                                      _areasDisponiveis = [];
                                      _areaSelecionada = null;
                                    }
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Propriedade é obrigatória';
                            }
                            return null;
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
                          onChanged: (_loadingAreas || _propriedadeSelecionada == null)
                              ? null
                              : (value) {
                                  setState(() => _areaSelecionada = value);
                                },
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

                // Características do Lote
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

                        // Aptidão
                        DropdownButtonFormField<String>(
                          value: _aptidao,
                          decoration: const InputDecoration(
                            labelText: 'Aptidão',
                            border: OutlineInputBorder(),
                          ),
                          items: _aptidaoOptions.map((option) {
                            return DropdownMenuItem(
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

                        // Finalidade
                        DropdownButtonFormField<String>(
                          value: _finalidade,
                          decoration: const InputDecoration(
                            labelText: 'Finalidade',
                            border: OutlineInputBorder(),
                          ),
                          items: _finalidadeOptions.map((option) {
                            return DropdownMenuItem(
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

                        // Sistema de Criação
                        DropdownButtonFormField<String>(
                          value: _sistemaCriacao,
                          decoration: const InputDecoration(
                            labelText: 'Sistema de Criação',
                            border: OutlineInputBorder(),
                          ),
                          items: _sistemaCriacaoOptions.map((option) {
                            return DropdownMenuItem(
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                FormPrimaryButton(
                  text: widget.loteInicial == null ? 'Cadastrar Lote' : 'Salvar Alterações',
                  onPressed: _salvar,
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

  void _salvar() {
    if (!canSubmit()) return;

    if (!_formKey.currentState!.validate()) {
      resetProtection();
      return;
    }
    if (_propriedadeSelecionada == null) {
      FormSnackBar.showError(context, 'Selecione uma propriedade');
      resetProtection();
      return;
    }

    markAsSubmitting();

    final lote = LoteEntity(
      id: widget.loteInicial?.id,
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      criterioAgrupamento: _criterioAgrupamentoController.text.trim().isEmpty ? '' : _criterioAgrupamentoController.text.trim(),
      propriedadeId: _propriedadeSelecionada!.id!,
      propriedade: PropriedadeSimples(
        id: _propriedadeSelecionada!.id!,
        nome: _propriedadeSelecionada!.nome,
      ),
      areaAtualId: _areaSelecionada?.id,
      aptidao: _aptidao,
      finalidade: _finalidade,
      sistemaCriacao: _sistemaCriacao,
      ativo: _ativo,
    );

    if (widget.loteInicial == null) {
      context.read<LoteBloc>().add(CreateLoteEvent(lote));
    } else {
      context.read<LoteBloc>().add(UpdateLoteEvent(lote));
    }
  }
}
