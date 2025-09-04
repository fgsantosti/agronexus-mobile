import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/presentation/reproducao/selecionar_lotes_screen.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:intl/intl.dart';

class CadastroEstacaoMontaScreen extends StatefulWidget {
  const CadastroEstacaoMontaScreen({super.key});

  @override
  State<CadastroEstacaoMontaScreen> createState() => _CadastroEstacaoMontaScreenState();
}

class _CadastroEstacaoMontaScreenState extends State<CadastroEstacaoMontaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers
  final _nomeController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _observacoesController = TextEditingController();

  DateTime _dataInicioSelecionada = DateTime.now();
  DateTime _dataFimSelecionada = DateTime.now().add(const Duration(days: 60));
  bool _ativa = true;
  bool _isLoading = false;

  // Propriedades
  PropriedadeEntity? _propriedadeSelecionada;

  @override
  void initState() {
    super.initState();
    _dataInicioController.text = _dateFormat.format(_dataInicioSelecionada);
    _dataFimController.text = _dateFormat.format(_dataFimSelecionada);
    _carregarPropriedades();
  }

  void _carregarPropriedades() {
    context.read<PropriedadeBlocNew>().add(const LoadPropriedadesEvent());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataInicio() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataInicioSelecionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _dataInicioSelecionada) {
      setState(() {
        _dataInicioSelecionada = picked;
        _dataInicioController.text = _dateFormat.format(picked);

        // Ajustar data fim se necessário
        if (_dataFimSelecionada.isBefore(_dataInicioSelecionada)) {
          _dataFimSelecionada = _dataInicioSelecionada.add(const Duration(days: 60));
          _dataFimController.text = _dateFormat.format(_dataFimSelecionada);
        }
      });
    }
  }

  Future<void> _selecionarDataFim() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataFimSelecionada,
      firstDate: _dataInicioSelecionada,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _dataFimSelecionada) {
      setState(() {
        _dataFimSelecionada = picked;
        _dataFimController.text = _dateFormat.format(picked);
      });
    }
  }

  void _cadastrarEstacao() {
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

    final estacao = EstacaoMontaEntity(
      id: '', // Será gerado pelo backend
      nome: _nomeController.text,
      dataInicio: _dataInicioSelecionada,
      dataFim: _dataFimSelecionada,
      observacoes: _observacoesController.text.isNotEmpty ? _observacoesController.text : "",
      ativa: _ativa,
      totalFemeas: 0, // Será calculado pelo backend
      taxaPrenhez: 0.0, // Será calculado pelo backend
      propriedadeId: _propriedadeSelecionada!.id,
    );

    context.read<ReproducaoBloc>().add(CreateEstacaoMontaEvent(estacao));
  }

  void _mostrarSnackbar(String mensagem, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Nova Estação de Monta',
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          setState(() {
            _isLoading = state is ReproducaoLoading;
          });

          if (state is EstacaoMontaCreated) {
            _mostrarSnackbar('Estação de monta cadastrada com sucesso!');

            // Navegar para seleção de lotes
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<ReproducaoBloc>(),
                  child: SelecionarLotesScreen(
                    estacaoMontaId: state.estacao.id,
                    lotesJaAssociados: const [],
                  ),
                ),
              ),
            ).then((_) {
              // Voltar para a tela anterior após selecionar lotes
              Navigator.of(context).pop(true);
            });
          } else if (state is ReproducaoError) {
            _mostrarSnackbar(state.message, isError: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNomeField(),
                        const SizedBox(height: 16),
                        _buildPropriedadeField(),
                        const SizedBox(height: 16),
                        _buildDataFields(),
                        const SizedBox(height: 16),
                        _buildStatusField(),
                        const SizedBox(height: 16),
                        _buildObservacoesField(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBotaoSalvar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNomeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nome da Estação *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nomeController,
          decoration: InputDecoration(
            hintText: 'Ex: Estação 2025',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome é obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPropriedadeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Propriedade *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<PropriedadeBlocNew, PropriedadeState>(
          builder: (context, state) {
            if (state is PropriedadeLoading) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            if (state is PropriedadesLoaded) {
              if (state.propriedades.isEmpty) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orange.shade50,
                  ),
                  child: const Center(
                    child: Text(
                      'Nenhuma propriedade encontrada',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                );
              }

              return DropdownButtonFormField<PropriedadeEntity>(
                value: _propriedadeSelecionada,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.location_city),
                ),
                hint: const Text('Selecione a propriedade'),
                items: state.propriedades.map((propriedade) {
                  return DropdownMenuItem<PropriedadeEntity>(
                    value: propriedade,
                    child: Text(
                      propriedade.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (propriedade) {
                  setState(() {
                    _propriedadeSelecionada = propriedade;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Propriedade é obrigatória';
                  }
                  return null;
                },
              );
            }

            if (state is PropriedadeError) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.shade50,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Erro ao carregar propriedades',
                          style: TextStyle(color: Colors.red.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _carregarPropriedades,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: const Center(
                child: Text('Carregando propriedades...'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Período da Estação *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dataInicioController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data Início',
                  hintText: 'Selecione a data',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onTap: _selecionarDataInicio,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data obrigatória';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _dataFimController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data Fim',
                  hintText: 'Selecione a data',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onTap: _selecionarDataFim,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data obrigatória';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(_ativa ? 'Ativa' : 'Inativa'),
          subtitle: Text(
            _ativa ? 'A estação está ativa e disponível para inseminações' : 'A estação está inativa',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          value: _ativa,
          onChanged: (value) {
            setState(() {
              _ativa = value;
            });
          },
          contentPadding: EdgeInsets.zero,
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
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Informações adicionais sobre a estação de monta...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoSalvar() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _cadastrarEstacao,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
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
                'Cadastrar Estação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
