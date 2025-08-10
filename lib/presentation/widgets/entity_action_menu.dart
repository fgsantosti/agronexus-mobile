import 'package:flutter/material.dart';

/// Menu de ações padronizado atualmente exibindo apenas "Detalhes".
/// (Editar / Excluir foram removidos pela diretriz de design.)
/// Uso:
/// EntityActionMenu(
///   onDetails: () {},
/// )
class EntityActionMenu extends StatelessWidget {
  final VoidCallback? onDetails;
  final VoidCallback? onEdit; // reservado para futura reativação
  final VoidCallback? onDelete; // reservado para futura reativação
  final IconData icon;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const EntityActionMenu({
    super.key,
    this.onDetails,
    this.onEdit,
    this.onDelete,
    this.icon = Icons.more_vert,
    this.iconSize = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ActionKey>(
      padding: padding ?? EdgeInsets.zero,
      icon: Icon(icon, size: iconSize),
      onSelected: (value) {
        if (value == _ActionKey.details) {
          onDetails?.call();
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_ActionKey>>[];
        if (onDetails != null) {
          items.add(
            const PopupMenuItem(
              value: _ActionKey.details,
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Detalhes'),
                ],
              ),
            ),
          );
        }
        // Itens de editar / excluir removidos conforme solicitação
        return items;
      },
    );
  }
}

enum _ActionKey { details }

/// Helper para AppBars de telas de detalhes com padrão verde e ícones brancos.
PreferredSizeWidget buildDetailAppBar(String titulo) {
  return AppBar(
    backgroundColor: Colors.green.shade600,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    title: Text(titulo),
  );
}
