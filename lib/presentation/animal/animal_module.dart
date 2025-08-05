import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/animal_service.dart';
import 'package:agronexus/domain/repositories/remote/animal/animal_remote_repository_impl.dart';
import 'package:agronexus/config/services/http_impl.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/animal/animal_list_screen.dart';

class AnimalModule extends StatelessWidget {
  const AnimalModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnimalBloc(
        AnimalService(
          AnimalRemoteRepositoryImpl(
            httpService: HttpServiceImpl(),
          ),
        ),
      ),
      child: const AnimalListScreen(),
    );
  }
}

// Para usar em uma tela principal ou roteamento:
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroNexus - Animais',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const AnimalModule(),
    );
  }
}

// Exemplo de roteamento
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/animais':
      return MaterialPageRoute(
        builder: (_) => const AnimalModule(),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Página não encontrada'),
          ),
        ),
      );
  }
}
