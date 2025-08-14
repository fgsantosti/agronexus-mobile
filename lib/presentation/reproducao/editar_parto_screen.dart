import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:intl/intl.dart';

class EditarPartoScreen extends StatefulWidget {
  final PartoEntity parto;

  const EditarPartoScreen({
    super.key,
    required this.parto,
  });

  @override
  State<EditarPartoScreen> createState() => _EditarPartoScreenState();
}

class _EditarPartoScreenState extends State<EditarPartoScreen> {
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

  // Opções disponíveis (serão carregadas da API)
  List<AnimalEntity> _animaisDisponiveis = [];

  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preencherCampos();
    _carregarOpcoes();
  }

  void _preencherCampos() {
    final parto = widget.parto;

    // Preencher campos com dados atuais
    _dataSelecionada = parto.dataParto;
    _dataPartoController.text = _dateFormat.format(_dataSelecionada);
    _maeSelecionada = parto.mae;
    _bezerroSelecionado = parto.bezerro;
    _resultadoSelecionado = parto.resultado;
    _dificuldadeSelecionada = parto.dificuldade;

    if (parto.pesoNascimento != null) {
      _pesoNascimentoController.text = parto.pesoNascimento!.toStringAsFixed(1);
    }

    if (parto.observacoes != null) {
      _observacoesController.text = parto.observacoes!;
    }
  }

  void _carregarOpcoes() {
    // TODO: Implementar carregamento de opções da API
    // Por enquanto, vamos usar listas com os dados atuais
    setState(() {
      _animaisDisponiveis = widget.parto.bezerro != null ? [widget.parto.bezerro!] : [];
    });
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

  void _atualizarParto() {
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

    final partoAtualizado = PartoEntity(
      id: widget.parto.id,
      mae: _maeSelecionada!,
      dataParto: _dataSelecionada,
      resultado: _resultadoSelecionado!,
      dificuldade: _dificuldadeSelecionada!,
      bezerro: _bezerroSelecionado,
      pesoNascimento: _pesoNascimentoController.text.isNotEmpty ? double.tryParse(_pesoNascimentoController.text.replaceAll(',', '.')) : null,
      observacoes: _observacoesController.text.isNotEmpty ? _observacoesController.text : null,
    );

    context.read<ReproducaoBloc>().add(UpdatePartoEvent(widget.parto.id, partoAtualizado));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Parto'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _atualizarParto,
            child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is PartoUpdated) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parto atualizado com sucesso!')),
            );
          }

          if (state is ReproducaoError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações da mãe (não editável)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pets, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mãe',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Animal ${widget.parto.mae.idAnimal}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Data do parto
                TextFormField(
                  controller: _dataPartoController,
                  decoration: const InputDecoration(
                    labelText: 'Data do Parto *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selecionarData,
                  validator: (value) => value?.isEmpty == true ? 'Selecione a data' : null,
                ),

                const SizedBox(height: 16),

                // Resultado do parto
                DropdownButtonFormField<ResultadoParto>(
                  decoration: const InputDecoration(
                    labelText: 'Resultado do Parto *',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Dificuldade do Parto *',
                    border: OutlineInputBorder(),
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

                // Seleção do bezerro (opcional)
                if (_resultadoSelecionado == ResultadoParto.nascidoVivo) ...[
                  DropdownButtonFormField<AnimalEntity>(
                    decoration: const InputDecoration(
                      labelText: 'Cria',
                      border: OutlineInputBorder(),
                    ),
                    value: _bezerroSelecionado,
                    items: _animaisDisponiveis
                        .map((animal) => DropdownMenuItem(
                              value: animal,
                              child: Text('Animal ${animal.idAnimal}'),
                            ))
                        .toList(),
                    onChanged: (animal) => setState(() => _bezerroSelecionado = animal),
                  ),

                  const SizedBox(height: 16),

                  // Peso ao nascimento
                  TextFormField(
                    controller: _pesoNascimentoController,
                    decoration: const InputDecoration(
                      labelText: 'Peso ao Nascimento (kg)',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final peso = double.tryParse(value.replaceAll(',', '.'));
                        if (peso == null || peso <= 0) {
                          return 'Digite um peso válido';
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
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Informações adicionais
                Container(
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
                          Icon(Icons.edit_note, color: Colors.orange.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Editando Registro',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• A mãe não pode ser alterada após o cadastro\n'
                        '• Você pode alterar todos os outros dados conforme necessário\n'
                        '• Para nascidos vivos, vincule a cria se disponível',
                        style: TextStyle(
                          color: Colors.orange.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
