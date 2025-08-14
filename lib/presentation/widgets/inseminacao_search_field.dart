import 'package:flutter/material.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:intl/intl.dart';

class InseminacaoSearchField extends StatefulWidget {
  final List<InseminacaoEntity> inseminacoes;
  final List<DiagnosticoGestacaoEntity> diagnosticos;
  final InseminacaoEntity? inseminacaoSelecionada;
  final Function(InseminacaoEntity?) onChanged;
  final String labelText;
  final String? Function(String?)? validator;
  final bool enabled;

  const InseminacaoSearchField({
    super.key,
    required this.inseminacoes,
    this.diagnosticos = const [],
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
    _inseminacoesFiltradas = _getInseminacoesSemDiagnostico();

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

  // Método para filtrar inseminações que não possuem diagnóstico
  List<InseminacaoEntity> _getInseminacoesSemDiagnostico() {
    final inseminacoesComDiagnostico = widget.diagnosticos.map((d) => d.inseminacao.id).toSet();
    return widget.inseminacoes.where((inseminacao) => !inseminacoesComDiagnostico.contains(inseminacao.id)).toList();
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

    // Atualizar lista de inseminações se mudou ou se mudaram os diagnósticos
    if (widget.inseminacoes != oldWidget.inseminacoes || widget.diagnosticos != oldWidget.diagnosticos) {
      _inseminacoesFiltradas = _getInseminacoesSemDiagnostico();
    }

    // Se a inseminação selecionada mudou, atualizar o campo
    if (widget.inseminacaoSelecionada != oldWidget.inseminacaoSelecionada) {
      if (widget.inseminacaoSelecionada != null) {
        _controller.text = _getInseminacaoDisplayText(widget.inseminacaoSelecionada!);
      } else {
        _controller.clear();
      }
    }
  }

  void _filtrarInseminacoes(String query) {
    final inseminacoesSemDiagnostico = _getInseminacoesSemDiagnostico();

    if (query.isEmpty) {
      setState(() {
        _inseminacoesFiltradas = inseminacoesSemDiagnostico;
      });
    } else {
      final queryLower = query.toLowerCase();
      setState(() {
        _inseminacoesFiltradas = inseminacoesSemDiagnostico.where((inseminacao) {
          final animal = inseminacao.animal;
          return animal.identificacaoUnica.toLowerCase().contains(queryLower) ||
              (animal.nomeRegistro?.toLowerCase().contains(queryLower) ?? false) ||
              animal.situacao.toLowerCase().contains(queryLower) ||
              animal.idAnimal.toLowerCase().contains(queryLower) ||
              inseminacao.tipo.label.toLowerCase().contains(queryLower);
        }).toList();
      });
    }
  }

  String _getInseminacaoDisplayText(InseminacaoEntity inseminacao) {
    final animal = inseminacao.animal;
    final dataFormatada = _dateFormat.format(inseminacao.dataInseminacao);

    String animalText = _getAnimalDisplayText(animal);

    return '$animalText - $dataFormatada';
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

  void _mostrarSugestoes() {
    _ocultarSugestoes();

    if (_inseminacoesFiltradas.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox;
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _inseminacoesFiltradas.length,
              itemBuilder: (context, index) {
                final inseminacao = _inseminacoesFiltradas[index];
                final animal = inseminacao.animal;
                final dataFormatada = _dateFormat.format(inseminacao.dataInseminacao);

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    _getAnimalDisplayText(animal),
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Data: $dataFormatada • Tipo: ${inseminacao.tipo.label}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  onTap: () => _selecionarInseminacao(inseminacao),
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
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selecionarInseminacao(InseminacaoEntity inseminacao) {
    _controller.text = _getInseminacaoDisplayText(inseminacao);
    widget.onChanged(inseminacao);
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
            hintText: 'Digite para pesquisar inseminações disponíveis...',
            suffixIcon: widget.enabled ? const Icon(Icons.search) : null,
            border: const OutlineInputBorder(),
          ),
          validator: widget.validator,
          onTap: () {
            if (widget.enabled && _inseminacoesFiltradas.isNotEmpty) {
              _mostrarSugestoes();
            }
          },
        ),
        if (_inseminacoesFiltradas.isEmpty && widget.inseminacoes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Todas as inseminações já possuem diagnóstico',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
