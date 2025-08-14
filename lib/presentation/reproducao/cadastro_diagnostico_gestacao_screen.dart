import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/widgets/inseminacao_search_field.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:intl/intl.dart';

class CadastroDiagnosticoGestacaoScreen extends StatefulWidget {
  final InseminacaoEntity? inseminacaoSelecionada;

  const CadastroDiagnosticoGestacaoScreen({
    super.key,
    this.inseminacaoSelecionada,
  });

  @override
  State<CadastroDiagnosticoGestacaoScreen> createState() => _CadastroDiagnosticoGestacaoScreenState();
}

class _CadastroDiagnosticoGestacaoScreenState extends State<CadastroDiagnosticoGestacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers
  final _dataDiagnosticoController = TextEditingController();
  final _metodoController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Campos selecionados
  InseminacaoEntity? _inseminacaoSelecionada;
  ResultadoDiagnostico? _resultadoSelecionado;

  // Opções disponíveis
  List<InseminacaoEntity>? _inseminacoes;
  List<DiagnosticoGestacaoEntity>? _diagnosticos;

  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataDiagnosticoController.text = _dateFormat.format(_dataSelecionada);
    _inseminacaoSelecionada = widget.inseminacaoSelecionada;
    _carregarInseminacoes();
    _carregarDiagnosticos();
  }

  @override
  void dispose() {
    _dataDiagnosticoController.dispose();
    _metodoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _carregarInseminacoes() {
    // Carregar inseminações dos últimos 6 meses para diagnóstico
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month - 6, 1);
    context.read<ReproducaoBloc>().add(
          LoadInseminacoesEvent(
            dataInicio: inicio,
            dataFim: now,
          ),
        );
  }

  void _carregarDiagnosticos() {
    // Carregar diagnósticos existentes para evitar duplicatas
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month - 6, 1);
    context.read<ReproducaoBloc>().add(
          LoadDiagnosticosGestacaoEvent(
            dataInicio: inicio,
            dataFim: now,
          ),
        );
  }

  Future<void> _selecionarData() async {
    DateTime? firstDate = DateTime(2020);

    // Se há uma inseminação selecionada, a data mínima é a data da inseminação
    if (_inseminacaoSelecionada != null) {
      firstDate = _inseminacaoSelecionada!.dataInseminacao;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada.isBefore(firstDate) ? firstDate : _dataSelecionada,
      firstDate: firstDate,
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecionar data do diagnóstico',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
        _dataDiagnosticoController.text = _dateFormat.format(picked);
      });
    }
  }

  void _cadastrarDiagnostico() {
    if (!_formKey.currentState!.validate()) return;
    if (_inseminacaoSelecionada == null) {
      _mostrarSnackbar('Selecione uma inseminação');
      return;
    }
    if (_resultadoSelecionado == null) {
      _mostrarSnackbar('Selecione o resultado do diagnóstico');
      return;
    }

    // Validar se a data do diagnóstico é posterior à data da inseminação
    if (_dataSelecionada.isBefore(_inseminacaoSelecionada!.dataInseminacao)) {
      _mostrarSnackbar('A data do diagnóstico deve ser posterior à data da inseminação');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final diagnostico = DiagnosticoGestacaoEntity(
      id: '', // Será gerado pelo backend
      inseminacao: _inseminacaoSelecionada!,
      dataDiagnostico: _dataSelecionada,
      resultado: _resultadoSelecionado!,
      metodo: _metodoController.text.trim(),
      observacoes: _observacoesController.text.trim(), // Sempre obrigatório
      dataPartoPrevista: _resultadoSelecionado == ResultadoDiagnostico.positivo ? _calcularDataPartoPrevista() : null,
    );

    context.read<ReproducaoBloc>().add(CreateDiagnosticoGestacaoEvent(diagnostico));
  }

  DateTime? _calcularDataPartoPrevista() {
    if (_inseminacaoSelecionada != null) {
      // Assumindo período de gestação de 280 dias (bovinos)
      // Isso deveria vir da espécie do animal, mas por simplicidade usamos 280 dias
      return _inseminacaoSelecionada!.dataInseminacao.add(const Duration(days: 280));
    }
    return null;
  }

  void _mostrarSnackbar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Novo Diagnóstico',
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is InseminacoesLoaded) {
            setState(() {
              _inseminacoes = state.inseminacoes;
              _isLoading = false;
            });
          } else if (state is DiagnosticosGestacaoLoaded) {
            setState(() {
              _diagnosticos = state.diagnosticos;
            });
          } else if (state is DiagnosticoGestacaoCreated) {
            _mostrarSnackbar('Diagnóstico cadastrado com sucesso!');
            Navigator.of(context).pop(true);
          } else if (state is ReproducaoError) {
            _mostrarSnackbar('Erro: ${state.message}');
            setState(() {
              _isLoading = false;
            });
          } else if (state is InseminacoesLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },
        child: _isLoading && _inseminacoes == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInseminacaoDropdown(),
                      const SizedBox(height: 16),
                      _buildDataDiagnostico(),
                      const SizedBox(height: 16),
                      _buildResultadoDropdown(),
                      if (_resultadoSelecionado == ResultadoDiagnostico.positivo) ...[
                        const SizedBox(height: 16),
                        _buildDataPartoPrevista(),
                      ],
                      const SizedBox(height: 16),
                      _buildMetodo(),
                      const SizedBox(height: 16),
                      _buildObservacoes(),
                      const SizedBox(height: 24),
                      _buildBotaoSalvar(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInseminacaoDropdown() {
    if (widget.inseminacaoSelecionada != null) {
      // Se veio de uma inseminação específica, mostra como readonly
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inseminação Selecionada',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.science, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.inseminacaoSelecionada!.animal.situacao.isNotEmpty ? widget.inseminacaoSelecionada!.animal.situacao : 'Animal ${widget.inseminacaoSelecionada!.animal.idAnimal}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_dateFormat.format(widget.inseminacaoSelecionada!.dataInseminacao)} - ${widget.inseminacaoSelecionada!.tipo.label}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return InseminacaoSearchField(
      inseminacoes: _inseminacoes ?? [],
      diagnosticos: _diagnosticos ?? [],
      inseminacaoSelecionada: _inseminacaoSelecionada,
      labelText: 'Selecionar Inseminação*',
      onChanged: (inseminacao) {
        setState(() {
          _inseminacaoSelecionada = inseminacao;
        });
      },
      validator: (value) {
        if (_inseminacaoSelecionada == null) {
          return 'Selecione uma inseminação';
        }
        return null;
      },
    );
  }

  Widget _buildDataDiagnostico() {
    return TextFormField(
      controller: _dataDiagnosticoController,
      decoration: const InputDecoration(
        labelText: 'Data do Diagnóstico*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.calendar_today),
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

  Widget _buildResultadoDropdown() {
    return DropdownButtonFormField<ResultadoDiagnostico>(
      value: _resultadoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Resultado do Diagnóstico*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.medical_services),
      ),
      items: ResultadoDiagnostico.values.map((resultado) {
        return DropdownMenuItem<ResultadoDiagnostico>(
          value: resultado,
          child: Row(
            children: [
              Icon(
                _getResultadoIcon(resultado),
                color: _getResultadoColor(resultado),
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
    if (dataPartoPrevista == null) return const SizedBox.shrink();

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
                  'Data Prevista do Parto',
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
                Text(
                  'Aproximadamente 280 dias após a inseminação',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoSalvar() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _cadastrarDiagnostico,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Salvar Diagnóstico',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Color _getResultadoColor(ResultadoDiagnostico resultado) {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return Colors.green;
      case ResultadoDiagnostico.negativo:
        return Colors.red;
      case ResultadoDiagnostico.inconclusivo:
        return Colors.orange;
    }
  }

  IconData _getResultadoIcon(ResultadoDiagnostico resultado) {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return Icons.check;
      case ResultadoDiagnostico.negativo:
        return Icons.close;
      case ResultadoDiagnostico.inconclusivo:
        return Icons.help;
    }
  }
}
