import 'package:flutter/material.dart';
import 'package:agronexus/presentation/widgets/internal_scaffold.dart';
import 'package:agronexus/domain/entities/reproducao.dart';

class NovoDiagnosticoScreen extends StatefulWidget {
  final String? propriedadeId;
  final Inseminacao? inseminacao;

  const NovoDiagnosticoScreen({
    super.key,
    this.propriedadeId,
    this.inseminacao,
  });

  @override
  State<NovoDiagnosticoScreen> createState() => _NovoDiagnosticoScreenState();
}

class _NovoDiagnosticoScreenState extends State<NovoDiagnosticoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _metodoController = TextEditingController();
  final _observacoesController = TextEditingController();

  ResultadoDiagnostico? _resultadoSelecionado;
  String? _inseminacaoSelecionada;

  // Dados mockados para demonstração
  final List<Map<String, String>> _inseminacoesDisponiveis = [
    {'id': '1', 'nome': 'IA - Vaca 001 (15/07/2025)'},
    {'id': '2', 'nome': 'IATF - Vaca 002 (20/07/2025)'},
    {'id': '3', 'nome': 'Monta Natural - Vaca 003 (25/07/2025)'},
  ];

  @override
  void initState() {
    super.initState();
    _dataController.text = _formatarData(DateTime.now());
    if (widget.inseminacao != null) {
      _inseminacaoSelecionada = widget.inseminacao!.id;
    }
  }

  @override
  void dispose() {
    _dataController.dispose();
    _metodoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InternalScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Novo Diagnóstico'),
          actions: [
            TextButton(
              onPressed: _salvarDiagnostico,
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
              // Dados do Diagnóstico
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dados do Diagnóstico',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Inseminação
                      if (widget.inseminacao == null) ...[
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Inseminação',
                            border: OutlineInputBorder(),
                          ),
                          value: _inseminacaoSelecionada,
                          items: _inseminacoesDisponiveis
                              .map((inseminacao) => DropdownMenuItem<String>(
                                    value: inseminacao['id'],
                                    child: Text(inseminacao['nome']!),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _inseminacaoSelecionada = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione uma inseminação';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inseminação Selecionada',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${widget.inseminacao!.tipoDisplay} - Animal ${widget.inseminacao!.animalId}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Data IA: ${_formatarData(widget.inseminacao!.dataInseminacao)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],

                      // Data do Diagnóstico
                      TextFormField(
                        controller: _dataController,
                        decoration: InputDecoration(
                          labelText: 'Data do Diagnóstico',
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

                      // Método
                      TextFormField(
                        controller: _metodoController,
                        decoration: InputDecoration(
                          labelText: 'Método Utilizado',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: Ultrassom, Palpação retal...',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o método utilizado';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Resultado
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultado do Diagnóstico',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...ResultadoDiagnostico.values.map((resultado) {
                        Color cor = _getCorResultado(resultado);
                        IconData icone = _getIconeResultado(resultado);

                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _resultadoSelecionado == resultado ? cor : Colors.grey[300]!,
                              width: 2,
                            ),
                            color: _resultadoSelecionado == resultado ? cor.withOpacity(0.1) : null,
                          ),
                          child: RadioListTile<ResultadoDiagnostico>(
                            title: Row(
                              children: [
                                Icon(icone, color: cor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  _getResultadoDisplay(resultado),
                                  style: TextStyle(
                                    fontWeight: _resultadoSelecionado == resultado ? FontWeight.bold : FontWeight.normal,
                                    color: _resultadoSelecionado == resultado ? cor : null,
                                  ),
                                ),
                              ],
                            ),
                            value: resultado,
                            groupValue: _resultadoSelecionado,
                            activeColor: cor,
                            onChanged: (value) {
                              setState(() {
                                _resultadoSelecionado = value;
                              });
                            },
                          ),
                        );
                      }).toList(),
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
                          hintText: 'Informações adicionais sobre o diagnóstico...',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Informações importantes
              if (_resultadoSelecionado == ResultadoDiagnostico.positivo) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Prenha Confirmada!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Data prevista do parto: ${widget.inseminacao != null ? _formatarData(widget.inseminacao!.dataInseminacao.add(Duration(days: 285))) : "A calcular"}\n'
                        '• Mantenha acompanhamento veterinário regular\n'
                        '• Planeje o manejo nutricional para a gestação\n'
                        '• Agende próximas consultas de pré-natal',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
              ],

              if (_resultadoSelecionado == ResultadoDiagnostico.negativo) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Animal Vazio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Animal pode retornar à estação de monta\n'
                        '• Avaliar possíveis causas da falha reprodutiva\n'
                        '• Considerar exames complementares se necessário',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getResultadoDisplay(ResultadoDiagnostico resultado) {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return 'Prenha (Positivo)';
      case ResultadoDiagnostico.negativo:
        return 'Vazia (Negativo)';
      case ResultadoDiagnostico.inconclusivo:
        return 'Inconclusivo';
    }
  }

  Color _getCorResultado(ResultadoDiagnostico resultado) {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return Colors.green;
      case ResultadoDiagnostico.negativo:
        return Colors.red;
      case ResultadoDiagnostico.inconclusivo:
        return Colors.orange;
    }
  }

  IconData _getIconeResultado(ResultadoDiagnostico resultado) {
    switch (resultado) {
      case ResultadoDiagnostico.positivo:
        return Icons.favorite;
      case ResultadoDiagnostico.negativo:
        return Icons.heart_broken;
      case ResultadoDiagnostico.inconclusivo:
        return Icons.help;
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 30)),
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

  void _salvarDiagnostico() {
    if (_formKey.currentState!.validate()) {
      if (_resultadoSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selecione o resultado do diagnóstico'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Simular salvamento
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                _getIconeResultado(_resultadoSelecionado!),
                color: _getCorResultado(_resultadoSelecionado!),
              ),
              SizedBox(width: 8),
              Text('Diagnóstico Registrado'),
            ],
          ),
          content: Text('Resultado: ${_getResultadoDisplay(_resultadoSelecionado!)}\n\n'
              'O diagnóstico foi registrado com sucesso!'),
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
