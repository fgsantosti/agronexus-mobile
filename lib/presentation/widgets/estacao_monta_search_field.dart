import 'package:flutter/material.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:intl/intl.dart';

class EstacaoMontaSearchField extends StatefulWidget {
  final List<EstacaoMontaEntity> estacoes;
  final EstacaoMontaEntity? estacaoSelecionada;
  final Function(EstacaoMontaEntity?) onChanged;
  final String labelText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool apenasAtivas;

  const EstacaoMontaSearchField({
    super.key,
    required this.estacoes,
    required this.onChanged,
    this.estacaoSelecionada,
    this.labelText = 'Estação de Monta',
    this.validator,
    this.enabled = true,
    this.apenasAtivas = true,
  });

  @override
  State<EstacaoMontaSearchField> createState() => _EstacaoMontaSearchFieldState();
}

class _EstacaoMontaSearchFieldState extends State<EstacaoMontaSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  List<EstacaoMontaEntity> _estacoesFiltradas = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _estacoesFiltradas = _getEstacoesDisponiveis();

    // Se há uma estação selecionada, mostra no campo
    if (widget.estacaoSelecionada != null) {
      _controller.text = _getEstacaoDisplayText(widget.estacaoSelecionada!);
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _ocultarSugestoes();
      } else {
        // Quando recebe foco, filtra com o texto atual (ou string vazia para mostrar todos)
        _filtrarEstacoes(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  List<EstacaoMontaEntity> _getEstacoesDisponiveis() {
    print('DEBUG WIDGET - Total estações recebidas: ${widget.estacoes.length}');
    if (widget.apenasAtivas) {
      final ativas = widget.estacoes.where((estacao) => estacao.ativa).toList();
      print('DEBUG WIDGET - Filtrando apenas ativas: ${ativas.length}');
      return ativas;
    }
    return widget.estacoes;
  }

  String _getEstacaoDisplayText(EstacaoMontaEntity estacao) {
    final periodo = '${_dateFormat.format(estacao.dataInicio)} - ${_dateFormat.format(estacao.dataFim)}';
    final status = estacao.ativa ? '🟢' : '🔴';
    return '${estacao.nome} $status ($periodo)';
  }

  void _filtrarEstacoes(String query) {
    print('DEBUG WIDGET - Filtrando estações com query: "$query"');
    // Remove o overlay antes de atualizar a lista para evitar problemas de concorrência
    _removeOverlay();

    final estacoesDisponiveis = _getEstacoesDisponiveis();
    print('DEBUG WIDGET - Estações disponíveis para filtrar: ${estacoesDisponiveis.length}');

    setState(() {
      if (query.isEmpty) {
        _estacoesFiltradas = List<EstacaoMontaEntity>.from(estacoesDisponiveis);
        print('DEBUG WIDGET - Query vazia, mostrando todas: ${_estacoesFiltradas.length}');
      } else {
        _estacoesFiltradas = estacoesDisponiveis.where((estacao) {
          final searchQuery = query.toLowerCase();
          final nome = estacao.nome.toLowerCase();
          final dataInicio = _dateFormat.format(estacao.dataInicio).toLowerCase();
          final dataFim = _dateFormat.format(estacao.dataFim).toLowerCase();

          return nome.contains(searchQuery) || dataInicio.contains(searchQuery) || dataFim.contains(searchQuery);
        }).toList();
        print('DEBUG WIDGET - Após filtrar por "$query": ${_estacoesFiltradas.length} resultados');
        if (_estacoesFiltradas.isNotEmpty) {
          print('DEBUG WIDGET - Primeiro resultado: ${_estacoesFiltradas.first.nome}');
        }
      }
    });

    // Mostra as sugestões após a atualização da lista
    if (query.isNotEmpty || _focusNode.hasFocus) {
      print('DEBUG WIDGET - Tentando mostrar sugestões. Query: "$query", Resultados: ${_estacoesFiltradas.length}');
      // Usa um pequeno delay para garantir que o setState terminou
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          print('DEBUG WIDGET - Chamando _mostrarSugestoes()');
          _mostrarSugestoes();
        } else {
          print('DEBUG WIDGET - NÃO chamando _mostrarSugestoes(). mounted: $mounted, hasFocus: ${_focusNode.hasFocus}');
        }
      });
    }
  }

  void _mostrarSugestoes() {
    print('DEBUG WIDGET - _mostrarSugestoes() chamado. _overlayEntry: ${_overlayEntry != null}, mounted: $mounted');
    if (_overlayEntry != null || !mounted) {
      print('DEBUG WIDGET - Saindo de _mostrarSugestoes(). Overlay já existe ou não montado.');
      return;
    }

    // Adiciona validação extra para garantir que o contexto é válido
    try {
      print('DEBUG WIDGET - Criando overlay entry...');
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      print('DEBUG WIDGET - Overlay inserido com sucesso!');
    } catch (e) {
      // Se há erro ao criar overlay, define como null para permitir nova tentativa
      print('DEBUG WIDGET - Erro ao criar overlay: $e');
      _overlayEntry = null;
    }
  }

  void _ocultarSugestoes() {
    _removeOverlay();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        // Cria uma cópia local da lista para evitar problemas de concorrência
        final estacoesParaMostrar = List<EstacaoMontaEntity>.from(_estacoesFiltradas);

        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: estacoesParaMostrar.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhuma estação de monta encontrada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: estacoesParaMostrar.length,
                      itemBuilder: (context, index) {
                        // Verificação de segurança para evitar RangeError
                        if (index >= estacoesParaMostrar.length) {
                          return const SizedBox.shrink();
                        }

                        final estacao = estacoesParaMostrar[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.event,
                            size: 20,
                            color: estacao.ativa ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            estacao.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Período: ${_dateFormat.format(estacao.dataInicio)} - ${_dateFormat.format(estacao.dataFim)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Status: ${estacao.ativa ? "Ativa" : "Inativa"} • Fêmeas: ${estacao.totalFemeas} • Taxa: ${estacao.taxaPrenhez.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: estacao.ativa ? Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              estacao.ativa ? 'ATIVA' : 'INATIVA',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: estacao.ativa ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                          ),
                          onTap: () {
                            _selecionarEstacao(estacao);
                          },
                          hoverColor: Colors.blue.shade50,
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  void _selecionarEstacao(EstacaoMontaEntity estacao) {
    _controller.text = _getEstacaoDisplayText(estacao);
    widget.onChanged(estacao);
    _ocultarSugestoes();
    _focusNode.unfocus();
  }

  void _limparSelecao() {
    _controller.clear();
    widget.onChanged(null);
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
            border: const OutlineInputBorder(),
            prefixIcon: Icon(
              Icons.event,
              color: widget.apenasAtivas ? Colors.green : null,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _limparSelecao,
                  )
                : const Icon(Icons.search),
            hintText: widget.apenasAtivas ? 'Digite o nome da estação de monta ativa' : 'Digite o nome da estação de monta',
          ),
          onChanged: (value) {
            _filtrarEstacoes(value);

            // Se o texto não corresponde exatamente a uma estação selecionada,
            // remove a seleção
            final estacoesDisponiveis = _getEstacoesDisponiveis();
            final estacoesExatas = estacoesDisponiveis.where((estacao) => _getEstacaoDisplayText(estacao) == value);

            if (estacoesExatas.isEmpty && widget.estacaoSelecionada != null) {
              widget.onChanged(null);
            }
          },
          onTap: () {
            // Quando o usuário toca no campo, mostra as sugestões
            _filtrarEstacoes(_controller.text);
          },
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null;
          },
        ),
        if (widget.estacaoSelecionada != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selecionada: ${_getEstacaoDisplayText(widget.estacaoSelecionada!)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (widget.apenasAtivas && _getEstacoesDisponiveis().isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nenhuma estação de monta ativa disponível',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
