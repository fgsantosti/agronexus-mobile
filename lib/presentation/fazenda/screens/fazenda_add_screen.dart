import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/presentation/bloc/fazenda/fazenda_bloc.dart';
import 'package:agronexus/presentation/widgets/select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class FazendaAddScreen extends StatefulWidget {
  const FazendaAddScreen({super.key});

  @override
  State<FazendaAddScreen> createState() => _FazendaAddScreenState();
}

class _FazendaAddScreenState extends State<FazendaAddScreen> {
  static const String _requiredField = "Campo obrigatório";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const String _nomeLabel = "Nome da Fazenda";
  static const String _nomePlaceholder = "Digite o nome da fazenda";
  static const String _localizacaoLabel = "Localização";
  static const String _localizacaoPlaceholder = "Digite a localização";
  static const String _hectaresLabel = "Hectares";
  static const String _hectaresPlaceholder = "Digite a quantidade de hectares";
  static const String _tipoLabel = "Tipo de Fazenda";
  static const String _tipoPlaceholder = "Selecione o tipo de fazenda";
  static const String _ativaLabel = "Ativa";
  static const String _latitudeLabel = "Latitude";
  static const String _latitudePlaceholder = "Digite a latitude";
  static const String _longitudeLabel = "Longitude";
  static const String _longitudePlaceholder = "Digite a longitude";

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _hectaresController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _localizacaoController.dispose();
    _hectaresController.dispose();
    _tipoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _sendForm() async {
    if (_formKey.currentState!.validate()) {
      FazendaBloc bloc = context.read<FazendaBloc>();
      bloc.add(
        UpdateLoadedFazendaEvent(
          entity: bloc.state.entity.copyWith(
            nome: () => _nomeController.text,
            localizacao: () => _localizacaoController.text,
            hectares: () => _hectaresController.text,
            tipo: () => bloc.state.entity.tipo,
            ativa: () => bloc.state.entity.ativa,
            latitude: () => _latitudeController.text,
            longitude: () => _longitudeController.text,
          ),
        ),
      );
      bloc.add(
        bloc.state.entity.id != null
            ? UpdateFazendaEvent(
                entity: bloc.state.entity.copyWith(
                  nome: () => _nomeController.text,
                  localizacao: () => _localizacaoController.text,
                  hectares: () => _hectaresController.text,
                  tipo: () => bloc.state.entity.tipo,
                  ativa: () => bloc.state.entity.ativa,
                  latitude: () => _latitudeController.text,
                  longitude: () => _longitudeController.text,
                ),
              )
            : CreateFazendaEvent(
                entity: bloc.state.entity.copyWith(
                  nome: () => _nomeController.text,
                  localizacao: () => _localizacaoController.text,
                  hectares: () => _hectaresController.text,
                  tipo: () => bloc.state.entity.tipo,
                  ativa: () => bloc.state.entity.ativa,
                  latitude: () => _latitudeController.text,
                  longitude: () => _longitudeController.text,
                ),
              ),
      );
    }
  }

  Future<String> _getLatitude() async {
    Position position = await _getCurrentLocationWithPermission();
    return position.latitude.toString();
  }

  Future<String> _getLongitude() async {
    Position position = await _getCurrentLocationWithPermission();
    return position.longitude.toString();
  }

  Future<Position> _getCurrentLocationWithPermission() async {
    // Verificar permissões
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente. Ative nas configurações do dispositivo.');
    }

    // Verificar se serviços de localização estão habilitados
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviços de localização estão desabilitados');
    }

    // Obter posição atual
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FazendaBloc, FazendaState>(
      listener: (context, state) async {
        ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context);
        GoRouter router = GoRouter.of(context);
        if (state.entity.id != null) {
          if (_nomeController.text.isEmpty) {
            _nomeController.text = state.entity.nome;
          }
          if (_localizacaoController.text.isEmpty) {
            _localizacaoController.text = state.entity.localizacao;
          }
          if (_hectaresController.text.isEmpty) {
            _hectaresController.text = state.entity.hectares.toString();
          }
          if (_tipoController.text.isEmpty) {
            _tipoController.text = state.entity.tipo.label;
          }

          if (_latitudeController.text.isEmpty) {
            _latitudeController.text = state.entity.latitude ?? await _getLatitude();
          }
          if (_longitudeController.text.isEmpty) {
            _longitudeController.text = state.entity.longitude ?? await _getLongitude();
          }
        }
        if (state.status == FazendaStatus.failure) {
          scaffoldMessengerState.showSnackBar(
            const SnackBar(content: Text("Falha ao atualizar dados")),
          );
        }
        if (state.status == FazendaStatus.updated) {
          router.pop<bool>(true);
        }
        if (state.status == FazendaStatus.created) {
          router.pop<bool>(true);
        }
      },
      builder: (context, state) {
        if (state.status == FazendaStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            shrinkWrap: true,
            children: [
              const SizedBox(height: 20),
              Text(
                "Fazenda",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.brown,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  label: Text(_nomeLabel),
                  hintText: _nomePlaceholder,
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (value) {
                  if (value == null) return _requiredField;
                  if (value.isEmpty) return _requiredField;
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _localizacaoController,
                decoration: InputDecoration(
                  label: Text(_localizacaoLabel),
                  hintText: _localizacaoPlaceholder,
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (value) {
                  if (value == null) return _requiredField;
                  if (value.isEmpty) return _requiredField;
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _hectaresController,
                decoration: InputDecoration(
                  label: Text(_hectaresLabel),
                  hintText: _hectaresPlaceholder,
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              ANSelectField(
                items: TipoFazenda.values
                    .map<SelectItem>(
                      (e) => SelectItem(label: e.label, value: e.name),
                    )
                    .toList(),
                onChanged: (vl) => context.read<FazendaBloc>().add(
                      UpdateLoadedFazendaEvent(
                        entity: state.entity.copyWith(tipo: () => TipoFazenda.fromString(vl!.value)),
                      ),
                    ),
                selectedItem: SelectItem(
                  label: state.entity.tipo.label,
                  value: state.entity.tipo.name,
                ),
                label: _tipoLabel,
                hint: _tipoPlaceholder,
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text(_ativaLabel),
                value: state.entity.ativa,
                onChanged: (value) {
                  if (state.entity.id != null) {
                    context.read<FazendaBloc>().add(
                          UpdateLoadedFazendaEvent(
                            entity: state.entity.copyWith(
                              ativa: () => value ?? false,
                            ),
                          ),
                        );
                  }
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  label: Text(_latitudeLabel),
                  hintText: _latitudePlaceholder,
                  suffix: IconButton(
                    onPressed: () async {
                      try {
                        Position position = await _getCurrentLocationWithPermission();
                        _latitudeController.text = position.latitude.toString();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Latitude obtida com sucesso'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao obter localização: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.mapLocationDot,
                      color: Colors.green,
                    ),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  label: Text(_longitudeLabel),
                  hintText: _longitudePlaceholder,
                  suffix: IconButton(
                    onPressed: () async {
                      try {
                        Position position = await _getCurrentLocationWithPermission();
                        _longitudeController.text = position.longitude.toString();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Longitude obtida com sucesso'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao obter localização: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.mapLocationDot,
                      color: Colors.green,
                    ),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUnfocus,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _sendForm, child: const Text("Salvar")),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
