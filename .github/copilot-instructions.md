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
  - `repositories/`: contratos divididos em `local/` e `remote/` por feature
  - `services/`: coordenam repositories local e remote, verificam conectividade
- **Repositórios:**
  - Remote repositories retornam `Either<AgroNexusException, T>` (dartz package)
  - Local repositories têm métodos síncronos para CRUD e sincronização
  - Implementem métodos padrão: `list`, `getById`, `create`, `update`, `delete`
- **Serviços:**
  - Verificam conectividade com `InternetConnection().hasInternetAccess`
  - Priorizam dados remotos quando online, fallback para local quando offline
  - Coordenam sincronização entre repositories local e remote
- Use injeção de dependência com GetIt (`lib/config/inject_dependencies.dart`)

## 3. Consumo de API

- Use `dio` para requisições HTTP através de `HttpService` e `HttpServiceImpl`.
- Baseie estruturas de modelos nos endpoints definidos pela API backend.
- **Padrões de Repository Remote:**
  - Retornem `Either<AgroNexusException, T>` para tratamento de erros
  - Implementem métodos padrão: `list`, `getById`, `create`, `update`, `delete`
  - Usem paginação com `limit` e `offset` para listagens
  - Suportem busca com parâmetro `search` opcional
- **Tratamento de Erros:**
  - Use `AgroNexusException` para erros customizados
  - Implemente fallback para dados locais em caso de erro de rede
- Use `lib/config/api.dart` para centralizar URLs e endpoints.
- Para novos campos, atualize o modelo no `domain` e implemente nos repositories correspondentes.

## 4. Implementação Híbrida (API e Local)

### Estratégia de Dados Dual
- Implemente sempre duas fontes de dados: **API remota** e **armazenamento local**
- Use `shared_preferences` para dados simples (configurações, preferências do usuário)
- Use SQLite (via `sqflite`) para dados complexos e relacionais quando necessário
- Implemente sincronização offline-first: dados locais como fonte primária, sincronizando com API quando disponível

### Padrão Repository com Fontes Múltiplas
- Crie repositories que abstraiam a origem dos dados (local vs remota)
- Implemente cache inteligente: busque dados locais primeiro, depois da API
- Use `connectivity_plus` para detectar status de conexão
- Fallback automático para dados locais quando offline

### Gestão de Estado Offline/Online
- Estados devem refletir conectividade: `loading`, `loaded`, `offline`, `syncing`
- Implemente filas de sincronização para ações pendentes quando offline
- Use timestamps para resolver conflitos de sincronização
- Notifique o usuário sobre status de sincronização

### Estrutura de Implementação
```dart
// Repository abstrato
abstract class BaseRepository<T> {
  Future<Either<Failure, List<T>>> getLocal();
  Future<Either<Failure, List<T>>> getRemote();
  Future<Either<Failure, T>> syncData(T entity);
}

// Service para coordenar fontes
class DataSyncService {
  Future<void> syncAll();
  Stream<SyncStatus> get syncStatus;
}
```

### Boas Práticas
- Sempre implemente fallback local para funcionalidades críticas
- Cache inteligente com verificação de conectividade via `InternetConnection()`
- **Padrões de Repository Local:**
  - Métodos síncronos para performance: `saveEntity`, `saveEntities`, `getAllEntities`
  - Controle de sincronização: `getSynkedEntities`, `getNotSynkedEntities`
  - Métodos de limpeza: `deleteSynkedEntities`, `deleteAllEntities`
  - Parâmetro `isSynked` para controlar status de sincronização
- **Serviços de Coordenação:**
  - Verifiquem conectividade antes de decidir fonte de dados
  - Usem remote repository quando online, local quando offline
  - Retornem `ListBaseEntity<T>` para listagens consistentes
- Sincronização incremental para otimizar performance
- Feedback visual claro sobre status offline/online
- Trate conflitos de dados de forma consistente

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
Ao implementar uma nova feature (ex: `veterinario`), siga esta sequência:

#### 1. Camada Domain
- **Model**: `lib/domain/models/veterinario_entity.dart`
  - Estenda `BaseEntity`
  - Implemente `Equatable`
  - Use `copyWith` com `AgroNexusGetter<T>`
  - Métodos `toJson()` e `fromJson()`
  - Enums com `label` e `fromString()` se necessário

#### 2. Repositories
- **Remote**: `lib/domain/repositories/remote/veterinario/`
  - `veterinario_remote_repository.dart`: contrato abstrato
  - `veterinario_remote_repository_impl.dart`: implementação
  - Retorne `Either<AgroNexusException, T>`
  - Métodos: `list`, `getById`, `create`, `update`, `delete`
- **Local**: `lib/domain/repositories/local/veterinario/`
  - `veterinario_local_repository.dart`: contrato abstrato
  - `veterinario_local_repository_impl.dart`: implementação
  - Métodos síncronos com controle de `isSynked`

#### 3. Service
- **Service**: `lib/domain/services/veterinario_service.dart`
  - Injete both repositories (remote e local)
  - Verifique conectividade com `InternetConnection()`
  - Priorize remote quando online, fallback para local
  - Retorne `ListBaseEntity<T>` para listagens

#### 4. Injeção de Dependências
- **Registrar no GetIt**: `lib/config/inject_dependencies.dart`
  - Registre repositories (local e remote)
  - Registre service
  - Registre BLoC

#### 5. Camada Presentation
- **BLoC**: `lib/presentation/bloc/veterinario/`
  - `veterinario_bloc.dart`: lógica principal
  - `veterinario_events.dart`: eventos (Create, Update, Delete, List, etc.)
  - `veterinario_state.dart`: estado com status enum
  - Use `part of` e `part` para conectar arquivos
- **Páginas**: `lib/presentation/veterinario/`
  - Organize por funcionalidade
  - Use `InternalScaffold` como base
  - Implemente `BlocProvider` e `BlocListener`/`BlocBuilder`

#### 6. Navegação
- **Adicionar rotas**: `lib/config/routers/router.dart`
  - Defina rotas nomeadas
  - Configure navegação no `AnBottomAppBar` se necessário

### Padrões de Nomeação para Features
- Arquivos: `snake_case` (ex: `veterinario_entity.dart`)
- Classes: `PascalCase` (ex: `VeterinarioEntity`, `VeterinarioBloc`)
- Enums: `PascalCase` (ex: `StatusVeterinario`)
- Variáveis: `camelCase` (ex: `veterinarioData`)
- Pastas: `snake_case` (ex: `veterinario/`)

### Template de Service
```dart
class VeterinarioService {
  final VeterinarioRemoteRepository remoteRepository;
  final VeterinarioLocalRepository localRepository;

  VeterinarioService({
    required this.remoteRepository,
    required this.localRepository,
  });

  Future<ListBaseEntity<VeterinarioEntity>> listEntities({
    int limit = 20,
    int offset = 0,
    String? search,
  }) async {
    bool hasConnection = await InternetConnection().hasInternetAccess;
    if (hasConnection) {
      final data = await remoteRepository.list(
        limit: limit, offset: offset, search: search);
      return data.getOrElse(() => throw Exception());
    } else {
      final List<VeterinarioEntity> data = await localRepository.getAllEntities();
      return ListBaseEntity<VeterinarioEntity>.empty().copyWith(results: () => data);
    }
  }
}
```

## 9. Commits e Branches

- Siga Conventional Commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`.
- Use branches temáticas: `feature/`, `fix/`, `hotfix/`.

## 10. Documentação
- Não crie documentação extensa no código; mantenha comentários claros e concisos.
- O copilot não precisa criar .md de instruções do que ele implementa ou de como ele funciona, pois sera documentada no README.md do projeto, faça modificações no README.md para documentar o que foi implementado, só quando for pedido.
- Faça alteração no README apenas quando for pedido.
