import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/presentation/bloc/animal/animal_state.dart';
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

class _AnimalFormScreenState extends State<AnimalFormScreen> {
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

  @override
  void initState() {
    super.initState();

    // Carregar opções de cadastro
    context.read<AnimalBloc>().add(const LoadOpcoesCadastroEvent());

    // Se for edição, preencher os campos
    if (widget.animal != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal == null ? 'Cadastrar Animal' : 'Editar Animal'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AnimalBloc, AnimalState>(
        listener: (context, state) {
          if (state is OpcoesCadastroLoaded) {
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

                  // Carregar raças para a espécie
                  context.read<AnimalBloc>().add(LoadRacasByEspecieEvent(_especieSelecionada!.id));
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
          } else if (state is AnimalCreated || state is AnimalUpdated) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.animal == null ? 'Animal cadastrado com sucesso!' : 'Animal atualizado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AnimalError) {
            // Mostrar apenas dialog de erro
            _showErrorDialog(context, state.message);
          }
        },
        child: Column(
          children: [
            // Indicador de progresso
            _buildProgressIndicator(),

            // Conteúdo do formulário
            Expanded(
              child: PageView(
                controller: _pageController,
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
                });

                if (value != null) {
                  context.read<AnimalBloc>().add(LoadRacasByEspecieEvent(value.id));
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
            items: CategoriaAnimal.values.map((categoria) {
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
                labelText: 'Propriedade',
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
                });
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
              items: _opcoesCadastro!.posiveisPais.map((animal) {
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
              items: _opcoesCadastro!.possiveisMaes.map((animal) {
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Botão Voltar
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Voltar'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          // Botão Próximo/Salvar
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                if (_currentStep < _totalSteps - 1) {
                  // Validar passo atual antes de prosseguir
                  if (_validateCurrentStep()) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else {
                  // Salvar animal
                  _saveAnimal();
                }
              },
              child: Text(
                _currentStep < _totalSteps - 1 ? 'Próximo' : 'Salvar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _identificacaoController.text.isNotEmpty && _sexoSelecionado != null && _dataNascimento != null;
      case 1:
        return _especieSelecionada != null && _categoriaSelecionada != null;
      case 2:
        return true; // Campos opcionais
      case 3:
        return true; // Campos opcionais
      default:
        return true;
    }
  }

  void _saveAnimal() {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

    if (widget.animal == null) {
      context.read<AnimalBloc>().add(CreateAnimalEvent(animal));
    } else {
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
