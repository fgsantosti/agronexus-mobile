import 'package:flutter/material.dart';
import 'package:agronexus/presentation/widgets/internal_scaffold.dart';
import 'package:agronexus/domain/entities/reproducao.dart';

class NovaInseminacaoScreen extends StatefulWidget {
  final String? propriedadeId;

  const NovaInseminacaoScreen({
    super.key,
    this.propriedadeId,
  });

  @override
  State<NovaInseminacaoScreen> createState() => _NovaInseminacaoScreenState();
}

class _NovaInseminacaoScreenState extends State<NovaInseminacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _semenController = TextEditingController();
  final _observacoesController = TextEditingController();

  TipoInseminacao? _tipoSelecionado;
  String? _animalSelecionado;
  String? _reprodutorSelecionado;
  String? _protocoloSelecionado;
  String? _estacaoSelecionado;

  // Dados mockados para demonstração
  final List<Map<String, String>> _animaisDisponiveis = [
    {'id': '1', 'nome': 'Vaca 001 - Mimosa'},
    {'id': '2', 'nome': 'Vaca 002 - Estrela'},
    {'id': '3', 'nome': 'Vaca 003 - Bonita'},
    {'id': '4', 'nome': 'Novilha 001 - Princesa'},
  ];

  final List<Map<String, String>> _reprodutoresDisponiveis = [
    {'id': '1', 'nome': 'Touro 001 - Campeão'},
    {'id': '2', 'nome': 'Touro 002 - Força'},
  ];

  final List<Map<String, String>> _protocolosDisponiveis = [
    {'id': '1', 'nome': 'Protocolo IATF Padrão (9 dias)'},
    {'id': '2', 'nome': 'Protocolo IATF Curto (7 dias)'},
    {'id': '3', 'nome': 'Protocolo P4 + eCG'},
  ];

  final List<Map<String, String>> _estacoesDisponiveis = [
    {'id': '1', 'nome': 'Estação 2025'},
    {'id': '2', 'nome': 'Estação Especial'},
  ];

  @override
  void initState() {
    super.initState();
    _dataController.text = _formatarData(DateTime.now());
  }

  @override
  void dispose() {
    _dataController.dispose();
    _semenController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InternalScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nova Inseminação'),
          actions: [
            TextButton(
              onPressed: _salvarInseminacao,
              child: Text(
                'SALVAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Tipo de Inseminação
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de Inseminação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...TipoInseminacao.values.map((tipo) {
                        return RadioListTile<TipoInseminacao>(
                          title: Text(_getTipoDisplay(tipo)),
                          value: tipo,
                          groupValue: _tipoSelecionado,
                          onChanged: (value) {
                            setState(() {
                              _tipoSelecionado = value;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Dados da Inseminação
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados da Inseminação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Animal
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Animal',
                          border: OutlineInputBorder(),
                        ),
                        value: _animalSelecionado,
                        items: _animaisDisponiveis
                            .map((animal) => DropdownMenuItem<String>(
                                  value: animal['id'],
                                  child: Text(animal['nome']!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _animalSelecionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione um animal';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Data da Inseminação
                      TextFormField(
                        controller: _dataController,
                        decoration: InputDecoration(
                          labelText: 'Data da Inseminação',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: _selecionarData,
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione a data';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Reprodutor (apenas para monta natural)
                      if (_tipoSelecionado == TipoInseminacao.natural) ...[
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Reprodutor',
                            border: OutlineInputBorder(),
                          ),
                          value: _reprodutorSelecionado,
                          items: _reprodutoresDisponiveis
                              .map((reprodutor) => DropdownMenuItem<String>(
                                    value: reprodutor['id'],
                                    child: Text(reprodutor['nome']!),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _reprodutorSelecionado = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                      ],

                      // Sêmen (para IA e IATF)
                      if (_tipoSelecionado == TipoInseminacao.ia || _tipoSelecionado == TipoInseminacao.iatf) ...[
                        TextFormField(
                          controller: _semenController,
                          decoration: InputDecoration(
                            labelText: 'Identificação do Sêmen',
                            border: OutlineInputBorder(),
                            hintText: 'Ex: Sêmen Premium XYZ-123',
                          ),
                          validator: (value) {
                            if (_tipoSelecionado != TipoInseminacao.natural && (value == null || value.isEmpty)) {
                              return 'Informe a identificação do sêmen';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                      ],

                      // Protocolo IATF (apenas para IATF)
                      if (_tipoSelecionado == TipoInseminacao.iatf) ...[
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Protocolo IATF',
                            border: OutlineInputBorder(),
                          ),
                          value: _protocoloSelecionado,
                          items: _protocolosDisponiveis
                              .map((protocolo) => DropdownMenuItem<String>(
                                    value: protocolo['id'],
                                    child: Text(protocolo['nome']!),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _protocoloSelecionado = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                      ],

                      // Estação de Monta
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Estação de Monta (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        value: _estacaoSelecionado,
                        items: _estacoesDisponiveis
                            .map((estacao) => DropdownMenuItem<String>(
                                  value: estacao['id'],
                                  child: Text(estacao['nome']!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _estacaoSelecionado = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Observações
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _observacoesController,
                        decoration: InputDecoration(
                          labelText: 'Observações (Opcional)',
                          border: OutlineInputBorder(),
                          hintText: 'Informações adicionais sobre a inseminação...',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Informações importantes
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Informações Importantes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• O diagnóstico de gestação deve ser realizado entre 30-45 dias após a inseminação\n'
                      '• Mantenha registro detalhado para melhor controle reprodutivo\n'
                      '• Em caso de IATF, siga rigorosamente o protocolo selecionado',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getTipoDisplay(TipoInseminacao tipo) {
    switch (tipo) {
      case TipoInseminacao.natural:
        return 'Monta Natural';
      case TipoInseminacao.ia:
        return 'Inseminação Artificial (IA)';
      case TipoInseminacao.iatf:
        return 'Inseminação Artificial em Tempo Fixo (IATF)';
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _dataController.text = _formatarData(picked);
      });
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  void _salvarInseminacao() {
    if (_formKey.currentState!.validate()) {
      if (_tipoSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selecione o tipo de inseminação'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Simular salvamento
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sucesso'),
          content: Text('Inseminação registrada com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
                Navigator.of(context).pop(); // Volta para a tela anterior
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
