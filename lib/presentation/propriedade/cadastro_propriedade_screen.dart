import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';
import 'package:agronexus/presentation/widgets/form_submit_protection_mixin.dart';

class CadastroPropriedadeScreen extends StatefulWidget {
  const CadastroPropriedadeScreen({super.key});

  @override
  State<CadastroPropriedadeScreen> createState() => _CadastroPropriedadeScreenState();
}

class _CadastroPropriedadeScreenState extends State<CadastroPropriedadeScreen> with FormSubmitProtectionMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers para campos de texto
  final _nomeController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _areaTotalController = TextEditingController();
  final _inscricaoEstadualController = TextEditingController();
  final _cnpjCpfController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _ativa = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _localizacaoController.dispose();
    _areaTotalController.dispose();
    _inscricaoEstadualController.dispose();
    _cnpjCpfController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(
        title: 'Nova Propriedade',
        showSaveButton: false,
      ),
      body: BlocListener<PropriedadeBlocNew, PropriedadeState>(
        listener: (context, state) {
          if (state is PropriedadeCreated) {
            FormSnackBar.showSuccess(context, 'Propriedade cadastrada com sucesso!');
            safeNavigateBack();
          }

          if (state is PropriedadeError) {
            FormSnackBar.showError(context, state.message);
            resetProtection();
          }

          if (state is PropriedadeLoading) {
            // Não precisa setar loading, o mixin já controla
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações básicas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações Básicas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome da Propriedade *',
                            hintText: 'Ex: Fazenda São João',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _localizacaoController,
                          decoration: const InputDecoration(
                            labelText: 'Localização *',
                            hintText: 'Endereço completo da propriedade',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Localização é obrigatória';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _areaTotalController,
                          decoration: const InputDecoration(
                            labelText: 'Área Total (hectares) *',
                            hintText: 'Ex: 500.50',
                            border: OutlineInputBorder(),
                            suffixText: 'ha',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Área total é obrigatória';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Digite um valor válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Propriedade Ativa'),
                          subtitle: const Text('Define se a propriedade está em uso'),
                          value: _ativa,
                          onChanged: (value) {
                            setState(() {
                              _ativa = value;
                            });
                          },
                          activeColor: Colors.green.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Documentação
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Documentação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _inscricaoEstadualController,
                          decoration: const InputDecoration(
                            labelText: 'Inscrição Estadual',
                            hintText: 'Número da inscrição estadual',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cnpjCpfController,
                          decoration: const InputDecoration(
                            labelText: 'CNPJ/CPF',
                            hintText: 'Documento do proprietário',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Coordenadas GPS
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coordenadas GPS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                  hintText: 'Ex: -15.7939',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _longitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                  hintText: 'Ex: -47.8828',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                FormPrimaryButton(
                  text: 'Cadastrar Propriedade',
                  onPressed: _cadastrarPropriedade,
                  isLoading: isSaving,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _cadastrarPropriedade() {
    if (!canSubmit()) return;

    if (!_formKey.currentState!.validate()) {
      resetProtection();
      return;
    }

    markAsSubmitting();

    // Criar coordenadas GPS se fornecidas
    PropriedadeCoordenadas? coordenadas;
    if (_latitudeController.text.isNotEmpty && _longitudeController.text.isNotEmpty) {
      final latitude = double.tryParse(_latitudeController.text);
      final longitude = double.tryParse(_longitudeController.text);
      if (latitude != null && longitude != null) {
        coordenadas = PropriedadeCoordenadas(
          latitude: latitude,
          longitude: longitude,
        );
      }
    }

    final propriedade = PropriedadeEntity(
      nome: _nomeController.text.trim(),
      localizacao: _localizacaoController.text.trim(),
      areaTotalHa: _areaTotalController.text.trim(),
      ativa: _ativa,
      coordenadasGps: coordenadas,
      inscricaoEstadual: _inscricaoEstadualController.text.trim().isNotEmpty ? _inscricaoEstadualController.text.trim() : null,
      cnpjCpf: _cnpjCpfController.text.trim().isNotEmpty ? _cnpjCpfController.text.trim() : null,
    );

    context.read<PropriedadeBlocNew>().add(CreatePropriedadeEvent(propriedade));
  }
}
