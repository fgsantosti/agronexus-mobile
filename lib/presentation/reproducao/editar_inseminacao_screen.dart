import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/presentation/widgets/estacao_monta_search_field.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';
import 'package:agronexus/presentation/widgets/form_submit_protection_mixin.dart';
import 'package:intl/intl.dart';

class EditarInseminacaoScreen extends StatefulWidget {
  final InseminacaoEntity inseminacao;

  const EditarInseminacaoScreen({
    super.key,
    required this.inseminacao,
  });

  @override
  State<EditarInseminacaoScreen> createState() => _EditarInseminacaoScreenState();
}

class _EditarInseminacaoScreenState extends State<EditarInseminacaoScreen> with FormSubmitProtectionMixin {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers
  final _dataInseminacaoController = TextEditingController();
  final _semenUtilizadoController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Campos selecionados
  AnimalEntity? _animalSelecionado;
  AnimalEntity? _reprodutorSelecionado;
  TipoInseminacao? _tipoSelecionado;
  ProtocoloIATFEntity? _protocoloSelecionado;
  EstacaoMontaEntity? _estacaoSelecionada;

  // Opções disponíveis
  OpcoesCadastroInseminacao? _opcoes;

  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preencherCamposComDadosExistentes();
    _carregarOpcoes();
  }

  @override
  void dispose() {
    _dataInseminacaoController.dispose();
    _semenUtilizadoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _preencherCamposComDadosExistentes() {
    final inseminacao = widget.inseminacao;

    // Preencher campos básicos
    _animalSelecionado = inseminacao.animal;
    _dataSelecionada = inseminacao.dataInseminacao;
    _dataInseminacaoController.text = _dateFormat.format(_dataSelecionada);
    _tipoSelecionado = inseminacao.tipo;

    // Preencher campos opcionais
    _reprodutorSelecionado = inseminacao.reprodutor;
    _semenUtilizadoController.text = inseminacao.semenUtilizado ?? '';
    _protocoloSelecionado = inseminacao.protocoloIatf;
    _estacaoSelecionada = inseminacao.estacaoMonta;
    _observacoesController.text = inseminacao.observacoes ?? '';
  }

  void _carregarOpcoes() {
    context.read<ReproducaoBloc>().add(LoadOpcoesCadastroInseminacaoEvent());
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
        _dataInseminacaoController.text = _dateFormat.format(picked);
      });
    }
  }

  void _atualizarInseminacao() async {
    if (!canSubmit()) return;

    if (!_formKey.currentState!.validate()) {
      resetProtection();
      return;
    }

    if (_animalSelecionado == null) {
      showProtectedSnackBar('Selecione um animal', isError: true);
      resetProtection();
      return;
    }

    if (_tipoSelecionado == null) {
      showProtectedSnackBar('Selecione o tipo de inseminação', isError: true);
      resetProtection();
      return;
    }

    markAsSubmitting();

    final inseminacaoAtualizada = InseminacaoEntity(
      id: widget.inseminacao.id, // Manter o ID existente
      animal: _animalSelecionado!,
      dataInseminacao: _dataSelecionada,
      tipo: _tipoSelecionado!,
      reprodutor: _reprodutorSelecionado,
      semenUtilizado: _semenUtilizadoController.text.isNotEmpty ? _semenUtilizadoController.text : null,
      protocoloIatf: _protocoloSelecionado,
      estacaoMonta: _estacaoSelecionada,
      observacoes: _observacoesController.text.isNotEmpty ? _observacoesController.text : null,
      dataDiagnosticoPrevista: widget.inseminacao.dataDiagnosticoPrevista, // Manter data prevista
    );

    context.read<ReproducaoBloc>().add(UpdateInseminacaoEvent(widget.inseminacao.id, inseminacaoAtualizada));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Permite voltar normalmente
      onPopInvokedWithResult: (didPop, result) {
        print('DEBUG NAVEGAÇÃO - PopScope na EditarInseminacaoScreen invocado: didPop=$didPop');
        if (didPop) {
          print('DEBUG NAVEGAÇÃO - Voltando da tela de edição');
        }
      },
      child: Scaffold(
        appBar: FormAppBar(
          title: 'Editar Inseminação',
          showSaveButton: false,
        ),
        body: BlocListener<ReproducaoBloc, ReproducaoState>(
          listener: (context, state) {
            if (state is OpcoesCadastroInseminacaoLoaded) {
              setState(() {
                _opcoes = state.opcoes;
                _isLoading = false;
              });
            } else if (state is InseminacaoUpdated) {
              showProtectedSnackBar('Inseminação atualizada com sucesso!');
              safeNavigateBack(result: true);
            } else if (state is ReproducaoError) {
              showProtectedSnackBar('Erro: ${state.message}', isError: true);
              resetProtection();
              setState(() {
                _isLoading = false;
              });
            } else if (state is OpcoesCadastroInseminacaoLoading) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _opcoes == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAnimalDropdown(),
                            const SizedBox(height: 16),
                            _buildDataInseminacao(),
                            const SizedBox(height: 16),
                            _buildTipoInseminacaoDropdown(),
                            const SizedBox(height: 16),
                            _buildReprodutorDropdown(),
                            const SizedBox(height: 16),
                            _buildProtocoloDropdown(),
                            const SizedBox(height: 16),
                            _buildEstacaoSearchField(),
                            const SizedBox(height: 16),
                            _buildSemenUtilizado(),
                            const SizedBox(height: 16),
                            _buildObservacoes(),
                            const SizedBox(height: 24),
                            _buildBotaoAtualizar(),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return TextFormField(
      initialValue: _animalSelecionado?.idAnimal ?? 'Animal não informado',
      decoration: const InputDecoration(
        labelText: 'Animal (Fêmea)*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pets),
        suffixIcon: Icon(Icons.lock, color: Colors.grey),
      ),
      enabled: false,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildDataInseminacao() {
    return TextFormField(
      controller: _dataInseminacaoController,
      decoration: const InputDecoration(
        labelText: 'Data da Inseminação*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      onTap: _selecionarData,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe a data';
        return null;
      },
    );
  }

  Widget _buildTipoInseminacaoDropdown() {
    return DropdownButtonFormField<TipoInseminacao>(
      decoration: const InputDecoration(
        labelText: 'Tipo de Inseminação*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.science),
      ),
      value: _tipoSelecionado,
      items: _opcoes!.tiposInseminacao.map((tipo) {
        return DropdownMenuItem(
          value: tipo,
          child: Text(tipo.label),
        );
      }).toList(),
      onChanged: (tipo) {
        setState(() {
          _tipoSelecionado = tipo;
        });
      },
      validator: (value) {
        if (value == null) return 'Selecione o tipo';
        return null;
      },
    );
  }

  Widget _buildReprodutorDropdown() {
    return TextFormField(
      initialValue: _reprodutorSelecionado?.idAnimal ?? 'Nenhum reprodutor selecionado',
      decoration: const InputDecoration(
        labelText: 'Reprodutor (Macho)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.male),
        suffixIcon: Icon(Icons.lock, color: Colors.grey),
      ),
      enabled: false,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildProtocoloDropdown() {
    return DropdownButtonFormField<ProtocoloIATFEntity>(
      decoration: const InputDecoration(
        labelText: 'Protocolo IATF',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment),
      ),
      value: _protocoloSelecionado,
      items: [
        const DropdownMenuItem<ProtocoloIATFEntity>(
          value: null,
          child: Text('Nenhum protocolo'),
        ),
        ..._opcoes!.protocolosIatf.map((protocolo) {
          return DropdownMenuItem(
            value: protocolo,
            child: Text(protocolo.nome),
          );
        }),
      ],
      onChanged: (protocolo) {
        setState(() {
          _protocoloSelecionado = protocolo;
        });
      },
    );
  }

  Widget _buildEstacaoSearchField() {
    return EstacaoMontaSearchField(
      estacoes: _opcoes?.estacoesMonta ?? [],
      estacaoSelecionada: _estacaoSelecionada,
      labelText: 'Estação de Monta',
      apenasAtivas: true,
      onChanged: (estacao) {
        setState(() {
          _estacaoSelecionada = estacao;
        });
      },
    );
  }

  Widget _buildSemenUtilizado() {
    return TextFormField(
      controller: _semenUtilizadoController,
      decoration: const InputDecoration(
        labelText: 'Sêmen Utilizado',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.science_outlined),
        hintText: 'Ex: Sêmen de Touro Nelore - Lote XYZ123',
      ),
      maxLines: 2,
    );
  }

  Widget _buildObservacoes() {
    return TextFormField(
      controller: _observacoesController,
      decoration: const InputDecoration(
        labelText: 'Observações',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.notes),
        hintText: 'Insira observações sobre a inseminação...',
      ),
      maxLines: 3,
    );
  }

  Widget _buildBotaoAtualizar() {
    return FormPrimaryButton(
      onPressed: _atualizarInseminacao,
      isLoading: isSaving,
      text: 'Atualizar Inseminação',
    );
  }
}
