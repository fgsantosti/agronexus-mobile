import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';

class EditarPropriedadeScreen extends StatefulWidget {
  final PropriedadeEntity propriedade;

  const EditarPropriedadeScreen({
    super.key,
    required this.propriedade,
  });

  @override
  State<EditarPropriedadeScreen> createState() => _EditarPropriedadeScreenState();
}

class _EditarPropriedadeScreenState extends State<EditarPropriedadeScreen> {
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preencherCamposComDadosExistentes();
  }

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

  void _preencherCamposComDadosExistentes() {
    final propriedade = widget.propriedade;

    // Preencher campos básicos
    _nomeController.text = propriedade.nome;
    _localizacaoController.text = propriedade.localizacao;
    _areaTotalController.text = propriedade.areaTotalHa;
    _ativa = propriedade.ativa;

    // Preencher campos opcionais
    _inscricaoEstadualController.text = propriedade.inscricaoEstadual ?? '';
    _cnpjCpfController.text = propriedade.cnpjCpf ?? '';

    // Preencher coordenadas GPS
    if (propriedade.coordenadasGps != null) {
      _latitudeController.text = propriedade.coordenadasGps!.latitude.toString();
      _longitudeController.text = propriedade.coordenadasGps!.longitude.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Propriedade'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _atualizarPropriedade,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: BlocListener<PropriedadeBlocNew, PropriedadeState>(
        listener: (context, state) {
          if (state is PropriedadeUpdated) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Propriedade atualizada com sucesso!')),
            );
          }

          if (state is PropriedadeError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is PropriedadeLoading) {
            setState(() => _isLoading = true);
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _atualizarPropriedade() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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

    final propriedadeAtualizada = widget.propriedade.copyWith(
      nome: () => _nomeController.text.trim(),
      localizacao: () => _localizacaoController.text.trim(),
      areaTotalHa: () => _areaTotalController.text.trim(),
      ativa: () => _ativa,
      coordenadasGps: () => coordenadas,
      inscricaoEstadual: () => _inscricaoEstadualController.text.trim().isNotEmpty ? _inscricaoEstadualController.text.trim() : null,
      cnpjCpf: () => _cnpjCpfController.text.trim().isNotEmpty ? _cnpjCpfController.text.trim() : null,
    );

    context.read<PropriedadeBlocNew>().add(UpdatePropriedadeEvent(widget.propriedade.id!, propriedadeAtualizada));
  }
}
