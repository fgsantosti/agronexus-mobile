import 'package:flutter/material.dart';
import 'package:agronexus/domain/models/animal_entity.dart';

class AnimalSearchField extends StatefulWidget {
  final List<AnimalEntity> animais;
  final AnimalEntity? animalSelecionado;
  final Function(AnimalEntity?) onChanged;
  final String labelText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool apenasFemeas;
  final bool apenasManhos;

  const AnimalSearchField({
    super.key,
    required this.animais,
    required this.onChanged,
    this.animalSelecionado,
    this.labelText = 'Animal',
    this.validator,
    this.enabled = true,
    this.apenasFemeas = false,
    this.apenasManhos = false,
  });

  @override
  State<AnimalSearchField> createState() => _AnimalSearchFieldState();
}

class _AnimalSearchFieldState extends State<AnimalSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<AnimalEntity> _animaisFiltrados = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animaisFiltrados = _getAnimaisDisponiveis();

    // Se há um animal selecionado, mostra no campo
    if (widget.animalSelecionado != null) {
      _controller.text = _getAnimalDisplayText(widget.animalSelecionado!);
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _ocultarSugestoes();
      } else {
        // Quando recebe foco, filtra com o texto atual (ou string vazia para mostrar todos)
        _filtrarAnimais(_controller.text);
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

  List<AnimalEntity> _getAnimaisDisponiveis() {
    print('DEBUG WIDGET - Total animais recebidos: ${widget.animais.length}');
    if (widget.apenasFemeas) {
      final femeas = widget.animais.where((animal) => animal.sexo == Sexo.femea).toList();
      print('DEBUG WIDGET - Filtrando apenas fêmeas: ${femeas.length}');
      return femeas;
    }
    if (widget.apenasManhos) {
      final machos = widget.animais.where((animal) => animal.sexo == Sexo.macho).toList();
      print('DEBUG WIDGET - Filtrando apenas machos: ${machos.length}');
      print('DEBUG WIDGET - Primeiro macho: ${machos.isNotEmpty ? '${machos.first.idAnimal} - ${machos.first.fazendaNome}' : 'Nenhum'}');
      return machos;
    }
    return widget.animais;
  }

  String _getAnimalDisplayText(AnimalEntity animal) {
    final nome = animal.fazendaNome.isNotEmpty ? animal.fazendaNome : 'Sem nome';
    final sexoIndicador = animal.sexo == Sexo.femea ? '♀' : '♂';
    return '${animal.idAnimal} - $nome $sexoIndicador';
  }

  void _filtrarAnimais(String query) {
    print('DEBUG WIDGET - Filtrando animais com query: "$query"');
    // Remove o overlay antes de atualizar a lista para evitar problemas de concorrência
    _removeOverlay();

    final animaisDisponiveis = _getAnimaisDisponiveis();
    print('DEBUG WIDGET - Animais disponíveis para filtrar: ${animaisDisponiveis.length}');

    setState(() {
      if (query.isEmpty) {
        _animaisFiltrados = List<AnimalEntity>.from(animaisDisponiveis);
        print('DEBUG WIDGET - Query vazia, mostrando todos: ${_animaisFiltrados.length}');
      } else {
        _animaisFiltrados = animaisDisponiveis.where((animal) {
          final searchQuery = query.toLowerCase();
          final identificacao = animal.idAnimal.toLowerCase();
          final nome = animal.fazendaNome.toLowerCase();

          return identificacao.contains(searchQuery) || nome.contains(searchQuery);
        }).toList();
        print('DEBUG WIDGET - Após filtrar por "$query": ${_animaisFiltrados.length} resultados');
        if (_animaisFiltrados.isNotEmpty) {
          print('DEBUG WIDGET - Primeiro resultado: ${_animaisFiltrados.first.idAnimal}');
        }
      }
    });

    // Mostra as sugestões após a atualização da lista
    if (query.isNotEmpty) {
      print('DEBUG WIDGET - Tentando mostrar sugestões. Query: "$query", Resultados: ${_animaisFiltrados.length}');
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
        final animaisParaMostrar = List<AnimalEntity>.from(_animaisFiltrados);

        return Positioned(
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
              child: animaisParaMostrar.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhum animal encontrado',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: animaisParaMostrar.length,
                      itemBuilder: (context, index) {
                        // Verificação de segurança para evitar RangeError
                        if (index >= animaisParaMostrar.length) {
                          return const SizedBox.shrink();
                        }

                        final animal = animaisParaMostrar[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            animal.sexo == Sexo.femea ? Icons.female : Icons.male,
                            size: 20,
                            color: animal.sexo == Sexo.femea ? Colors.pink : Colors.blue,
                          ),
                          title: Text(
                            animal.idAnimal,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${animal.fazendaNome.isNotEmpty ? animal.fazendaNome : 'Sem nome'} - ${animal.sexo.label}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onTap: () {
                            _selecionarAnimal(animal);
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

  void _selecionarAnimal(AnimalEntity animal) {
    _controller.text = _getAnimalDisplayText(animal);
    widget.onChanged(animal);
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
              widget.apenasFemeas
                  ? Icons.female
                  : widget.apenasManhos
                      ? Icons.male
                      : Icons.pets,
              color: widget.apenasFemeas
                  ? Colors.pink
                  : widget.apenasManhos
                      ? Colors.blue
                      : null,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _limparSelecao,
                  )
                : const Icon(Icons.search),
            hintText: widget.apenasFemeas
                ? 'Digite a identificação ou nome da fêmea'
                : widget.apenasManhos
                    ? 'Digite a identificação ou nome do macho'
                    : 'Digite a identificação ou nome do animal',
          ),
          onChanged: (value) {
            _filtrarAnimais(value);

            // Se o texto não corresponde exatamente a um animal selecionado,
            // remove a seleção
            final animaisDisponiveis = _getAnimaisDisponiveis();
            final animaisExatos = animaisDisponiveis.where((animal) => _getAnimalDisplayText(animal) == value);

            if (animaisExatos.isEmpty && widget.animalSelecionado != null) {
              widget.onChanged(null);
            }
          },
          onTap: () {
            // Quando o usuário toca no campo, mostra as sugestões
            _filtrarAnimais(_controller.text);
          },
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null;
          },
        ),
        if (widget.animalSelecionado != null)
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
                      'Selecionado: ${_getAnimalDisplayText(widget.animalSelecionado!)}',
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
        if ((widget.apenasFemeas || widget.apenasManhos) && _getAnimaisDisponiveis().isEmpty)
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
                      widget.apenasFemeas ? 'Nenhuma fêmea disponível para inseminação' : 'Nenhum macho disponível como reprodutor',
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
