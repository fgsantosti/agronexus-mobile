import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/presentation/widgets/animal_search_field.dart';
import 'package:intl/intl.dart';

class CadastroInseminacaoScreen extends StatefulWidget {
  const CadastroInseminacaoScreen({super.key});

  @override
  State<CadastroInseminacaoScreen> createState() => _CadastroInseminacaoScreenState();
}

class _CadastroInseminacaoScreenState extends State<CadastroInseminacaoScreen> {
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
    _dataInseminacaoController.text = _dateFormat.format(_dataSelecionada);
    _carregarOpcoes();
  }

  @override
  void dispose() {
    _dataInseminacaoController.dispose();
    _semenUtilizadoController.dispose();
    _observacoesController.dispose();
    super.dispose();
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

  void _cadastrarInseminacao() {
    if (!_formKey.currentState!.validate()) return;
    if (_animalSelecionado == null) {
      _mostrarSnackbar('Selecione um animal');
      return;
    }
    if (_tipoSelecionado == null) {
      _mostrarSnackbar('Selecione o tipo de inseminação');
      return;
    }

    final inseminacao = InseminacaoEntity(
      id: '', // Será gerado pelo backend
      animal: _animalSelecionado!,
      dataInseminacao: _dataSelecionada,
      tipo: _tipoSelecionado!,
      reprodutor: _reprodutorSelecionado,
      semenUtilizado: _semenUtilizadoController.text.isNotEmpty ? _semenUtilizadoController.text : null,
      protocoloIatf: _protocoloSelecionado,
      estacaoMonta: _estacaoSelecionada,
      observacoes: _observacoesController.text.isNotEmpty ? _observacoesController.text : null,
    );

    context.read<ReproducaoBloc>().add(CreateInseminacaoEvent(inseminacao));
  }

  void _mostrarSnackbar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Inseminação'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is OpcoesCadastroInseminacaoLoaded) {
            setState(() {
              _opcoes = state.opcoes;
              _isLoading = false;
            });

            // Debug: verificar quantos reprodutores foram carregados
            print('DEBUG CADASTRO - Reprodutores carregados: ${state.opcoes.reprodutores.length}');
            for (var reprodutor in state.opcoes.reprodutores) {
              print('DEBUG CADASTRO - Reprodutor: ${reprodutor.idAnimal} - ${reprodutor.fazendaNome} - Sexo: ${reprodutor.sexo}');
            }
          } else if (state is InseminacaoCreated) {
            print('DEBUG CADASTRO - Estado InseminacaoCreated recebido!');
            _mostrarSnackbar('Inseminação cadastrada com sucesso!');
            print('DEBUG CADASTRO - Chamando Navigator.pop(true)');
            Navigator.of(context).pop(true); // Retorna true para indicar sucesso
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
                          _buildEstacaoDropdown(),
                          const SizedBox(height: 16),
                          _buildSemenUtilizado(),
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

  Widget _buildAnimalDropdown() {
    return AnimalSearchField(
      animais: _opcoes!.femeas,
      animalSelecionado: _animalSelecionado,
      labelText: 'Animal (Fêmea)*',
      apenasFemeas: true,
      onChanged: (animal) {
        setState(() {
          _animalSelecionado = animal;
        });
      },
      validator: (value) {
        if (_animalSelecionado == null) return 'Selecione um animal';
        return null;
      },
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
    return AnimalSearchField(
      animais: _opcoes!.reprodutores,
      animalSelecionado: _reprodutorSelecionado,
      labelText: 'Reprodutor (Macho)',
      apenasManhos: true,
      onChanged: (reprodutor) {
        setState(() {
          _reprodutorSelecionado = reprodutor;
        });
      },
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

  Widget _buildEstacaoDropdown() {
    return DropdownButtonFormField<EstacaoMontaEntity>(
      decoration: const InputDecoration(
        labelText: 'Estação de Monta',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.event),
      ),
      value: _estacaoSelecionada,
      items: [
        const DropdownMenuItem<EstacaoMontaEntity>(
          value: null,
          child: Text('Nenhuma estação'),
        ),
        ..._opcoes!.estacoesMonta.map((estacao) {
          return DropdownMenuItem(
            value: estacao,
            child: Text(estacao.nome),
          );
        }),
      ],
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

  Widget _buildBotaoSalvar() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _cadastrarInseminacao,
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
                Text('Salvando...'),
              ],
            )
          : const Text(
              'Cadastrar Inseminação',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
