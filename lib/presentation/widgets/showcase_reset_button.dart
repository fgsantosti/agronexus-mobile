import 'package:flutter/material.dart';
import 'package:agronexus/config/services/showcase_service.dart';
import 'package:agronexus/config/inject_dependencies.dart';

/// Widget para resetar o showcase (útil para testes e desenvolvimento)
/// Pode ser adicionado em telas de debug ou configurações
class ShowcaseResetButton extends StatelessWidget {
  const ShowcaseResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.replay, color: Colors.orange),
      title: const Text('Resetar Tutorial'),
      subtitle: const Text('Exibir tutorial novamente na próxima abertura'),
      onTap: () async {
        final showcaseService = getIt<ShowcaseService>();
        await showcaseService.resetAllShowcases();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tutorial resetado! Ele será exibido novamente ao abrir o app.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }
}
