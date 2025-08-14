import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/presentation/bloc/animal/animal_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/presentation/widgets/animal_search_field.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:intl/intl.dart';

class CadastroPartoScreen extends StatefulWidget {
  const CadastroPartoScreen({super.key});

  @override
  State<CadastroPartoScreen> createState() => _CadastroPartoScreenState();
}

class _CadastroPartoScreenState extends State<CadastroPartoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers
  final _dataPartoController = TextEditingController();
  final _pesoNascimentoController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Campos selecionados
  AnimalEntity? _maeSelecionada;
  AnimalEntity? _bezerroSelecionado;
  ResultadoParto? _resultadoSelecionado;
  DificuldadeParto? _dificuldadeSelecionada;

  // Opções disponíveis
  List<AnimalEntity> _femeasDisponiveis = [];
  List<AnimalEntity> _animaisDisponiveis = [];
  List<DiagnosticoGestacaoEntity> _gestacoesDisponiveis = [];
  List<AnimalEntity> _filhosDaMae = [];

  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingFilhos = false;

  @override
  void initState() {
    super.initState();
    _dataPartoController.text = _dateFormat.format(_dataSelecionada);
    _carregarOpcoes();
  }

  void _carregarOpcoes() {
    // Carregar gestações pendentes de parto
    context.read<ReproducaoBloc>().add(LoadGestacoesPendentePartoEvent());
    // Carregar animais para seleção de cria
    context.read<AnimalBloc>().add(LoadAnimaisEvent());
  }

  void _carregarFilhosDaMae(String maeId) {
    setState(() => _isLoadingFilhos = true);
    context.read<AnimalBloc>().add(LoadFilhosDaMaeEvent(maeId));
  }

  @override
  void dispose() {
    _dataPartoController.dispose();
    _pesoNascimentoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _mostrarSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
        _dataPartoController.text = _dateFormat.format(picked);
      });
    }
  }

  void _salvarParto() {
    if (!_formKey.currentState!.validate()) return;
    if (_maeSelecionada == null) {
      _mostrarSnackbar('Selecione a mãe');
      return;
    }
    if (_resultadoSelecionado == null) {
      _mostrarSnackbar('Selecione o resultado do parto');
      return;
    }
    if (_dificuldadeSelecionada == null) {
      _mostrarSnackbar('Selecione a dificuldade do parto');
      return;
    }

    setState(() => _isLoading = true);

    final parto = PartoEntity(
      id: '', // Será gerado pela API
      mae: _maeSelecionada!,
      dataParto: _dataSelecionada,
      resultado: _resultadoSelecionado!,
      dificuldade: _dificuldadeSelecionada!,
      bezerro: _bezerroSelecionado,
      pesoNascimento: _pesoNascimentoController.text.isNotEmpty ? double.tryParse(_pesoNascimentoController.text.replaceAll(',', '.')) : null,
      observacoes: _observacoesController.text.trim().isNotEmpty ? _observacoesController.text.trim() : '',
    );

    context.read<ReproducaoBloc>().add(CreatePartoEvent(parto));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Cadastrar Parto',
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ReproducaoBloc, ReproducaoState>(
            listener: (context, state) {
              print('DEBUG SCREEN - Estado recebido: ${state.runtimeType}');

              if (state is PartoCreated) {
                print('DEBUG SCREEN - Parto criado com sucesso! Redirecionando...');
                setState(() => _isLoading = false);

                // Aguardar um frame antes de redirecionar para garantir que o estado seja atualizado
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Parto cadastrado com sucesso!')),
                    );
                  }
                });
              }

              if (state is GestacoesPendentePartoLoaded) {
                setState(() {
                  _gestacoesDisponiveis = state.gestacoes;
                  _femeasDisponiveis = state.gestacoes.map((g) => g.inseminacao.animal).toList();
                });
              }

              if (state is ReproducaoError) {
                print('DEBUG SCREEN - Erro: ${state.message}');
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: ${state.message}')),
                );
              }

              if (state is ReproducaoLoading) {
                // Não definir _isLoading aqui para evitar conflitos
                print('DEBUG SCREEN - Estado de loading recebido');
              }
            },
          ),
          BlocListener<AnimalBloc, AnimalState>(
            listener: (context, state) {
              if (state is AnimaisLoaded) {
                setState(() {
                  _animaisDisponiveis = state.animais;
                });
              }

              if (state is FilhosDaMaeLoaded) {
                setState(() {
                  _filhosDaMae = state.filhos;
                  _isLoadingFilhos = false;
                });
              }

              if (state is AnimalError) {
                setState(() => _isLoadingFilhos = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao carregar dados: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Mostrar mensagem se não há gestações pendentes
    if (_gestacoesDisponiveis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pregnant_woman, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhuma gestação pendente',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há fêmeas com prenhez confirmada\ndisponíveis para registro de parto',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<ReproducaoBloc>().add(LoadGestacoesPendentePartoEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seleção da mãe com informações da gestação
            AnimalSearchField(
              animais: _femeasDisponiveis,
              animalSelecionado: _maeSelecionada,
              onChanged: (animal) {
                setState(() => _maeSelecionada = animal);
                if (animal != null && animal.id != null) {
                  _carregarFilhosDaMae(animal.id!);
                } else {
                  setState(() {
                    _filhosDaMae = [];
                    _isLoadingFilhos = false;
                  });
                }
              },
              labelText: 'Mãe (Gestação Confirmada) *',
              apenasFemeas: true,
              validator: (value) {
                if (_maeSelecionada == null) {
                  return 'Selecione a mãe';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Informações da gestação selecionada
            if (_maeSelecionada != null) ...[
              _buildGestacaoInfo(),
              const SizedBox(height: 16),
            ],

            // Crias da mãe selecionada
            if (_maeSelecionada != null) ...[
              _buildFilhosDaMae(),
              const SizedBox(height: 16),
            ],

            // Data do parto
            TextFormField(
              controller: _dataPartoController,
              decoration: InputDecoration(
                labelText: 'Data do Parto *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              readOnly: true,
              onTap: _selecionarData,
              validator: (value) => value?.isEmpty == true ? 'Selecione a data' : null,
            ),

            const SizedBox(height: 16),

            // Resultado do parto
            DropdownButtonFormField<ResultadoParto>(
              decoration: InputDecoration(
                labelText: 'Resultado do Parto *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              value: _resultadoSelecionado,
              items: ResultadoParto.values
                  .map((resultado) => DropdownMenuItem(
                        value: resultado,
                        child: Text(resultado.label),
                      ))
                  .toList(),
              onChanged: (resultado) => setState(() => _resultadoSelecionado = resultado),
              validator: (value) => value == null ? 'Selecione o resultado' : null,
            ),

            const SizedBox(height: 16),

            // Dificuldade do parto
            DropdownButtonFormField<DificuldadeParto>(
              decoration: InputDecoration(
                labelText: 'Dificuldade do Parto *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              value: _dificuldadeSelecionada,
              items: DificuldadeParto.values
                  .map((dificuldade) => DropdownMenuItem(
                        value: dificuldade,
                        child: Text(dificuldade.label),
                      ))
                  .toList(),
              onChanged: (dificuldade) => setState(() => _dificuldadeSelecionada = dificuldade),
              validator: (value) => value == null ? 'Selecione a dificuldade' : null,
            ),

            const SizedBox(height: 16),

            // Seleção da cria (opcional) - apenas para nascido vivo
            if (_resultadoSelecionado == ResultadoParto.nascidoVivo) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.child_care, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Informações da Cria',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Campo de seleção da cria
                    AnimalSearchField(
                      animais: _animaisDisponiveis,
                      animalSelecionado: _bezerroSelecionado,
                      onChanged: (animal) => setState(() => _bezerroSelecionado = animal),
                      labelText: 'Selecionar Cria (Opcional)',
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Vincule a cria que nasceu neste parto. Digite o número de identificação para buscar.',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Peso ao nascimento
              TextFormField(
                controller: _pesoNascimentoController,
                decoration: InputDecoration(
                  labelText: 'Peso ao Nascimento (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: const Icon(Icons.monitor_weight),
                  helperText: 'Opcional, mas recomendado para controle',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final peso = double.tryParse(value.replaceAll(',', '.'));
                    if (peso == null || peso <= 0) {
                      return 'Digite um peso válido';
                    }
                    if (peso > 100) {
                      return 'Peso muito alto para um bezerro';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
            ],

            // Observações
            TextFormField(
              controller: _observacoesController,
              decoration: InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Informações adicionais sobre o parto...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              maxLines: 3,
              maxLength: 500,
            ),

            const SizedBox(height: 32),

            // Informações adicionais
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Informações Importantes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Para partos com nascido vivo, você pode vincular a cria\n'
                    '• O peso ao nascimento é opcional mas recomendado\n'
                    '• Registre observações sobre complicações ou cuidados especiais',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildBotaoSalvar(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGestacaoInfo() {
    // Buscar informações da gestação da mãe selecionada
    final gestacao = _gestacoesDisponiveis.firstWhere(
      (g) => g.inseminacao.animal.idAnimal == _maeSelecionada!.idAnimal,
    );

    // Calcular dias de gestação
    final diasGestacao = DateTime.now().difference(gestacao.inseminacao.dataInseminacao).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pregnant_woman, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Prenhez Confirmada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Informações da inseminação
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Inseminação: ${_dateFormat.format(gestacao.inseminacao.dataInseminacao)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Tipo de inseminação
          Row(
            children: [
              Icon(Icons.science, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Tipo: ${gestacao.inseminacao.tipo.label}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Diagnóstico
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                'Diagnóstico: ${_dateFormat.format(gestacao.dataDiagnostico)} (${gestacao.resultado.label})',
                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Dias de gestação
          Row(
            children: [
              Icon(Icons.timer, size: 16, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'Gestação: $diasGestacao dias',
                style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w500),
              ),
            ],
          ),

          // Data prevista do parto
          if (gestacao.dataPartoPrevista != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event_available, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Parto previsto: ${_dateFormat.format(gestacao.dataPartoPrevista!)}',
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Status da gestação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Text(
                  'Gestação Normal (270-300 dias)',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilhosDaMae() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: Colors.orange.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Crias da Mãe',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                  fontSize: 16,
                ),
              ),
              if (_isLoadingFilhos) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingFilhos)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Carregando filhos...'),
              ),
            )
          else if (_filhosDaMae.where((filho) => _isCategoriaInicial(filho.categoria)).isEmpty)
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nenhuma cria (bezerro, cabrito, cordeiro, etc.) registrada para esta mãe.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          else
            ...(_filhosDaMae
                .where((filho) => _isCategoriaInicial(filho.categoria))
                .map((filho) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: filho.sexo == Sexo.macho ? Colors.blue.shade100 : Colors.pink.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              filho.sexo == Sexo.macho ? Icons.male : Icons.female,
                              color: filho.sexo == Sexo.macho ? Colors.blue.shade600 : Colors.pink.shade600,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filho.identificacaoUnica,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (filho.nomeRegistro?.isNotEmpty == true)
                                  Text(
                                    filho.nomeRegistro!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                Text(
                                  '${filho.categoria.label} • ${filho.status.label}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _dateFormat.format(DateTime.parse(filho.dataNascimento)),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _calculateAge(DateTime.parse(filho.dataNascimento)),
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                .toList()),
        ],
      ),
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);

    if (difference.inDays < 30) {
      return '${difference.inDays} dias';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months meses';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingMonths = ((difference.inDays % 365) / 30).floor();
      if (remainingMonths > 0) {
        return '$years anos e $remainingMonths meses';
      } else {
        return '$years anos';
      }
    }
  }

  bool _isCategoriaInicial(CategoriaAnimal categoria) {
    // Categorias iniciais (crias/filhotes) de cada espécie
    const categoriasIniciais = [
      // Bovinos
      CategoriaAnimal.bezerro,
      CategoriaAnimal.bezerra,

      // Caprinos
      CategoriaAnimal.cabrito,
      CategoriaAnimal.cabrita,

      // Ovinos
      CategoriaAnimal.cordeiro,
      CategoriaAnimal.cordeira,

      // Equinos
      CategoriaAnimal.potro,

      // Suínos
      CategoriaAnimal.leitao,
    ];

    return categoriasIniciais.contains(categoria);
  }

  Widget _buildBotaoSalvar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _salvarParto,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Salvando...'),
                ],
              )
            : const Text(
                'Salvar Parto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
