import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
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
  final _custoMaterialController = TextEditingController();
  final _custoPessoalController = TextEditingController();

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
    _custoMaterialController.dispose();
    _custoPessoalController.dispose();
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
      custoMaterial: double.tryParse(_custoMaterialController.text),
      custoPessoal: double.tryParse(_custoPessoalController.text),
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
          print('Estado atual do BLoC: ${state.runtimeType}');
          if (state is OpcoesCadastroInseminacaoLoaded) {
            print('Opções carregadas: ${state.opcoes}');
            setState(() {
              _opcoes = state.opcoes;
              _isLoading = false;
            });
          } else if (state is InseminacaoCreated) {
            _mostrarSnackbar('Inseminação cadastrada com sucesso!');
            Navigator.of(context).pop(true); // Retorna true para indicar sucesso
          } else if (state is ReproducaoError) {
            print('Erro no BLoC: ${state.message}');
            _mostrarSnackbar('Erro: ${state.message}');
            setState(() {
              _isLoading = false;
            });
          } else if (state is ReproducaoLoading) {
            print('Estado de loading...');
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
                          _buildCustosSection(),
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
    return DropdownButtonFormField<AnimalEntity>(
      decoration: const InputDecoration(
        labelText: 'Animal (Fêmea)*',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pets),
      ),
      value: _animalSelecionado,
      items: _opcoes!.femeas.map((animal) {
        return DropdownMenuItem(
          value: animal,
          child: Text('${animal.idAnimal} - ${animal.fazendaNome}'),
        );
      }).toList(),
      onChanged: (animal) {
        setState(() {
          _animalSelecionado = animal;
        });
      },
      validator: (value) {
        if (value == null) return 'Selecione um animal';
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
    return DropdownButtonFormField<AnimalEntity>(
      decoration: const InputDecoration(
        labelText: 'Reprodutor (Macho)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.male),
      ),
      value: _reprodutorSelecionado,
      items: [
        const DropdownMenuItem<AnimalEntity>(
          value: null,
          child: Text('Nenhum selecionado'),
        ),
        ..._opcoes!.reprodutores.map((reprodutor) {
          return DropdownMenuItem(
            value: reprodutor,
            child: Text('${reprodutor.idAnimal} - ${reprodutor.fazendaNome}'),
          );
        }),
      ],
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

  Widget _buildCustosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _custoMaterialController,
                decoration: const InputDecoration(
                  labelText: 'Custo Material (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _custoPessoalController,
                decoration: const InputDecoration(
                  labelText: 'Custo Pessoal (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ),
          ],
        ),
      ],
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
