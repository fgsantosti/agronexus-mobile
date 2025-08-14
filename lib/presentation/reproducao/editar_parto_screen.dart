import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:intl/intl.dart';

class EditarPartoScreen extends StatefulWidget {
  final PartoEntity parto;

  const EditarPartoScreen({super.key, required this.parto});

  @override
  State<EditarPartoScreen> createState() => _EditarPartoScreenState();
}

class _EditarPartoScreenState extends State<EditarPartoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controladores
  final _dataPartoController = TextEditingController();
  final _pesoNascimentoController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Variáveis de estado
  DateTime _dataSelecionada = DateTime.now();
  AnimalEntity? _maeSelecionada;
  AnimalEntity? _bezerroSelecionado;
  ResultadoParto? _resultadoSelecionado;
  DificuldadeParto? _dificuldadeSelecionada;
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
    // TODO: Implementar carregamento de opções da API se necessário
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
      appBar: buildStandardAppBar(
        title: 'Editar Parto',
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is PartoUpdated) {
            setState(() => _isLoading = false);
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parto atualizado com sucesso!')),
            );
          }

          if (state is ReproducaoError) {
            setState(() => _isLoading = false);
            _mostrarSnackbar(state.message);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMaeSection(),
                  const SizedBox(height: 20),
                  _buildDataPartoField(),
                  const SizedBox(height: 20),
                  _buildResultadoField(),
                  const SizedBox(height: 20),
                  _buildDificuldadeField(),
                  const SizedBox(height: 20),
                  _buildBezerroSection(),
                  const SizedBox(height: 20),
                  _buildPesoNascimentoField(),
                  const SizedBox(height: 20),
                  _buildObservacoesField(),
                  const SizedBox(height: 24),
                  _buildBotaoAtualizar(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mãe *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.pets,
                  color: Colors.green.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animal Selecionado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _maeSelecionada?.identificacaoUnica ?? 'Animal ${widget.parto.mae.idAnimal}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataPartoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data do Parto *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dataPartoController,
          decoration: InputDecoration(
            hintText: 'Selecione a data do parto',
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
      ],
    );
  }

  Widget _buildResultadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resultado do Parto *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ResultadoParto>(
          decoration: InputDecoration(
            hintText: 'Selecione o resultado do parto',
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
      ],
    );
  }

  Widget _buildDificuldadeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dificuldade do Parto *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DificuldadeParto>(
          decoration: InputDecoration(
            hintText: 'Selecione a dificuldade do parto',
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
      ],
    );
  }

  Widget _buildBezerroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bezerro',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (_bezerroSelecionado != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.child_care,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bezerro Selecionado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _bezerroSelecionado?.identificacaoUnica ?? 'Animal ${_bezerroSelecionado?.idAnimal}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _bezerroSelecionado = null),
                  icon: const Icon(Icons.clear, color: Colors.red),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Nenhum bezerro selecionado',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPesoNascimentoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peso ao Nascimento (kg)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pesoNascimentoController,
          decoration: InputDecoration(
            hintText: 'Ex: 35.5',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.monitor_weight),
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
      ],
    );
  }

  Widget _buildObservacoesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observações',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _observacoesController,
          decoration: InputDecoration(
            hintText: 'Informações adicionais sobre o parto...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildBotaoAtualizar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _atualizarParto,
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
                  Text('Atualizando...'),
                ],
              )
            : const Text(
                'Atualizar Parto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
