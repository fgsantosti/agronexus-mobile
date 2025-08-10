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

class CadastroLoteScreen extends StatefulWidget {
  final String? propriedadeId;
  final LoteEntity? loteInicial;

  const CadastroLoteScreen({super.key, this.propriedadeId, this.loteInicial});

  @override
  State<CadastroLoteScreen> createState() => _CadastroLoteScreenState();
}

class _CadastroLoteScreenState extends State<CadastroLoteScreen> {
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
  bool _isLoading = false;

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
      appBar: AppBar(
        title: Text(widget.loteInicial == null ? 'Novo Lote' : 'Editar Lote'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvar,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoteBloc, LoteState>(
            listener: (context, state) {
              if (state is LoteCreated) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lote cadastrado com sucesso!')),
                );
              }

              if (state is LoteUpdated) {
                // Retorna para a lista informando sucesso da edição
                Navigator.pop(context, true);
              }

              if (state is LoteError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (state is LoteLoading) {
                setState(() => _isLoading = true);
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    if (_propriedadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma propriedade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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
