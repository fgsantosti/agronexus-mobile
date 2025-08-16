import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/presentation/widgets/animal_search_field.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';

class ConfigurarPadroesEstacaoScreen extends StatefulWidget {
  final EstacaoMontaEntity estacao;
  final TipoInseminacao? tipoInseminacaoPadrao;
  final ProtocoloIATFEntity? protocoloPadrao;
  final AnimalEntity? reprodutorPadrao;
  final String? semenUtilizadoPadrao;

  const ConfigurarPadroesEstacaoScreen({
    super.key,
    required this.estacao,
    this.tipoInseminacaoPadrao,
    this.protocoloPadrao,
    this.reprodutorPadrao,
    this.semenUtilizadoPadrao,
  });

  @override
  State<ConfigurarPadroesEstacaoScreen> createState() => _ConfigurarPadroesEstacaoScreenState();
}

class _ConfigurarPadroesEstacaoScreenState extends State<ConfigurarPadroesEstacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _semenUtilizadoController = TextEditingController();

  // Campos selecionados
  TipoInseminacao? _tipoSelecionado;
  ProtocoloIATFEntity? _protocoloSelecionado;
  AnimalEntity? _reprodutorSelecionado;

  // Opções disponíveis
  OpcoesCadastroInseminacao? _opcoes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarCampos();
    _carregarOpcoes();
  }

  @override
  void dispose() {
    _semenUtilizadoController.dispose();
    super.dispose();
  }

  void _inicializarCampos() {
    _tipoSelecionado = widget.tipoInseminacaoPadrao;
    _protocoloSelecionado = widget.protocoloPadrao;
    _reprodutorSelecionado = widget.reprodutorPadrao;
    _semenUtilizadoController.text = widget.semenUtilizadoPadrao ?? '';
  }

  void _carregarOpcoes() {
    context.read<ReproducaoBloc>().add(LoadOpcoesCadastroInseminacaoEvent());
  }

  void _salvarConfiguracoes() {
    if (!_formKey.currentState!.validate()) return;

    // Criar objeto com as configurações completas
    final configuracoes = {
      'tipo_inseminacao': _tipoSelecionado?.value,
      'tipo_inseminacao_obj': _tipoSelecionado,
      'protocolo_iatf_id': _protocoloSelecionado?.id,
      'protocolo_iatf_obj': _protocoloSelecionado,
      'reprodutor_id': _reprodutorSelecionado?.id,
      'reprodutor_obj': _reprodutorSelecionado,
      'semen_utilizado': _semenUtilizadoController.text.isNotEmpty ? _semenUtilizadoController.text : null,
    };

    // Retornar as configurações para a tela anterior
    Navigator.pop(context, configuracoes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações padrão salvas com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Configurar Padrões',
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is OpcoesCadastroInseminacaoLoaded) {
            setState(() {
              _opcoes = state.opcoes;
              _isLoading = false;
            });
          } else if (state is OpcoesCadastroInseminacaoLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ReproducaoError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _isLoading || _opcoes == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.settings, color: Colors.green.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Estação: ${widget.estacao.nome}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Configure os valores padrão que serão aplicados automaticamente ao cadastrar novas inseminações nesta estação de monta.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tipo de Inseminação
                      _buildTipoInseminacaoDropdown(),
                      const SizedBox(height: 16),

                      // Protocolo IATF
                      _buildProtocoloDropdown(),
                      const SizedBox(height: 16),

                      // Reprodutor
                      _buildReprodutorDropdown(),
                      const SizedBox(height: 16),

                      // Sêmen Utilizado
                      _buildSemenUtilizado(),
                      const SizedBox(height: 24),

                      // Botão de salvar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _salvarConfiguracoes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Salvar Configurações Padrão',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTipoInseminacaoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Inseminação Padrão',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TipoInseminacao>(
          decoration: const InputDecoration(
            labelText: 'Selecione o tipo padrão',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.science),
            hintText: 'Nenhum tipo selecionado',
          ),
          value: _tipoSelecionado,
          items: [
            const DropdownMenuItem<TipoInseminacao>(
              value: null,
              child: Text('Nenhum padrão'),
            ),
            ..._opcoes!.tiposInseminacao.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(tipo.label),
              );
            }),
          ],
          onChanged: (tipo) {
            setState(() {
              _tipoSelecionado = tipo;
              // Se mudou para não-IATF, limpar protocolo
              if (tipo != TipoInseminacao.iatf) {
                _protocoloSelecionado = null;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildProtocoloDropdown() {
    final protocolosDisponiveis = _tipoSelecionado == TipoInseminacao.iatf;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Protocolo IATF Padrão',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ProtocoloIATFEntity>(
          decoration: InputDecoration(
            labelText: protocolosDisponiveis ? 'Selecione o protocolo padrão' : 'Disponível apenas para IATF',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.assignment),
            hintText: 'Nenhum protocolo selecionado',
          ),
          value: _protocoloSelecionado,
          items: [
            const DropdownMenuItem<ProtocoloIATFEntity>(
              value: null,
              child: Text('Nenhum padrão'),
            ),
            if (protocolosDisponiveis)
              ..._opcoes!.protocolosIatf.map((protocolo) {
                return DropdownMenuItem(
                  value: protocolo,
                  child: Text(protocolo.nome),
                );
              }),
          ],
          onChanged: protocolosDisponiveis
              ? (protocolo) {
                  setState(() {
                    _protocoloSelecionado = protocolo;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildReprodutorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reprodutor Padrão',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        AnimalSearchField(
          animais: _opcoes!.reprodutores,
          animalSelecionado: _reprodutorSelecionado,
          labelText: 'Selecione o reprodutor padrão',
          apenasManhos: true,
          onChanged: (reprodutor) {
            setState(() {
              _reprodutorSelecionado = reprodutor;
              print('DEBUG CONFIG: Reprodutor selecionado: ${reprodutor?.identificacaoUnica ?? "Nenhum"}');
              print('DEBUG CONFIG: Reprodutor ID: ${reprodutor?.id ?? "Nenhum"}');
            });
          },
        ),
        if (_reprodutorSelecionado != null) ...[
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildSemenUtilizado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sêmen Utilizado Padrão',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _semenUtilizadoController,
          decoration: const InputDecoration(
            labelText: 'Identificação do sêmen padrão',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.science_outlined),
            hintText: 'Ex: Sêmen Premium IATF - Nelore',
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
