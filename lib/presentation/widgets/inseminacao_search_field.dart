import 'package:flutter/material.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:intl/intl.dart';

class InseminacaoSearchField extends StatefulWidget {
  final List<InseminacaoEntity> inseminacoes;
  final InseminacaoEntity? inseminacaoSelecionada;
  final Function(InseminacaoEntity?) onChanged;
  final String labelText;
  final String? Function(String?)? validator;
  final bool enabled;

  const InseminacaoSearchField({
    super.key,
    required this.inseminacoes,
    required this.onChanged,
    this.inseminacaoSelecionada,
    this.labelText = 'Inseminação',
    this.validator,
    this.enabled = true,
  });

  @override
  State<InseminacaoSearchField> createState() => _InseminacaoSearchFieldState();
}

class _InseminacaoSearchFieldState extends State<InseminacaoSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  List<InseminacaoEntity> _inseminacoesFiltradas = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _inseminacoesFiltradas = widget.inseminacoes;

    // Se há uma inseminação selecionada, mostra no campo
    if (widget.inseminacaoSelecionada != null) {
      _controller.text = _getInseminacaoDisplayText(widget.inseminacaoSelecionada!);
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _ocultarSugestoes();
      } else {
        // Quando recebe foco, filtra com o texto atual (ou string vazia para mostrar todas)
        _filtrarInseminacoes(_controller.text);
        _mostrarSugestoes();
      }
    });

    _controller.addListener(() {
      if (_focusNode.hasFocus) {
        _filtrarInseminacoes(_controller.text);
        _mostrarSugestoes();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _ocultarSugestoes();
    super.dispose();
  }

  @override
  void didUpdateWidget(InseminacaoSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Atualizar lista de inseminações se mudou
    if (widget.inseminacoes != oldWidget.inseminacoes) {
      _inseminacoesFiltradas = widget.inseminacoes;
    }

    // Atualizar texto se a inseminação selecionada mudou
    if (widget.inseminacaoSelecionada != oldWidget.inseminacaoSelecionada) {
      if (widget.inseminacaoSelecionada != null) {
        _controller.text = _getInseminacaoDisplayText(widget.inseminacaoSelecionada!);
      } else {
        _controller.clear();
      }
    }
  }

  String _getAnimalDisplayText(AnimalEntity animal) {
    String displayText = '';

    // Mostrar identificação
    if (animal.identificacaoUnica.isNotEmpty) {
      displayText = animal.identificacaoUnica;
    } else if (animal.idAnimal.isNotEmpty) {
      displayText = animal.idAnimal;
    }

    // Adicionar nome se disponível
    if (animal.nomeRegistro != null && animal.nomeRegistro!.isNotEmpty) {
      displayText += ' - ${animal.nomeRegistro}';
    } else if (animal.situacao.isNotEmpty && animal.situacao != animal.identificacaoUnica && animal.situacao != animal.idAnimal) {
      displayText += ' - ${animal.situacao}';
    }

    return displayText.isNotEmpty ? displayText : 'Animal ${animal.idAnimal}';
  }

  String _getInseminacaoDisplayText(InseminacaoEntity inseminacao) {
    final animalText = _getAnimalDisplayText(inseminacao.animal);
    final data = _dateFormat.format(inseminacao.dataInseminacao);
    return '$animalText - $data';
  }

  void _filtrarInseminacoes(String query) {
    setState(() {
      if (query.isEmpty) {
        _inseminacoesFiltradas = widget.inseminacoes;
      } else {
        _inseminacoesFiltradas = widget.inseminacoes.where((inseminacao) {
          final textoCompleto = _getInseminacaoDisplayText(inseminacao).toLowerCase();
          final animalDisplay = _getAnimalDisplayText(inseminacao.animal).toLowerCase();
          final identificacao = inseminacao.animal.identificacaoUnica.toLowerCase();
          final idAnimal = inseminacao.animal.idAnimal.toLowerCase();
          final nomeRegistro = (inseminacao.animal.nomeRegistro ?? '').toLowerCase();
          final situacao = inseminacao.animal.situacao.toLowerCase();
          final tipo = inseminacao.tipo.label.toLowerCase();
          final queryLower = query.toLowerCase();

          return textoCompleto.contains(queryLower) ||
              animalDisplay.contains(queryLower) ||
              identificacao.contains(queryLower) ||
              idAnimal.contains(queryLower) ||
              nomeRegistro.contains(queryLower) ||
              situacao.contains(queryLower) ||
              tipo.contains(queryLower);
        }).toList();
      }
    });
  }

  void _mostrarSugestoes() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    if (_inseminacoesFiltradas.isEmpty) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _inseminacoesFiltradas.length,
              itemBuilder: (context, index) {
                final inseminacao = _inseminacoesFiltradas[index];
                return InkWell(
                  onTap: () {
                    _selecionarInseminacao(inseminacao);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: index < _inseminacoesFiltradas.length - 1 ? Border(bottom: BorderSide(color: Colors.grey.shade200)) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.science,
                            color: Colors.pink.shade400,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getAnimalDisplayText(inseminacao.animal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_dateFormat.format(inseminacao.dataInseminacao)} - ${inseminacao.tipo.label}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _ocultarSugestoes() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _selecionarInseminacao(InseminacaoEntity inseminacao) {
    setState(() {
      _controller.text = _getInseminacaoDisplayText(inseminacao);
    });

    widget.onChanged(inseminacao);
    _focusNode.unfocus();
    _ocultarSugestoes();
  }

  void _limparSelecao() {
    setState(() {
      _controller.clear();
    });
    widget.onChanged(null);
    _focusNode.unfocus();
    _ocultarSugestoes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: 'Digite a identificação ou nome da fêmea',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.science),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: widget.enabled ? _limparSelecao : null,
                  )
                : const Icon(Icons.search),
            helperText: 'Digite para buscar por animal ou data',
          ),
          validator: widget.validator,
          onTap: () {
            if (_focusNode.hasFocus) {
              _mostrarSugestoes();
            }
          },
        ),
        if (_inseminacoesFiltradas.isEmpty && _controller.text.isNotEmpty && _focusNode.hasFocus)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Nenhuma inseminação encontrada',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
