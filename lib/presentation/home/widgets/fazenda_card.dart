import 'package:agronexus/config/routers/router.dart';
import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/presentation/bloc/fazenda/fazenda_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class FazendaCard extends StatelessWidget {
  final FazendaEntity fazenda;
  const FazendaCard({super.key, required this.fazenda});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fazenda.nome, style: TextStyle(fontSize: 18)),
                Chip(
                  label: Text(
                    fazenda.tipo.label,
                    style: TextStyle(fontSize: 16),
                  ),
                  padding: EdgeInsets.only(left: 4, right: 4),
                  backgroundColor: Colors.green[50],
                ),
              ],
            ),
            Text(
              'Local: ${fazenda.localizacao}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  avatar: Icon(FontAwesomeIcons.clone),
                  label: Text(
                    '${fazenda.lotes?.length ?? 0} lotes',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 8),
                Chip(
                  avatar: Icon(FontAwesomeIcons.cow),
                  padding: EdgeInsets.only(left: 4, right: 4),
                  label: Text(
                    '${fazenda.totalAnimaisAtivos} animais',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).push(
                      AgroNexusRouter.fazenda.detailPath,
                      extra: fazenda.id,
                    );
                  },
                  child: Text(
                    'Ver Detalhes',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                  ),
                  onPressed: () async {
                    FazendaBloc bloc = context.read<FazendaBloc>();
                    bool? value = await GoRouter.of(context).push<bool>(
                      AgroNexusRouter.fazenda.editPath,
                      extra: fazenda.id,
                    );
                    if (value != null) bloc.add(ListFazendaEvent());
                  },
                  child: Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
