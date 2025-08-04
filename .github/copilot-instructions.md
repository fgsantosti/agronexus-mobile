# Instruções Personalizadas para GitHub Copilot – AgroNexus Mobile

Este arquivo fornece orientações e boas práticas para gerar ou modificar código no projeto Flutter `agronexus-mobile`.

## 1. Estrutura do Projeto

- Siga a organização de pastas existente:
  - `lib/main.dart`: ponto de entrada da aplicação.
  - `lib/config/`: configurações globais, temas, APIs, injeção de dependências e utilitários.
    - `lib/config/routers/`: configuração de roteamento com GoRouter.
    - `lib/config/services/`: serviços HTTP e implementações.
    - `lib/config/theme/`: configurações de tema da aplicação.
  - `lib/domain/`: camada de domínio seguindo Clean Architecture.
    - `lib/domain/models/`: entidades de dados que estendem BaseEntity.
    - `lib/domain/repositories/`: contratos de repositórios divididos em `local/` e `remote/`.
    - `lib/domain/services/`: serviços que coordenam repositories local e remote.
  - `lib/presentation/`: camada de apresentação com BLoC pattern.
    - `lib/presentation/bloc/`: BLoCs organizados por feature em subpastas.
    - `lib/presentation/cubit/`: Cubits para estados simples.
    - `lib/presentation/widgets/`: widgets reutilizáveis.
    - Páginas organizadas por feature (ex: `fazenda/`, `reproducao/`, etc.).
- Utilize componentes reutilizáveis e mantenha consistência visual.
- Evite duplicação de código; crie widgets e métodos reutilizáveis.


## 2. Padrões de Código

### Convenções de Nomenclatura
- Classes: `PascalCase` (ex: `AnimalEntity`, `ReproducaoEntity`)
- Arquivos: `snake_case` (ex: `animal_entity.dart`, `reproducao_cubit.dart`)
- Variáveis e métodos: `camelCase` (ex: `createdAt`, `getUserData`)
- Constantes: `SCREAMING_SNAKE_CASE` ou `camelCase` para valores finais

### Estrutura de Classes
- Use Flutter com Null Safety em todas as classes e métodos
- **Modelos de Dados:**
  - Herde de `BaseEntity` para modelos que representam dados da API
  - Implemente `Equatable` para comparação de objetos
  - Use `copyWith` com `AgroNexusGetter<T>` para criar versões modificadas de objetos imutáveis
  - Prefira classes imutáveis (`final` fields) para modelos
  - Implemente `toJson()` e `fromJson()` seguindo o padrão snake_case para API
- **Enums:**
  - Use enums com `label` para valores displayáveis
  - Implemente método `fromString()` para conversão de strings
  - Siga padrão: `enum Status { ativo(label: 'Ativo'), inativo(label: 'Inativo'); }`

### Formatação e Qualidade
- Formate o código com `dart format .` antes de commitar
- Execute `flutter analyze` para validar regras de lint
- Use `super.key` para widgets que estendem StatelessWidget/StatefulWidget
- Sempre declare tipos explícitos quando possível

### Gerenciamento de Estado
- Use BLoC/Cubit para gerenciamento de estado complexo
- **Estrutura de BLoC:**
  - Organize BLoCs em `lib/presentation/bloc/<feature>/` por feature
  - Arquivos separados: `<feature>_bloc.dart`, `<feature>_events.dart`, `<feature>_state.dart`
  - Use `part of` e `part` para conectar arquivos
- **Estados:**
  - Estados devem ser classes imutáveis que estendem `Equatable`
  - Use enums para status: `initial`, `loading`, `success`, `failure`, `created`, `updated`
  - Use `copyWith` com `AgroNexusGetter<T>` para atualizações de estado
  - Inclua propriedades como: `entities`, `entity`, `errorMessage`, `limit`, `offset`, `count`, `search`
- **Eventos:**
  - Crie eventos específicos: `Create`, `Update`, `Delete`, `List`, `NextPage`, `Detail`
  - Use sealed classes ou abstract classes para eventos base

### Arquitetura
- Siga Clean Architecture: `domain/` (entities, repositories, services) -> `presentation/` (UI, state)
- **Camada Domain:**
  - `models/`: entidades que estendem `BaseEntity`
  - `repositories/remote/`: contratos e implementações para comunicação com API
  - `services/`: coordenam repositories remote, atuam como passthrough
- **Repositórios:**
  - Remote repositories **não retornam** `Either<AgroNexusException, T>`
  - Retornam diretamente os tipos (`List<T>`, `T`, `void`)
  - Use `AgroNexusException.fromDioError()` em blocos try-catch
  - Implementem métodos específicos da feature conforme necessário
- **Serviços:**
  - **Não verificam** conectividade
  - Atuam como passthrough para repositories remote
  - Retornam tipos diretamente sem wrapping em `ListBaseEntity<T>`
- Use injeção de dependência com GetIt (`lib/config/inject_dependencies.dart`)

## 3. Consumo de API

- Use `dio` para requisições HTTP através de `HttpService` e `HttpServiceImpl`.
- Baseie estruturas de modelos nos endpoints definidos pela API backend.
- **Padrões de Repository Remote:**
  - **Não retornem** `Either<AgroNexusException, T>` - retorne diretamente os tipos
  - Use `AgroNexusException.fromDioError()` em blocos try-catch para tratamento de erros
  - Implementem métodos específicos da feature conforme necessário
  - Usem query parameters para filtros (ex: `animalId`, `dataInicio`, `dataFim`)
- **Tratamento de Erros:**
  - Use `AgroNexusException.fromDioError()` para converter erros do Dio
  - Propague exceções para serem tratadas nos BLoCs
  - Implemente feedback visual adequado nas telas
- Use `lib/config/api.dart` para centralizar URLs e endpoints.
- Para novos campos, atualize o modelo no `domain` e implemente nos repositories correspondentes.

## 4. Estratégia de Cache e Estado

### Cache Local no Estado dos Widgets
- **Não implemente** repositories locais ou armazenamento local persistente
- **Use** cache apenas no estado dos widgets para preservar dados durante navegação
- **Implemente** variáveis de cache como `List<T>? _cachedData` nos StatefulWidgets
- **Preserve** dados durante mudanças de estado do BLoC para melhor UX

### Padrão de Cache em Widgets
```dart
class _FeatureScreenState extends State<FeatureScreen> {
  List<EntityType>? _cachedEntities; // Cache local dos dados

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<FeatureBloc>().add(LoadDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeatureBloc, FeatureState>(
      listener: (context, state) {
        // Atualizar cache quando dados são carregados
        if (state is DataLoaded) {
          _cachedEntities = state.entities;
        }
        
        // Recarregar dados após operações CRUD
        if (state is EntityCreated || state is EntityUpdated || state is EntityDeleted) {
          _loadData();
        }
      },
      child: BlocBuilder<FeatureBloc, FeatureState>(
        builder: (context, state) {
          // Mostrar loading apenas se não há cache
          if (state is FeatureLoading && _cachedEntities == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Usar dados do cache ou lista vazia
          final entities = _cachedEntities ?? [];
          
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(/* ... */),
          );
        },
      ),
    );
  }
}
```

### Gerenciamento de Estado com Cache
- **Preserve** dados durante estados de loading para evitar telas em branco
- **Recarregue** dados automaticamente após operações CRUD
- **Use** `RefreshIndicator` para atualização manual
- **Implemente** feedback visual adequado (SnackBar, CircularProgressIndicator)

### Ciclo de Vida e Recarregamento
```dart
class _ScreenState extends State<Screen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recarregar quando app volta para foreground
    if (state == AppLifecycleState.resumed) {
      _reloadDataIfNeeded();
    }
  }
}
```

### Boas Práticas de Cache
- **Não persista** dados além do ciclo de vida do widget
- **Use** cache apenas para melhorar UX durante navegação
- **Recarregue** dados sempre que necessário para manter atualização
- **Implemente** tratamento de erro adequado quando API falha

## 5. Widgets e UI

### Design System
- Utilize Material Design 3 como base
- Siga o tema definido em `lib/config/theme/theme.dart`
- Use Google Fonts conforme configuração do projeto
- Mantenha consistência visual entre telas

### Estrutura de Widgets
- Crie widgets pequenos e focados (Single Responsibility Principle)
- Separe widgets reutilizáveis em `lib/presentation/widgets/`
- **Widgets Padrão do Projeto:**
  - `InternalScaffold`: scaffold padrão com AppBar e BottomAppBar
  - `AnBottomAppBar`: barra inferior personalizada com navegação
  - `PasswordTextField`: campo de senha com toggle de visibilidade
  - `SelectField`: campo de seleção customizado
- Use `const` constructors sempre que possível para otimização
- Prefira StatelessWidget quando o estado não for necessário
- Use `BlocListener` para reações a mudanças de estado (navegação, mensagens)
- Use `BlocBuilder` para construção reativa da UI

### Navegação
- Use GoRouter para navegação (configurado em `lib/config/routers/router.dart`)
- Defina rotas nomeadas para facilitar manutenção
- Use context.go() ou context.push() para navegação

### Formulários e Validação
- Use `mask_text_input_formatter` para máscaras de entrada
- Implemente validação de campos de forma consistente
- Use `date_field` para seleção de datas

### Responsividade
- Considere diferentes tamanhos de tela
- Use MediaQuery para adaptar layouts
- Teste em dispositivos Android e iOS

## 6. Dependências e Packages

### Packages Principais Utilizados
- **Estado**: `flutter_bloc`, `bloc` para gerenciamento de estado
- **Navegação**: `go_router` para roteamento
- **HTTP**: `dio` para requisições API
- **Injeção de Dependência**: `get_it` 
- **Utilidades**: `equatable`, `dartz`, `shared_preferences`
- **UI**: `google_fonts`, `font_awesome_flutter`, `flutter_animate`
- **Formulários**: `mask_text_input_formatter`, `date_field`
- **Funcionalidades**: `geolocator`, `image_picker`, `url_launcher`
- **Conectividade**: `internet_connection_checker_plus` para verificação de rede
- **Formatação**: `intl` para formatação de datas e internacionalização

### Adição de Dependências
- Adicione novos packages em `pubspec.yaml` na seção adequada
- Execute `flutter pub get` após adicionar dependências
- Para packages de desenvolvimento, use `dev_dependencies`
- Mantenha versões específicas para estabilidade
- Documente o propósito de novas dependências

## 7. Testes
- Não crie testes unitários em `test/` para modelos e serviços.

## 8. Implementação de Novas Features

### Checklist para Nova Feature
Ao implementar uma nova feature (ex: `veterinario`), siga esta sequência baseada no padrão implementado em **reprodução**:

#### 1. Camada Domain
- **Model**: `lib/domain/models/veterinario_entity.dart`
  - Estenda `BaseEntity`
  - Implemente `Equatable`
  - Use `copyWith` com `AgroNexusGetter<T>`
  - Métodos `toJson()` e `fromJson()` seguindo snake_case para API
  - Enums com `label`, `value` e `fromString()` se necessário

#### 2. Repositories
- **Remote**: `lib/domain/repositories/remote/veterinario/`
  - `veterinario_remote_repository.dart`: contrato abstrato com métodos específicos
  - `veterinario_repository_remote_impl.dart`: implementação com `HttpService`
  - **Não use** `Either<AgroNexusException, T>` - retorne diretamente os tipos
  - Use `AgroNexusException.fromDioError()` em blocos try-catch
  - Métodos padrão: métodos específicos da feature conforme necessário

#### 3. Service
- **Service**: `lib/domain/services/veterinario_service.dart`
  - Injete apenas o remote repository
  - **Não implemente** verificação de conectividade
  - Service atua como passthrough para o repository
  - Retorne os tipos diretamente sem `ListBaseEntity<T>`

#### 4. Injeção de Dependências
- **Registrar no GetIt**: `lib/config/inject_dependencies.dart`
  - Registre repository remote
  - Registre service
  - Registre BLoC

#### 5. Camada Presentation
- **BLoC**: `lib/presentation/bloc/veterinario/`
  - `veterinario_bloc.dart`: lógica principal com handlers para cada evento
  - `veterinario_event.dart`: eventos específicos estendendo classe base abstrata
  - `veterinario_state.dart`: estados específicos estendendo classe base abstrata
  - **Não use** `part of` e `part`
- **Páginas**: `lib/presentation/veterinario/`
  - Organize por funcionalidade específica
  - Use `Scaffold` como base
  - Implemente `BlocProvider`, `BlocListener` e `BlocBuilder`
  - Use `RefreshIndicator` para pull-to-refresh
  - Implemente cache local de dados no estado do widget

#### 6. Navegação
- **Adicionar rotas**: `lib/config/routers/router.dart`
  - Defina rotas nomeadas
  - Configure navegação conforme necessário

### Padrões de Nomeação para Features
- Arquivos: `snake_case` (ex: `veterinario_entity.dart`, `veterinario_repository_remote_impl.dart`)
- Classes: `PascalCase` (ex: `VeterinarioEntity`, `VeterinarioBloc`)
- Enums: `PascalCase` com `label` e `value` (ex: `StatusVeterinario`)
- Variáveis: `camelCase` (ex: `veterinarioData`)
- Pastas: `snake_case` (ex: `veterinario/`)

### Templates de Implementação

#### Template de Entity
```dart
import 'package:agronexus/domain/models/base_entity.dart';
import 'package:agronexus/config/utils.dart';

enum StatusVeterinario {
  ativo(label: 'Ativo', value: 'ativo'),
  inativo(label: 'Inativo', value: 'inativo');

  final String label;
  final String value;
  const StatusVeterinario({required this.label, required this.value});

  static StatusVeterinario fromString(String value) {
    switch (value) {
      case 'ativo':
        return StatusVeterinario.ativo;
      case 'inativo':
        return StatusVeterinario.inativo;
      default:
        throw Exception('Invalid StatusVeterinario value: $value');
    }
  }
}

class VeterinarioEntity extends BaseEntity {
  final String nome;
  final String? crmv;
  final StatusVeterinario status;

  const VeterinarioEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.nome,
    this.crmv,
    required this.status,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        nome,
        crmv,
        status,
      ];

  VeterinarioEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? nome,
    AgroNexusGetter<String?>? crmv,
    AgroNexusGetter<StatusVeterinario>? status,
  }) {
    return VeterinarioEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      nome: nome != null ? nome() : this.nome,
      crmv: crmv != null ? crmv() : this.crmv,
      status: status != null ? status() : this.status,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'nome': nome,
      'crmv': crmv,
      'status': status.value,
    });
    return data;
  }

  VeterinarioEntity.fromJson(Map<String, dynamic> json)
      : nome = json['nome'] ?? '',
        crmv = json['crmv'],
        status = StatusVeterinario.fromString(json['status'] ?? 'ativo'),
        super.fromJson(json);
}
```

#### Template de Repository Remote
```dart
abstract class VeterinarioRepository {
  Future<List<VeterinarioEntity>> getVeterinarios();
  Future<VeterinarioEntity> getVeterinario(String id);
  Future<VeterinarioEntity> createVeterinario(VeterinarioEntity veterinario);
  Future<VeterinarioEntity> updateVeterinario(String id, VeterinarioEntity veterinario);
  Future<void> deleteVeterinario(String id);
}
```

#### Template de Repository Implementation
```dart
import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/domain/models/veterinario_entity.dart';
import 'package:agronexus/domain/repositories/remote/veterinario/veterinario_remote_repository.dart';
import 'package:dio/dio.dart';
import 'package:agronexus/config/api.dart';

class VeterinarioRepositoryImpl implements VeterinarioRepository {
  final HttpService httpService;

  VeterinarioRepositoryImpl({required this.httpService});

  @override
  Future<List<VeterinarioEntity>> getVeterinarios() async {
    try {
      Response response = await httpService.get(
        path: API.veterinarios,
        isAuth: true,
      );
      List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => VeterinarioEntity.fromJson(json)).toList();
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  @override
  Future<VeterinarioEntity> getVeterinario(String id) async {
    try {
      Response response = await httpService.get(
        path: API.veterinarioById(id),
        isAuth: true,
      );
      return VeterinarioEntity.fromJson(response.data);
    } catch (e) {
      throw await AgroNexusException.fromDioError(e);
    }
  }

  // Implementar outros métodos seguindo o mesmo padrão...
}
```

#### Template de Service
```dart
import 'package:agronexus/domain/models/veterinario_entity.dart';
import 'package:agronexus/domain/repositories/remote/veterinario/veterinario_remote_repository.dart';

class VeterinarioService {
  final VeterinarioRepository _repository;

  VeterinarioService(this._repository);

  Future<List<VeterinarioEntity>> getVeterinarios() async {
    return await _repository.getVeterinarios();
  }

  Future<VeterinarioEntity> getVeterinario(String id) async {
    return await _repository.getVeterinario(id);
  }

  Future<VeterinarioEntity> createVeterinario(VeterinarioEntity veterinario) async {
    return await _repository.createVeterinario(veterinario);
  }

  // Implementar outros métodos como passthrough...
}
```

#### Template de BLoC Events
```dart
import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/veterinario_entity.dart';

abstract class VeterinarioEvent extends Equatable {
  const VeterinarioEvent();

  @override
  List<Object?> get props => [];
}

class LoadVeterinariosEvent extends VeterinarioEvent {
  const LoadVeterinariosEvent();
}

class CreateVeterinarioEvent extends VeterinarioEvent {
  final VeterinarioEntity veterinario;

  const CreateVeterinarioEvent(this.veterinario);

  @override
  List<Object> get props => [veterinario];
}

class UpdateVeterinarioEvent extends VeterinarioEvent {
  final String id;
  final VeterinarioEntity veterinario;

  const UpdateVeterinarioEvent(this.id, this.veterinario);

  @override
  List<Object> get props => [id, veterinario];
}

class DeleteVeterinarioEvent extends VeterinarioEvent {
  final String id;

  const DeleteVeterinarioEvent(this.id);

  @override
  List<Object> get props => [id];
}
```

#### Template de BLoC States
```dart
import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/veterinario_entity.dart';

abstract class VeterinarioState extends Equatable {
  const VeterinarioState();

  @override
  List<Object?> get props => [];
}

class VeterinarioInitial extends VeterinarioState {}

class VeterinarioLoading extends VeterinarioState {}

class VeterinariosLoaded extends VeterinarioState {
  final List<VeterinarioEntity> veterinarios;

  const VeterinariosLoaded(this.veterinarios);

  @override
  List<Object> get props => [veterinarios];
}

class VeterinarioCreated extends VeterinarioState {
  final VeterinarioEntity veterinario;

  const VeterinarioCreated(this.veterinario);

  @override
  List<Object> get props => [veterinario];
}

class VeterinarioUpdated extends VeterinarioState {
  final VeterinarioEntity veterinario;

  const VeterinarioUpdated(this.veterinario);

  @override
  List<Object> get props => [veterinario];
}

class VeterinarioDeleted extends VeterinarioState {
  final String id;

  const VeterinarioDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class VeterinarioError extends VeterinarioState {
  final String message;

  const VeterinarioError(this.message);

  @override
  List<Object> get props => [message];
}
```

#### Template de BLoC Principal
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/domain/services/veterinario_service.dart';
import 'package:agronexus/presentation/bloc/veterinario/veterinario_event.dart';
import 'package:agronexus/presentation/bloc/veterinario/veterinario_state.dart';

class VeterinarioBloc extends Bloc<VeterinarioEvent, VeterinarioState> {
  final VeterinarioService _service;

  VeterinarioBloc(this._service) : super(VeterinarioInitial()) {
    on<LoadVeterinariosEvent>(_onLoadVeterinarios);
    on<CreateVeterinarioEvent>(_onCreateVeterinario);
    on<UpdateVeterinarioEvent>(_onUpdateVeterinario);
    on<DeleteVeterinarioEvent>(_onDeleteVeterinario);
  }

  Future<void> _onLoadVeterinarios(LoadVeterinariosEvent event, Emitter<VeterinarioState> emit) async {
    emit(VeterinarioLoading());
    try {
      final veterinarios = await _service.getVeterinarios();
      emit(VeterinariosLoaded(veterinarios));
    } catch (e) {
      emit(VeterinarioError(e.toString()));
    }
  }

  Future<void> _onCreateVeterinario(CreateVeterinarioEvent event, Emitter<VeterinarioState> emit) async {
    emit(VeterinarioLoading());
    try {
      final veterinario = await _service.createVeterinario(event.veterinario);
      emit(VeterinarioCreated(veterinario));
    } catch (e) {
      emit(VeterinarioError(e.toString()));
    }
  }

  // Implementar outros handlers seguindo o mesmo padrão...
}
```

### Padrões de UI

#### Template de Tela de Listagem
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/veterinario/veterinario_bloc.dart';
import 'package:agronexus/presentation/bloc/veterinario/veterinario_event.dart';
import 'package:agronexus/presentation/bloc/veterinario/veterinario_state.dart';
import 'package:agronexus/domain/models/veterinario_entity.dart';

class VeterinarioScreen extends StatefulWidget {
  const VeterinarioScreen({super.key});

  @override
  State<VeterinarioScreen> createState() => _VeterinarioScreenState();
}

class _VeterinarioScreenState extends State<VeterinarioScreen> {
  List<VeterinarioEntity>? _cachedVeterinarios;

  @override
  void initState() {
    super.initState();
    _loadVeterinarios();
  }

  void _loadVeterinarios() {
    context.read<VeterinarioBloc>().add(const LoadVeterinariosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Veterinários')),
      body: RefreshIndicator(
        onRefresh: () async => _loadVeterinarios(),
        child: BlocListener<VeterinarioBloc, VeterinarioState>(
          listener: (context, state) {
            if (state is VeterinariosLoaded) {
              _cachedVeterinarios = state.veterinarios;
            }
            // Implementar outros listeners conforme necessário...
          },
          child: BlocBuilder<VeterinarioBloc, VeterinarioState>(
            builder: (context, state) {
              if (state is VeterinarioLoading && _cachedVeterinarios == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final veterinarios = _cachedVeterinarios ?? [];

              if (veterinarios.isEmpty) {
                return const Center(child: Text('Nenhum veterinário encontrado'));
              }

              return ListView.builder(
                itemCount: veterinarios.length,
                itemBuilder: (context, index) {
                  final veterinario = veterinarios[index];
                  return ListTile(
                    title: Text(veterinario.nome),
                    subtitle: Text(veterinario.crmv ?? 'CRMV não informado'),
                    trailing: Text(veterinario.status.label),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para tela de cadastro
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Observações Importantes
- **Não implemente** repositories locais nem verificação de conectividade
- **Use** cache local apenas no estado dos widgets para preservar dados durante navegação
- **Sempre** implemente `RefreshIndicator` para atualização manual
- **Use** try-catch com `AgroNexusException.fromDioError()` nos repositories
- **Mantenha** states específicos para cada ação (Loading, Loaded, Created, Updated, etc.)

### Padrões de Implementação de Telas Complexas

#### Estrutura de Telas com Múltiplas Funcionalidades (Baseado em Reprodução)

**Tela Principal com Abas (ex: ManejoReprodutivoScreen)**
```dart
class ManejoReprodutivoScreen extends StatefulWidget {
  const ManejoReprodutivoScreen({super.key});

  @override
  State<ManejoReprodutivoScreen> createState() => _ManejoReprodutivoScreenState();
}

class _ManejoReprodutivoScreenState extends State<ManejoReprodutivoScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  Map<String, dynamic>? _resumoData; // Cache local de dados

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    
    // Carregar dados apenas se cache não existe
    if (_resumoData == null) {
      context.read<ReproducaoBloc>().add(LoadResumoReproducaoEvent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recarregar quando app volta para foreground
    if (state == AppLifecycleState.resumed) {
      _recarregarDadosSeNecessario();
    }
  }
}
```

**Tela de Listagem com Cache (ex: InseminacaoScreen)**
```dart
class InseminacaoScreen extends StatefulWidget {
  const InseminacaoScreen({super.key});

  @override
  State<InseminacaoScreen> createState() => _InseminacaoScreenState();
}

class _InseminacaoScreenState extends State<InseminacaoScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isInitialized = false;
  List<InseminacaoEntity>? _cachedInseminacoes; // Cache local

  @override
  void initState() {
    super.initState();
    _loadInseminacoes();
  }

  void _loadInseminacoes() {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month - 3, 1);
    context.read<ReproducaoBloc>().add(
      LoadInseminacoesEvent(dataInicio: inicio, dataFim: now),
    );
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadInseminacoes(),
        child: BlocListener<ReproducaoBloc, ReproducaoState>(
          listener: (context, state) {
            // Preservar cache durante mudanças de estado
            if (state is InseminacoesLoaded) {
              _cachedInseminacoes = state.inseminacoes;
            }
            
            if (state is InseminacaoCreated || state is InseminacaoUpdated || state is InseminacaoDeleted) {
              _loadInseminacoes(); // Recarregar lista após operações CRUD
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Operação realizada com sucesso!')),
              );
            }
            
            if (state is ReproducaoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
            builder: (context, state) {
              if (state is InseminacoesLoading && _cachedInseminacoes == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final inseminacoes = _cachedInseminacoes ?? [];
              
              if (inseminacoes.isEmpty) {
                return const Center(child: Text('Nenhuma inseminação encontrada'));
              }

              return ListView.builder(
                itemCount: inseminacoes.length,
                itemBuilder: (context, index) {
                  final inseminacao = inseminacoes[index];
                  return Card(
                    child: ListTile(
                      title: Text(inseminacao.animal?.identificacao ?? 'Animal não identificado'),
                      subtitle: Text(_dateFormat.format(DateTime.parse(inseminacao.dataInseminacao))),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('Editar'),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => EditarInseminacaoScreen(inseminacao: inseminacao),
                              ));
                            },
                          ),
                          PopupMenuItem(
                            child: Text('Excluir'),
                            onTap: () => _confirmarExclusao(inseminacao.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const CadastroInseminacaoScreen(),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Tela de Formulário (ex: CadastroInseminacaoScreen)**
```dart
class CadastroInseminacaoScreen extends StatefulWidget {
  const CadastroInseminacaoScreen({super.key});

  @override
  State<CadastroInseminacaoScreen> createState() => _CadastroInseminacaoScreenState();
}

class _CadastroInseminacaoScreenState extends State<CadastroInseminacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Controllers para campos de texto
  final _dataInseminacaoController = TextEditingController();
  final _semenUtilizadoController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Campos selecionados
  AnimalEntity? _animalSelecionado;
  AnimalEntity? _reprodutorSelecionado;
  TipoInseminacao? _tipoSelecionado;
  
  // Opções disponíveis (carregadas da API)
  OpcoesCadastroInseminacao? _opcoes;

  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataInseminacaoController.text = _dateFormat.format(_dataSelecionada);
    _carregarOpcoes();
  }

  void _carregarOpcoes() {
    context.read<ReproducaoBloc>().add(LoadOpcoesCadastroInseminacaoEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Inseminação'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvar,
            child: _isLoading 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
          ),
        ],
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is OpcoesCadastroInseminacaoLoaded) {
            setState(() => _opcoes = state.opcoes);
          }
          
          if (state is InseminacaoCreated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inseminação cadastrada com sucesso!')),
            );
          }
          
          if (state is ReproducaoError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Campo de seleção de animal
                AnimalSearchField(
                  labelText: 'Selecionar Animal *',
                  onAnimalSelected: (animal) => setState(() => _animalSelecionado = animal),
                  validator: (value) => _animalSelecionado == null ? 'Selecione um animal' : null,
                ),
                
                const SizedBox(height: 16),
                
                // Campo de data
                TextFormField(
                  controller: _dataInseminacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Data da Inseminação *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selecionarData,
                  validator: (value) => value?.isEmpty == true ? 'Selecione a data' : null,
                ),
                
                // Outros campos do formulário...
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final inseminacao = InseminacaoEntity(
      animal: _animalSelecionado,
      dataInseminacao: _dataSelecionada.toIso8601String(),
      tipo: _tipoSelecionado!,
      // outros campos...
    );
    
    context.read<ReproducaoBloc>().add(CreateInseminacaoEvent(inseminacao));
  }
}
```

### Padrões de Navegação e Fluxo
- **Use** `Navigator.push` para telas de CRUD individual
- **Implemente** `AppLifecycleState` para recarregar dados quando app volta ao foreground
- **Preserve** dados em cache local durante mudanças de estado
- **Valide** formulários antes de enviar dados
- **Mostre** feedback visual (SnackBar) para operações CRUD
- **Use** `RefreshIndicator` em todas as listas para pull-to-refresh

## 9. Commits e Branches

- Siga Conventional Commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`.
- Use branches temáticas: `feature/`, `fix/`, `hotfix/`.

## 10. Documentação
- Não crie documentação extensa no código; mantenha comentários claros e concisos.
- O copilot não precisa criar .md de instruções do que ele implementa ou de como ele funciona, pois sera documentada no README.md do projeto, faça modificações no README.md para documentar o que foi implementado, só quando for pedido.
- Faça alteração no README apenas quando for pedido.
