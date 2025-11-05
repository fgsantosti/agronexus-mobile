import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';
import 'package:agronexus/presentation/widgets/form_submit_protection_mixin.dart';
import 'package:intl/intl.dart';

class EditarEstacaoMontaScreen extends StatefulWidget {
  final EstacaoMontaEntity estacao;

  const EditarEstacaoMontaScreen({
    super.key,
    required this.estacao,
  });

  @override
  State<EditarEstacaoMontaScreen> createState() => _EditarEstacaoMontaScreenState();
}

class _EditarEstacaoMontaScreenState extends State<EditarEstacaoMontaScreen> with FormSubmitProtectionMixin {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers
  final _nomeController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _observacoesController = TextEditingController();

  late DateTime _dataInicioSelecionada;
  late DateTime _dataFimSelecionada;
  late bool _ativa;

  @override
  void initState() {
    super.initState();
    _inicializarCampos();
  }

  void _inicializarCampos() {
    _nomeController.text = widget.estacao.nome;
    _dataInicioSelecionada = widget.estacao.dataInicio;
    _dataFimSelecionada = widget.estacao.dataFim;
    _ativa = widget.estacao.ativa;

    _dataInicioController.text = _dateFormat.format(_dataInicioSelecionada);
    _dataFimController.text = _dateFormat.format(_dataFimSelecionada);
    _observacoesController.text = widget.estacao.observacoes ?? '';
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

  void _atualizarEstacao() async {
    if (!canSubmit()) return;

    if (!_formKey.currentState!.validate()) {
      resetProtection();
      return;
    }

    markAsSubmitting();

    final estacaoAtualizada = EstacaoMontaEntity(
      id: widget.estacao.id,
      nome: _nomeController.text,
      dataInicio: _dataInicioSelecionada,
      dataFim: _dataFimSelecionada,
      observacoes: _observacoesController.text.isNotEmpty ? _observacoesController.text : null,
      ativa: _ativa,
      totalFemeas: widget.estacao.totalFemeas,
      taxaPrenhez: widget.estacao.taxaPrenhez,
    );

    context.read<ReproducaoBloc>().add(UpdateEstacaoMontaEvent(widget.estacao.id, estacaoAtualizada));
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta estação de monta? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ReproducaoBloc>().add(DeleteEstacaoMontaEvent(widget.estacao.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(
        title: 'Editar Estação de Monta',
        showSaveButton: false,
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is EstacaoMontaUpdated) {
            showProtectedSnackBar('Estação de monta atualizada com sucesso!');
            safeNavigateBack(result: true);
          } else if (state is EstacaoMontaDeleted) {
            showProtectedSnackBar('Estação de monta excluída com sucesso!');
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          } else if (state is ReproducaoError) {
            showProtectedSnackBar(state.message, isError: true);
            resetProtection();
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
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildNomeField(),
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

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Atuais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Fêmeas', '${widget.estacao.totalFemeas}'),
                ),
                Expanded(
                  child: _buildInfoItem('Taxa Prenhez', '${widget.estacao.taxaPrenhez.toStringAsFixed(1)}%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
    return Column(
      children: [
        FormPrimaryButton(
          onPressed: _atualizarEstacao,
          isLoading: isSaving,
          text: 'Salvar Alterações',
        ),
        const SizedBox(height: 12),
        FormSecondaryButton(
          onPressed: _confirmarExclusao,
          text: 'Excluir Estação',
          icon: Icons.delete,
        ),
      ],
    );
  }
}
