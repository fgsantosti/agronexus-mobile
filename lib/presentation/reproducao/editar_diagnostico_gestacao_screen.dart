import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:intl/intl.dart';

class EditarDiagnosticoGestacaoScreen extends StatefulWidget {
  final DiagnosticoGestacaoEntity diagnostico;

  const EditarDiagnosticoGestacaoScreen({
    super.key,
    required this.diagnostico,
  });

  @override
  State<EditarDiagnosticoGestacaoScreen> createState() => _EditarDiagnosticoGestacaoScreenState();
}

class _EditarDiagnosticoGestacaoScreenState extends State<EditarDiagnosticoGestacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers
  final _dataDiagnosticoController = TextEditingController();
  final _metodoController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Campos selecionados
  ResultadoDiagnostico? _resultadoSelecionado;

  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preencherCampos();
  }

  void _preencherCampos() {
    final diagnostico = widget.diagnostico;

    // Preencher campos com dados atuais
    _dataSelecionada = diagnostico.dataDiagnostico;
    _dataDiagnosticoController.text = _dateFormat.format(_dataSelecionada);
    _resultadoSelecionado = diagnostico.resultado;
    _metodoController.text = diagnostico.metodo;
    _observacoesController.text = diagnostico.observacoes;
  }

  @override
  void dispose() {
    _dataDiagnosticoController.dispose();
    _metodoController.dispose();
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
      firstDate: widget.diagnostico.inseminacao.dataInseminacao,
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
        _dataDiagnosticoController.text = _dateFormat.format(picked);
      });
    }
  }

  void _atualizarDiagnostico() {
    if (!_formKey.currentState!.validate()) return;
    if (_resultadoSelecionado == null) {
      _mostrarSnackbar('Selecione o resultado do diagnóstico');
      return;
    }

    // Validar se a data do diagnóstico é posterior à data da inseminação
    if (_dataSelecionada.isBefore(widget.diagnostico.inseminacao.dataInseminacao)) {
      _mostrarSnackbar('A data do diagnóstico deve ser posterior à data da inseminação');
      return;
    }

    final diagnosticoAtualizado = DiagnosticoGestacaoEntity(
      id: widget.diagnostico.id,
      inseminacao: widget.diagnostico.inseminacao,
      dataDiagnostico: _dataSelecionada,
      resultado: _resultadoSelecionado!,
      metodo: _metodoController.text.trim(),
      observacoes: _observacoesController.text.trim(), // Sempre obrigatório
      dataPartoPrevista: _resultadoSelecionado == ResultadoDiagnostico.positivo ? _calcularDataPartoPrevista() : null,
    );

    context.read<ReproducaoBloc>().add(UpdateDiagnosticoGestacaoEvent(widget.diagnostico.id, diagnosticoAtualizado));
  }

  DateTime? _calcularDataPartoPrevista() {
    // Assumindo período de gestação de 280 dias (bovinos)
    // Isso deveria vir da espécie do animal, mas por simplicidade usamos 280 dias
    return widget.diagnostico.inseminacao.dataInseminacao.add(const Duration(days: 280));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Editar Diagnóstico',
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is DiagnosticoGestacaoUpdated) {
            _mostrarSnackbar('Diagnóstico atualizado com sucesso!');
            Navigator.of(context).pop(true);
          } else if (state is ReproducaoError) {
            _mostrarSnackbar('Erro: ${state.message}');
            setState(() {
              _isLoading = false;
            });
          } else if (state is ReproducaoLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações da inseminação (somente leitura)
                _buildInfoInseminacao(),
                const SizedBox(height: 24),

                // Data do diagnóstico
                _buildDataDiagnostico(),
                const SizedBox(height: 16),

                // Resultado
                _buildResultado(),
                const SizedBox(height: 16),

                // Método
                _buildMetodo(),
                const SizedBox(height: 16),

                // Observações
                _buildObservacoes(),
                const SizedBox(height: 16),

                // Data de parto prevista (se positivo)
                _buildDataPartoPrevista(),
                const SizedBox(height: 24),

                // Botão de atualizar
                _buildBotaoAtualizar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoInseminacao() {
    final inseminacao = widget.diagnostico.inseminacao;
    final animal = inseminacao.animal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Informações da Inseminação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Animal', '${animal.identificacaoUnica} - ${animal.nomeRegistro ?? animal.situacao}'),
            _buildInfoItem('Data da Inseminação', _dateFormat.format(inseminacao.dataInseminacao)),
            _buildInfoItem('Tipo', inseminacao.tipo.label),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDiagnostico() {
    return TextFormField(
      controller: _dataDiagnosticoController,
      decoration: const InputDecoration(
        labelText: 'Data do Diagnóstico*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        hintText: 'Selecione a data do diagnóstico',
      ),
      readOnly: true,
      onTap: _selecionarData,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione a data do diagnóstico';
        }
        return null;
      },
    );
  }

  Widget _buildResultado() {
    return DropdownButtonFormField<ResultadoDiagnostico>(
      value: _resultadoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Resultado do Diagnóstico*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment_turned_in),
      ),
      items: ResultadoDiagnostico.values.map((resultado) {
        return DropdownMenuItem<ResultadoDiagnostico>(
          value: resultado,
          child: Row(
            children: [
              Icon(
                resultado == ResultadoDiagnostico.positivo ? Icons.check_circle : Icons.cancel,
                color: resultado == ResultadoDiagnostico.positivo ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(resultado.label),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _resultadoSelecionado = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecione o resultado do diagnóstico';
        }
        return null;
      },
    );
  }

  Widget _buildMetodo() {
    return TextFormField(
      controller: _metodoController,
      decoration: const InputDecoration(
        labelText: 'Método Utilizado*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.biotech),
        hintText: 'Ex: Ultrassom, Palpação, Exame de sangue',
      ),
      maxLines: 1,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe o método utilizado';
        }
        return null;
      },
    );
  }

  Widget _buildObservacoes() {
    return TextFormField(
      controller: _observacoesController,
      decoration: const InputDecoration(
        labelText: 'Observações*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.notes),
        hintText: 'Observações adicionais sobre o diagnóstico',
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'As observações são obrigatórias';
        }
        return null;
      },
    );
  }

  Widget _buildDataPartoPrevista() {
    final dataPartoPrevista = _calcularDataPartoPrevista();
    if (dataPartoPrevista == null || _resultadoSelecionado != ResultadoDiagnostico.positivo) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.baby_changing_station, color: Colors.green.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data de Parto Prevista',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  _dateFormat.format(dataPartoPrevista),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoAtualizar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _atualizarDiagnostico,
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
                'Atualizar Diagnóstico',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
