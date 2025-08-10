import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetalhesAreaScreen extends StatelessWidget {
  final AreaEntity area;
  const DetalhesAreaScreen({super.key, required this.area});

  List<LatLng> _parsePolygon(dynamic data) {
    if (data is List) {
      return data
          .whereType<List>()
          .where((e) => e.length == 2)
          .map((e) => LatLng(
                double.tryParse(e[0].toString()) ?? 0,
                double.tryParse(e[1].toString()) ?? 0,
              ))
          .toList();
    }
    return [];
  }

  double _computeAreaHa(List<LatLng> pts) {
    if (pts.length < 3) return 0;
    const earthRadius = 6378137.0;
    final latRad = pts.map((p) => p.latitude * (3.141592653589793 / 180)).toList();
    final lonRad = pts.map((p) => p.longitude * (3.141592653589793 / 180)).toList();
    final latMean = latRad.reduce((a, b) => a + b) / latRad.length;
    final cosLat = math.cos(latMean);
    final xs = <double>[];
    final ys = <double>[];
    for (var i = 0; i < pts.length; i++) {
      xs.add(earthRadius * lonRad[i] * cosLat);
      ys.add(earthRadius * latRad[i]);
    }
    double area2 = 0;
    for (var i = 0; i < xs.length; i++) {
      final j = (i + 1) % xs.length;
      area2 += xs[i] * ys[j] - xs[j] * ys[i];
    }
    return (area2.abs() / 2) / 10000.0;
  }

  @override
  Widget build(BuildContext context) {
    final polygonPoints = _parsePolygon(area.coordenadasPoligono);
    final areaHaCalc = _computeAreaHa(polygonPoints);
    return Scaffold(
      appBar: buildStandardAppBar(title: 'Detalhes - ${area.nome}'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: 'Informações Básicas', children: [
            _InfoRow(label: 'Nome', value: area.nome),
            _InfoRow(label: 'Tipo', value: area.tipo),
            _InfoRow(label: 'Status', value: area.status),
            _InfoRow(label: 'Tamanho (ha)', value: area.tamanhoHa.toStringAsFixed(4)),
            if (areaHaCalc > 0) _InfoRow(label: 'Área Polígono (ha)', value: areaHaCalc.toStringAsFixed(areaHaCalc < 10 ? 4 : 2)),
            if (area.propriedadeNome != null) _InfoRow(label: 'Propriedade', value: area.propriedadeNome!),
          ]),
          const SizedBox(height: 16),
          _Section(
            title: 'Mapa',
            children: [
              SizedBox(
                height: 280,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: polygonPoints.isEmpty
                      ? Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Text('Sem polígono cadastrado', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : FlutterMap(
                          options: MapOptions(
                            initialCenter: polygonPoints.first,
                            initialZoom: 16,
                            interactionOptions: const InteractionOptions(enableMultiFingerGestureRace: true),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'agronexus-mobile',
                            ),
                            PolygonLayer(polygons: [
                              Polygon(
                                points: polygonPoints,
                                color: Colors.green.withOpacity(0.3),
                                borderColor: Colors.green,
                                borderStrokeWidth: 3,
                              )
                            ]),
                            MarkerLayer(
                              markers: polygonPoints
                                  .asMap()
                                  .entries
                                  .map((e) => Marker(
                                        point: e.value,
                                        width: 30,
                                        height: 30,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.green, width: 2),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${e.key + 1}',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            )
                          ],
                        ),
                ),
              ),
              if (polygonPoints.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Vértices: ${polygonPoints.length} • Área polígono: ${areaHaCalc.toStringAsFixed(areaHaCalc < 10 ? 4 : 2)} ha',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (area.observacoes != null && area.observacoes!.isNotEmpty) _Section(title: 'Observações', children: [Text(area.observacoes!)])
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
