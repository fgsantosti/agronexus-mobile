import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget para desenhar/editar um polígono e retornar JSON de coordenadas.
/// Salva formato: [[lat,lng],[lat,lng],...]
class PolygonEditor extends StatefulWidget {
  final List<List<double>>? initial;
  final ValueChanged<List<List<double>>> onChanged;
  final VoidCallback? onClear;
  const PolygonEditor({super.key, this.initial, required this.onChanged, this.onClear});

  @override
  State<PolygonEditor> createState() => _PolygonEditorState();
}

class _PolygonEditorState extends State<PolygonEditor> {
  final MapController _mapController = MapController();
  final List<LatLng> _points = [];
  bool _closed = false;
  DateTime _lastNotify = DateTime.fromMillisecondsSinceEpoch(0);
  static const _notifyIntervalMs = 120; // debounce

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
  }

  void _addPoint(LatLng latLng) {
    if (_closed) return; // não adicionar depois de fechar
    setState(() {
      _points.add(latLng);
      _closed = _points.length > 2 && _points.length >= 3;
    });
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
    });
    widget.onClear?.call();
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final hasPolygon = _points.isNotEmpty;
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
                                    setState(() {
                                      _points.removeAt(e.key);
                                      _closed = _points.length > 2;
                                    });
                                    _notify();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.green, width: 3),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1))],
                                    ),
                                    child: Center(
                                      child: Text('${e.key + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _points.length >= 3 && !_closed
                  ? () {
                      setState(() => _closed = true);
                      _notify();
                    }
                  : null,
              icon: Icon(_closed ? Icons.lock : Icons.check_circle),
              label: Text(_closed ? 'Fechado' : 'Fechar'),
            ),
            OutlinedButton.icon(
              onPressed: _undo,
              icon: const Icon(Icons.undo),
              label: const Text('Desfazer'),
            ),
            OutlinedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear),
              label: const Text('Limpar'),
            ),
            if (_points.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  final jsonStr = const JsonEncoder.withIndent('  ').convert(
                    _points.map((e) => [e.latitude, e.longitude]).toList(),
                  );
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('JSON do Polígono'),
                      content: SingleChildScrollView(child: Text(jsonStr)),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
                    ),
                  );
                },
                icon: const Icon(Icons.code),
                label: const Text('Ver JSON'),
              ),
          ],
        ),
        Text(
          _points.isEmpty ? 'Toque no mapa para adicionar pontos.' : 'Pontos: ${_points.length}${_closed ? ' (fechado)' : ''}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
