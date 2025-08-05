import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/presentation/bloc/animal/animal_state.dart';
import 'package:agronexus/presentation/animal/animal_form_screen.dart';
import 'package:agronexus/domain/models/animal_entity.dart';

class AnimalEditScreen extends StatefulWidget {
  final String animalId;

  const AnimalEditScreen({
    super.key,
    required this.animalId,
  });

  @override
  State<AnimalEditScreen> createState() => _AnimalEditScreenState();
}

class _AnimalEditScreenState extends State<AnimalEditScreen> {
  AnimalEntity? _animalCarregado;

  @override
  void initState() {
    super.initState();
    // Carregar os dados do animal para edição
    context.read<AnimalBloc>().add(LoadAnimalDetailEvent(widget.animalId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnimalBloc, AnimalState>(
      listener: (context, state) {
        if (state is AnimalDetailLoaded) {
          setState(() {
            _animalCarregado = state.animal;
          });
        }
      },
      child: BlocBuilder<AnimalBloc, AnimalState>(
        builder: (context, state) {
          // Se o animal já foi carregado, mostrar o formulário
          if (_animalCarregado != null) {
            return AnimalFormScreen(animal: _animalCarregado);
          }

          if (state is AnimalLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Carregando...'),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AnimalError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Erro'),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AnimalBloc>().add(LoadAnimalDetailEvent(widget.animalId));
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Estado inicial
          return Scaffold(
            appBar: AppBar(
              title: const Text('Carregando...'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
