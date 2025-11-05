import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/presentation/bloc/animal/animal_state.dart';
import 'package:agronexus/presentation/widgets/form_submit_protection_mixin.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/models/opcoes_cadastro_animal.dart';

class AnimalFormScreen extends StatefulWidget {
  final AnimalEntity? animal; // Para edição

  const AnimalFormScreen({
    Key? key,
    this.animal,
  }) : super(key: key);

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> with FormSubmitProtectionMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Controllers para os campos do formulário
  final _identificacaoController = TextEditingController();
  final _nomeRegistroController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _valorCompraController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Estado do formulário
  Sexo? _sexoSelecionado;
  EspecieAnimal? _especieSelecionada;
  RacaAnimal? _racaSelecionada;
  CategoriaAnimal? _categoriaSelecionada;
  StatusAnimal _statusSelecionado = StatusAnimal.ativo;
  OrigemAnimal? _origemSelecionada;
  PropriedadeSimples? _propriedadeSelecionada;
  LoteSimples? _loteSelecionado;
  AnimalEntity? _paiSelecionado;
  AnimalEntity? _maeSelecionada;
  DateTime? _dataNascimento;
  DateTime? _dataCompra;

  OpcoesCadastroAnimal? _opcoesCadastro;
  List<RacaAnimal> _racasDisponiveis = [];
  List<String> _categoriasDisponiveis = [];

  // Proteção é fornecida pelo FormSubmitProtectionMixin
  // Não precisa mais declarar: _isSaving, _hasNavigated, _lastClickTime

  @override
  void initState() {
    super.initState();

    print('🚀 DEBUG FORM - initState chamado');
    print('🚀 DEBUG FORM - É edição: ${widget.animal != null}');

    // Resetar estados de navegação e salvamento usando o mixin
    resetAllProtection();

    // Carregar opções de cadastro
    context.read<AnimalBloc>().add(const LoadOpcoesCadastroEvent());

    // Se for edição, preencher os campos
    if (widget.animal != null) {
      print('🚀 DEBUG FORM - Preenchendo campos para edição: ${widget.animal!.identificacaoUnica}');
      _preencherCamposEdicao();
    }
  }

  void _preencherCamposEdicao() {
    final animal = widget.animal!;
    _identificacaoController.text = animal.identificacaoUnica;
    _nomeRegistroController.text = animal.nomeRegistro ?? '';
    _observacoesController.text = animal.observacoes ?? '';

    if (animal.valorCompra != null) {
      _valorCompraController.text = animal.valorCompra!.toString();
    }

    _sexoSelecionado = animal.sexo;
    _especieSelecionada = animal.especie;
    _racaSelecionada = animal.raca;
    _categoriaSelecionada = animal.categoria;
    _statusSelecionado = animal.status;
    _origemSelecionada = animal.origem;
    _propriedadeSelecionada = animal.propriedade;
    _loteSelecionado = animal.loteAtual;
    _paiSelecionado = animal.pai;
    _maeSelecionada = animal.mae;

    // Parse das datas
    if (animal.dataNascimento.isNotEmpty) {
      try {
        _dataNascimento = DateTime.parse(animal.dataNascimento);
        _dataNascimentoController.text = '${_dataNascimento!.day.toString().padLeft(2, '0')}/'
            '${_dataNascimento!.month.toString().padLeft(2, '0')}/'
            '${_dataNascimento!.year}';
      } catch (e) {
        print('Erro ao fazer parse da data de nascimento: $e');
      }
    }

    if (animal.dataCompra != null && animal.dataCompra!.isNotEmpty) {
      try {
        _dataCompra = DateTime.parse(animal.dataCompra!);
      } catch (e) {
        print('Erro ao fazer parse da data de compra: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _identificacaoController.dispose();
    _nomeRegistroController.dispose();
    _dataNascimentoController.dispose();
    _valorCompraController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  /// Filtra possíveis mães baseado na propriedade, espécie e categoria selecionadas
  List<AnimalEntity> _getPossiveisMaesFiltradas() {
    if (_opcoesCadastro == null) return [];

    List<AnimalEntity> maes = _opcoesCadastro!.possiveisMaes;

    // Filtrar apenas fêmeas reprodutivas (categorias apropriadas para mães)
    final categoriasMaes = [
      CategoriaAnimal.vaca, // Bovinos
      CategoriaAnimal.cabra, // Caprinos
      CategoriaAnimal.ovelha, // Ovinos
      CategoriaAnimal.egua, // Equinos
      // Para suínos, usamos 'porco' já que não há distinção específica de categoria por sexo
    ];

    maes = maes.where((animal) {
      // Verifica se é uma categoria reprodutiva feminina específica
      if (categoriasMaes.contains(animal.categoria)) {
        return true;
      }

      // Para suínos, filtra por sexo feminino e categoria 'porco'
      if (animal.categoria == CategoriaAnimal.porco && animal.sexo == Sexo.femea) {
        return true;
      }

      return false;
    }).toList();

    // Filtrar por propriedade se selecionada
    if (_propriedadeSelecionada != null) {
      maes = maes.where((animal) => animal.propriedade?.id == _propriedadeSelecionada!.id).toList();
    }

    // Filtrar por espécie se selecionada
    if (_especieSelecionada != null) {
      maes = maes.where((animal) => animal.especie?.id == _especieSelecionada!.id).toList();
    }

    // Garantir que a mãe atualmente selecionada sempre esteja na lista (para edição)
    if (_maeSelecionada != null && _maeSelecionada!.id != null) {
      final existeNaLista = maes.any((animal) => animal.id == _maeSelecionada!.id);
      if (!existeNaLista) {
        maes.add(_maeSelecionada!);
      }
    }

    return maes;
  }

  /// Filtra possíveis pais baseado na propriedade, espécie e categoria selecionadas
  List<AnimalEntity> _getPossiveisPaisFiltrados() {
    if (_opcoesCadastro == null) return [];

    List<AnimalEntity> pais = _opcoesCadastro!.posiveisPais;

    // Filtrar apenas machos reprodutivos (categorias apropriadas para pais)
    final categoriasPais = [
      CategoriaAnimal.touro, // Bovinos
      CategoriaAnimal.bode, // Caprinos
      CategoriaAnimal.carneiro, // Ovinos
      CategoriaAnimal.cavalo, // Equinos
      // Para suínos, usamos 'porco' já que não há distinção específica de categoria por sexo
    ];

    pais = pais.where((animal) {
      // Verifica se é uma categoria reprodutiva masculina específica
      if (categoriasPais.contains(animal.categoria)) {
        return true;
      }

      // Para suínos, filtra por sexo masculino e categoria 'porco'
      if (animal.categoria == CategoriaAnimal.porco && animal.sexo == Sexo.macho) {
        return true;
      }

      return false;
    }).toList();

    // Filtrar por propriedade se selecionada
    if (_propriedadeSelecionada != null) {
      pais = pais.where((animal) => animal.propriedade?.id == _propriedadeSelecionada!.id).toList();
    }

    // Filtrar por espécie se selecionada
    if (_especieSelecionada != null) {
      pais = pais.where((animal) => animal.especie?.id == _especieSelecionada!.id).toList();
    }

    // Garantir que o pai atualmente selecionado sempre esteja na lista (para edição)
    if (_paiSelecionado != null && _paiSelecionado!.id != null) {
      final existeNaLista = pais.any((animal) => animal.id == _paiSelecionado!.id);
      if (!existeNaLista) {
        pais.add(_paiSelecionado!);
      }
    }

    return pais;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(
        title: widget.animal == null ? 'Cadastrar Animal' : 'Editar Animal',
        showSaveButton: false, // Salvar será no último step
      ),
      body: BlocListener<AnimalBloc, AnimalState>(
        listener: (context, state) {
          print('📢 DEBUG FORM - Listener recebeu estado: ${state.runtimeType}');

          if (state is OpcoesCadastroLoaded) {
            print('📋 DEBUG FORM - Opções de cadastro carregadas');
            setState(() {
              _opcoesCadastro = state.opcoes;

              // Se estivermos editando, encontrar e atualizar referências corretas
              if (widget.animal != null) {
                // Encontrar a espécie correta na lista de opções
                if (_especieSelecionada != null) {
                  final especieCorreta = state.opcoes.especies.firstWhere(
                    (e) => e.id == _especieSelecionada!.id,
                    orElse: () => _especieSelecionada!,
                  );
                  _especieSelecionada = especieCorreta;

                  // Carregar raças e categorias para a espécie
                  context.read<AnimalBloc>().add(LoadRacasByEspecieEvent(_especieSelecionada!.id));
                  context.read<AnimalBloc>().add(LoadCategoriasByEspecieEvent(_especieSelecionada!.id));
                }

                // Encontrar a propriedade correta na lista de opções
                if (_propriedadeSelecionada != null) {
                  final propriedadeCorreta = state.opcoes.propriedades.firstWhere(
                    (p) => p.id == _propriedadeSelecionada!.id,
                    orElse: () => _propriedadeSelecionada!,
                  );
                  _propriedadeSelecionada = propriedadeCorreta;
                }

                // Encontrar o lote correto na lista de opções
                if (_loteSelecionado != null) {
                  final loteCorreto = state.opcoes.lotes.firstWhere(
                    (l) => l.id == _loteSelecionado!.id,
                    orElse: () => _loteSelecionado!,
                  );
                  _loteSelecionado = loteCorreto;
                }

                // Sincronizar pai e mãe selecionados com as listas de opções
                if (_paiSelecionado != null) {
                  final paiCorreto = state.opcoes.posiveisPais.firstWhere(
                    (p) => p.id == _paiSelecionado!.id,
                    orElse: () => _paiSelecionado!,
                  );
                  _paiSelecionado = paiCorreto;
                }

                if (_maeSelecionada != null) {
                  final maeCorreta = state.opcoes.possiveisMaes.firstWhere(
                    (m) => m.id == _maeSelecionada!.id,
                    orElse: () => _maeSelecionada!,
                  );
                  _maeSelecionada = maeCorreta;
                }
              }
            });
          } else if (state is RacasLoaded) {
            setState(() {
              _racasDisponiveis = state.racas;

              // Se estivermos editando, encontrar a raça correta na lista
              if (widget.animal != null && _racaSelecionada != null) {
                final racaCorreta = state.racas.firstWhere(
                  (r) => r.id == _racaSelecionada!.id,
                  orElse: () => _racaSelecionada!,
                );
                _racaSelecionada = racaCorreta;
              }
            });
          } else if (state is CategoriasLoaded) {
            setState(() {
              _categoriasDisponiveis = state.categorias;
            });
          } else if (state is AnimalCreated || state is AnimalUpdated) {
            print('🔄 DEBUG FORM - Estado recebido: ${state.runtimeType}');
            print('🔄 DEBUG FORM - hasNavigated: $hasNavigated');
            print('🔄 DEBUG FORM - isSaving: $isSaving');
            print('🔄 DEBUG FORM - mounted: $mounted');

            // Prevenir navegação duplicada usando o mixin
            if (hasNavigated) {
              print('⚠️ DEBUG FORM - Navegação já realizada, ignorando...');
              return;
            }

            // Retorna o animal criado/atualizado para a tela anterior para atualização otimista do cache
            final returnedAnimal = state is AnimalCreated ? state.animal : (state as AnimalUpdated).animal;
            print('✅ DEBUG FORM - Animal retornado: ${returnedAnimal.identificacaoUnica}');

            // Mostrar SnackBar e navegar usando o mixin
            showProtectedSnackBar(
              widget.animal == null ? 'Animal cadastrado com sucesso!' : 'Animal atualizado com sucesso!',
            );
            safeNavigateBack(result: returnedAnimal);
          } else if (state is AnimalError) {
            print('❌ DEBUG FORM - Erro recebido: ${state.message}');
            resetProtection(); // Reseta para permitir nova tentativa
            // Mostrar apenas dialog de erro
            if (mounted) {
              _showErrorDialog(context, state.message);
            }
          } else if (state is AnimalLoading) {
            print('⏳ DEBUG FORM - Estado de loading recebido');
          }
        },
        child: wrapWithProtection(
          child: Column(
            children: [
              // Indicador de progresso
              _buildProgressIndicator(),

              // Conteúdo do formulário
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: isSaving ? const NeverScrollableScrollPhysics() : null,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildStep1(), // Informações básicas
                    _buildStep2(), // Espécie, raça e categoria
                    _buildStep3(), // Genealogia e localização
                    _buildStep4(), // Dados adicionais e observações
                  ],
                ),
              ),

              // Botões de navegação
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < _totalSteps - 1 ? 8 : 0,
              ),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStepTitle(index),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.green : Colors.grey,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Básico';
      case 1:
        return 'Espécie';
      case 2:
        return 'Genealogia';
      case 3:
        return 'Adicionais';
      default:
        return '';
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Básicas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),

          // Identificação única
          TextFormField(
            controller: _identificacaoController,
            decoration: const InputDecoration(
              labelText: 'Identificação Única *',
              hintText: 'Ex: Brinco, Chip, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Nome do registro
          TextFormField(
            controller: _nomeRegistroController,
            decoration: const InputDecoration(
              labelText: 'Nome do Registro',
              hintText: 'Nome opcional do animal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
          ),

          const SizedBox(height: 16),

          // Sexo
          DropdownButtonFormField<Sexo>(
            value: _sexoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Sexo *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.wc),
            ),
            items: Sexo.values.map((sexo) {
              return DropdownMenuItem(
                value: sexo,
                child: Text(sexo.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sexoSelecionado = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Data de nascimento
          TextFormField(
            controller: _dataNascimentoController,
            decoration: const InputDecoration(
              labelText: 'Data de Nascimento *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dataNascimento ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _dataNascimento = date;
                  _dataNascimentoController.text = '${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}';
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Status
          DropdownButtonFormField<StatusAnimal>(
            value: _statusSelecionado,
            decoration: const InputDecoration(
              labelText: 'Status *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info),
            ),
            items: StatusAnimal.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _statusSelecionado = value ?? StatusAnimal.ativo;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Espécie e Raça',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),

          // Espécie
          if (_opcoesCadastro != null)
            DropdownButtonFormField<EspecieAnimal>(
              value: _especieSelecionada,
              decoration: const InputDecoration(
                labelText: 'Espécie *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _opcoesCadastro!.especies.map((especie) {
                return DropdownMenuItem(
                  value: especie,
                  child: Text(especie.nomeDisplay),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _especieSelecionada = value;
                  _racaSelecionada = null;
                  _categoriaSelecionada = null;
                  _racasDisponiveis = [];
                  _categoriasDisponiveis = [];

                  // Limpar seleções de pai e mãe quando a espécie mudar
                  // para garantir que apenas animais da mesma espécie sejam selecionáveis
                  if (_paiSelecionado != null && _paiSelecionado!.especie?.id != value?.id) {
                    _paiSelecionado = null;
                  }
                  if (_maeSelecionada != null && _maeSelecionada!.especie?.id != value?.id) {
                    _maeSelecionada = null;
                  }
                });

                if (value != null) {
                  context.read<AnimalBloc>().add(LoadRacasByEspecieEvent(value.id));
                  context.read<AnimalBloc>().add(LoadCategoriasByEspecieEvent(value.id));
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),

          const SizedBox(height: 16),

          // Raça
          DropdownButtonFormField<RacaAnimal>(
            value: _racaSelecionada,
            decoration: const InputDecoration(
              labelText: 'Raça',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
            ),
            items: _racasDisponiveis.map((raca) {
              return DropdownMenuItem(
                value: raca,
                child: Text(raca.nome),
              );
            }).toList(),
            onChanged: _especieSelecionada != null
                ? (value) {
                    setState(() {
                      _racaSelecionada = value;
                    });
                  }
                : null,
          ),

          const SizedBox(height: 16),

          // Categoria
          DropdownButtonFormField<CategoriaAnimal>(
            value: _categoriaSelecionada,
            decoration: const InputDecoration(
              labelText: 'Categoria *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            items: _categoriasDisponiveis.map((categoriaString) {
              final categoria = CategoriaAnimal.fromString(categoriaString);
              return DropdownMenuItem(
                value: categoria,
                child: Text(categoria.label),
              );
            }).toList(),
            onChanged: _especieSelecionada != null
                ? (value) {
                    setState(() {
                      _categoriaSelecionada = value;
                    });
                  }
                : null,
            validator: (value) {
              if (value == null) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Genealogia e Localização',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),

          // Propriedade
          if (_opcoesCadastro != null)
            DropdownButtonFormField<PropriedadeSimples>(
              value: _propriedadeSelecionada,
              decoration: const InputDecoration(
                labelText: 'Propriedade *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              items: _opcoesCadastro!.propriedades.map((propriedade) {
                return DropdownMenuItem(
                  value: propriedade,
                  child: Text(propriedade.nome),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _propriedadeSelecionada = value;
                  _loteSelecionado = null; // Reset lote ao mudar propriedade

                  // Limpar seleções de pai e mãe quando a propriedade mudar
                  // para garantir que apenas animais da mesma propriedade sejam selecionáveis
                  if (_paiSelecionado != null && _paiSelecionado!.propriedade?.id != value?.id) {
                    _paiSelecionado = null;
                  }
                  if (_maeSelecionada != null && _maeSelecionada!.propriedade?.id != value?.id) {
                    _maeSelecionada = null;
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione uma propriedade';
                }
                return null;
              },
            ),

          const SizedBox(height: 16),

          // Lote
          if (_opcoesCadastro != null)
            DropdownButtonFormField<LoteSimples>(
              value: _loteSelecionado,
              decoration: const InputDecoration(
                labelText: 'Lote Atual',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _opcoesCadastro!.lotes.map((lote) {
                return DropdownMenuItem(
                  value: lote,
                  child: Text(lote.nome),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _loteSelecionado = value;
                });
              },
            ),

          const SizedBox(height: 16),

          // Pai
          if (_opcoesCadastro != null)
            DropdownButtonFormField<AnimalEntity>(
              value: _paiSelecionado,
              decoration: const InputDecoration(
                labelText: 'Pai',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.male),
              ),
              items: _getPossiveisPaisFiltrados().map((animal) {
                return DropdownMenuItem(
                  value: animal,
                  child: Text('${animal.identificacaoUnica} - ${animal.nomeRegistro ?? 'Sem nome'}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _paiSelecionado = value;
                });
              },
            ),

          const SizedBox(height: 16),

          // Mãe
          if (_opcoesCadastro != null)
            DropdownButtonFormField<AnimalEntity>(
              value: _maeSelecionada,
              decoration: const InputDecoration(
                labelText: 'Mãe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.female),
              ),
              items: _getPossiveisMaesFiltradas().map((animal) {
                return DropdownMenuItem(
                  value: animal,
                  child: Text('${animal.identificacaoUnica} - ${animal.nomeRegistro ?? 'Sem nome'}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _maeSelecionada = value;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dados Adicionais',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),

          // Data de compra
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Data de Compra',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.shopping_cart),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: _dataCompra != null
                  ? '${_dataCompra!.day.toString().padLeft(2, '0')}/'
                      '${_dataCompra!.month.toString().padLeft(2, '0')}/'
                      '${_dataCompra!.year}'
                  : '',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dataCompra ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _dataCompra = date;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Valor de compra
          TextFormField(
            controller: _valorCompraController,
            decoration: const InputDecoration(
              labelText: 'Valor de Compra (R\$)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          // Origem
          DropdownButtonFormField<OrigemAnimal>(
            value: _origemSelecionada,
            decoration: const InputDecoration(
              labelText: 'Origem do Animal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
            hint: const Text('Selecione a origem'),
            items: OrigemAnimal.values.map((origem) {
              return DropdownMenuItem<OrigemAnimal>(
                value: origem,
                child: Text(origem.label),
              );
            }).toList(),
            onChanged: (OrigemAnimal? novaOrigemSelecionada) {
              setState(() {
                _origemSelecionada = novaOrigemSelecionada;
              });
            },
          ),

          const SizedBox(height: 16),

          // Observações
          TextFormField(
            controller: _observacoesController,
            decoration: const InputDecoration(
              labelText: 'Observações',
              hintText: 'Informações adicionais sobre o animal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return FormStepButtons(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onPrevious: _currentStep > 0
          ? () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          : null,
      onNext: _currentStep < _totalSteps - 1
          ? () {
              if (_validateCurrentStep()) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          : null,
      onSave: _saveAnimal,
      isSaving: isSaving,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _identificacaoController.text.isNotEmpty && _sexoSelecionado != null && _dataNascimento != null;
      case 1:
        return _especieSelecionada != null && _categoriaSelecionada != null;
      case 2:
        // Propriedade é obrigatória
        if (_propriedadeSelecionada == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione uma propriedade'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      case 3:
        return true; // Campos opcionais
      default:
        return true;
    }
  }

  void _saveAnimal() {
    print('💾 DEBUG FORM - _saveAnimal chamado');

    // Usar proteção do mixin
    if (!canSubmit()) {
      return;
    }

    if (!_validateCurrentStep()) {
      print('⚠️ DEBUG FORM - Validação falhou');
      showProtectedSnackBar('Por favor, preencha todos os campos obrigatórios', isError: true);
      return;
    }

    // Validação adicional da propriedade antes de salvar
    if (_propriedadeSelecionada == null) {
      print('⚠️ DEBUG FORM - Propriedade não selecionada');
      showProtectedSnackBar('Selecione uma propriedade antes de salvar', isError: true);
      return;
    }

    print('✅ DEBUG FORM - Validação OK, iniciando salvamento...');
    print('✅ DEBUG FORM - Propriedade: ${_propriedadeSelecionada!.nome}');

    // Marcar como submetendo usando o mixin
    markAsSubmitting();

    final animal = AnimalEntity(
      id: widget.animal?.id,
      identificacaoUnica: _identificacaoController.text,
      nomeRegistro: _nomeRegistroController.text.isNotEmpty ? _nomeRegistroController.text : null,
      sexo: _sexoSelecionado!,
      dataNascimento: _dataNascimento!.toIso8601String().split('T')[0],
      categoria: _categoriaSelecionada!,
      status: _statusSelecionado,
      especie: _especieSelecionada,
      raca: _racaSelecionada,
      propriedade: _propriedadeSelecionada,
      loteAtual: _loteSelecionado,
      pai: _paiSelecionado,
      mae: _maeSelecionada,
      dataCompra: _dataCompra?.toIso8601String().split('T')[0],
      valorCompra: _valorCompraController.text.isNotEmpty ? double.tryParse(_valorCompraController.text) : null,
      origem: _origemSelecionada,
      observacoes: _observacoesController.text.isNotEmpty ? _observacoesController.text : null,
      // Campos legados para compatibilidade
      idAnimal: _identificacaoController.text,
      situacao: _categoriaSelecionada!.value,
      acaoDestino: AcaoDestino.permanece,
      lote: _loteSelecionado?.id ?? '',
      loteNome: _loteSelecionado?.nome ?? '',
      fazendaNome: _propriedadeSelecionada?.nome ?? '',
    );

    print('📤 DEBUG FORM - Enviando evento para o BLoC...');
    if (widget.animal == null) {
      print('📤 DEBUG FORM - CreateAnimalEvent');
      context.read<AnimalBloc>().add(CreateAnimalEvent(animal));
    } else {
      print('📤 DEBUG FORM - UpdateAnimalEvent (ID: ${widget.animal!.id})');
      context.read<AnimalBloc>().add(UpdateAnimalEvent(widget.animal!.id!, animal));
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Erro', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
