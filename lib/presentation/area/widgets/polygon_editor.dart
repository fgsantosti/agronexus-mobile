import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget para desenhar/editar um polígono e retornar JSON de coordenadas.
/// Salva formato: [[lat,lng],[lat,lng],...]
class PolygonEditor extends StatefulWidget {
  final List<List<double>>? initial;
  final ValueChanged<List<List<double>>> onChanged;
  final VoidCallback? onClear;
  final ValueChanged<double>? onAreaChanged; // hectares calculados
  const PolygonEditor({super.key, this.initial, required this.onChanged, this.onClear, this.onAreaChanged});

  @override
  State<PolygonEditor> createState() => _PolygonEditorState();
}

class _PolygonEditorState extends State<PolygonEditor> {
  final MapController _mapController = MapController();
  final List<LatLng> _points = [];
  bool _closed = false; // indica se polígono está finalizado (impede novos pontos)
  int? _editingIndex; // índice do ponto em edição (reposicionamento ou remoção)
  DateTime _lastNotify = DateTime.fromMillisecondsSinceEpoch(0);
  static const _notifyIntervalMs = 120; // debounce de callbacks

  @override
  void initState() {
    super.initState();
    if (widget.initial != null && widget.initial!.isNotEmpty) {
      for (final p in widget.initial!) {
        if (p.length == 2) _points.add(LatLng(p[0], p[1]));
      }
      _closed = _points.length > 2;
    }
  }

  void _notify() {
    final now = DateTime.now();
    if (now.difference(_lastNotify).inMilliseconds < _notifyIntervalMs) return;
    _lastNotify = now;
    final data = _points.map((e) => [double.parse(e.latitude.toStringAsFixed(6)), double.parse(e.longitude.toStringAsFixed(6))]).toList(growable: false);
    widget.onChanged(data);
    if (widget.onAreaChanged != null) {
      widget.onAreaChanged!(_computeAreaHa());
    }
  }

  void _addPoint(LatLng latLng) {
    // Se estamos reposicionando um ponto existente
    if (_editingIndex != null) {
      setState(() {
        if (_editingIndex! >= 0 && _editingIndex! < _points.length) {
          _points[_editingIndex!] = latLng;
        }
        _editingIndex = null; // conclui edição ao tocar
      });
      _notify();
      return;
    }
    if (_closed) return; // não adicionar se polígono fechado
    setState(() => _points.add(latLng));
    _notify();
  }

  void _undo() {
    if (_points.isEmpty) return;
    setState(() {
      _points.removeLast();
      _closed = _points.length > 2;
    });
    _notify();
  }

  void _clear() {
    setState(() {
      _points.clear();
      _closed = false;
      _editingIndex = null;
    });
    widget.onClear?.call();
    _notify();
    if (widget.onAreaChanged != null) widget.onAreaChanged!(0);
  }

  double _computeAreaHa() {
    if (_points.length < 3) return 0;
    // Projeção planar simples (equiretangular) adequada para áreas pequenas.
    const earthRadius = 6378137.0; // metros
    final latRad = _points.map((p) => p.latitude * (math.pi / 180.0)).toList();
    final lonRad = _points.map((p) => p.longitude * (math.pi / 180.0)).toList();
    final latMean = latRad.reduce((a, b) => a + b) / latRad.length;
    final cosLat = math.cos(latMean);
    final xs = <double>[];
    final ys = <double>[];
    for (var i = 0; i < _points.length; i++) {
      xs.add(earthRadius * lonRad[i] * cosLat);
      ys.add(earthRadius * latRad[i]);
    }
    double area2 = 0; // duas vezes a área
    for (var i = 0; i < xs.length; i++) {
      final j = (i + 1) % xs.length;
      area2 += xs[i] * ys[j] - xs[j] * ys[i];
    }
    final areaM2 = area2.abs() / 2.0;
    return areaM2 / 10000.0; // converte m² para hectares
  }

  @override
  Widget build(BuildContext context) {
    final hasPolygon = _points.isNotEmpty;
    final areaHa = _computeAreaHa();
    final polygon = hasPolygon
        ? Polygon(
            points: _points,
            borderColor: Colors.green,
            borderStrokeWidth: 2.5,
            color: Colors.green.withOpacity(0.25),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _points.isNotEmpty ? _points.first : const LatLng(-15.7801, -47.9292),
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (tapPos, latLng) => _addPoint(latLng),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'agronexus-mobile',
                      tileBuilder: (context, widget, tile) => widget,
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('Tile error: $error');
                      },
                    ),
                    if (polygon != null) PolygonLayer(polygons: [polygon]),
                    if (hasPolygon)
                      MarkerLayer(
                        markers: _points
                            .asMap()
                            .entries
                            .map(
                              (e) => Marker(
                                point: e.value,
                                width: 38,
                                height: 38,
                                child: GestureDetector(
                                  onLongPress: () {
                                    // Long press: entrar em modo edição ou remover se já selecionado
                                    setState(() {
                                      if (_editingIndex == e.key) {
                                        // remover ponto
                                        _points.removeAt(e.key);
                                        _editingIndex = null;
                                      } else {
                                        _editingIndex = e.key;
                                      }
                                      if (_points.length < 3) _closed = false; // não pode manter fechado se <3
                                    });
                                    _notify();
                                    if (_editingIndex != null && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 4),
                                          content: Text('Editando ponto #${e.key + 1}. Toque no mapa para reposicionar ou long press de novo para remover.'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _editingIndex == e.key ? Colors.orange.shade100 : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _editingIndex == e.key ? Colors.deepOrange : Colors.green,
                                        width: 3,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${e.key + 1}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              if (areaHa > 0)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Card(
                    color: Colors.black.withOpacity(0.55),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '${areaHa.toStringAsFixed(areaHa < 10 ? 3 : 2)} ha',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 8,
                top: 8,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      onPressed: hasPolygon
                          ? () {
                              final center = _points.reduce((a, b) => LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2));
                              _mapController.move(center, _mapController.camera.zoom);
                            }
                          : null,
                      child: const Icon(Icons.my_location, size: 18),
                    ),
                    const SizedBox(height: 6),
                    FloatingActionButton.small(
                      onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 0.5),
                      child: const Icon(Icons.add, size: 20),
                    ),
                    const SizedBox(height: 6),
                    FloatingActionButton.small(
                      onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 0.5),
                      child: const Icon(Icons.remove, size: 20),
                    ),
                  ],
                ),
              ),
              if (!hasPolygon)
                const Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Text(
                          'Toque para adicionar pontos do polígono',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_points.length >= 3 || _closed)
                ? () {
                    setState(() {
                      if (_closed) {
                        _closed = false; // reabrir edição
                      } else {
                        _closed = true; // fechar polígono
                        _editingIndex = null; // sair de edição
                      }
                    });
                    _notify();
                  }
                : null,
            icon: Icon(_closed ? Icons.lock_open : Icons.check_circle),
            label: Text(_closed ? 'Reabrir' : 'Fechar'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _undo,
                icon: const Icon(Icons.undo),
                label: const Text('Desfazer'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.clear),
                label: const Text('Limpar'),
              ),
            ),
          ],
        ),
        if (_editingIndex != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _editingIndex = null),
              icon: const Icon(Icons.done),
              label: const Text('Concluir edição'),
            ),
          ),
        ],
        Text(
          _points.isEmpty
              ? 'Toque no mapa para adicionar pontos.'
              : 'Pontos: ${_points.length}${_closed ? ' (fechado)' : ''}${areaHa > 0 ? ' • Área: ${areaHa.toStringAsFixed(areaHa < 10 ? 3 : 2)} ha' : ''}${_editingIndex != null ? ' • Editando #${_editingIndex! + 1}' : ''}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
