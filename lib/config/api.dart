class API {
  // Para dispositivos físicos (USB debugging), use o IP da sua máquina local
  //static const String baseUrl = 'http://10.0.0.118:8000/'; // Dispositivo físico via USB
  //static const String baseUrl = 'http://10.0.2.2:8000/'; //Android Emulator
  // static const String baseUrl = 'http://localhost:8000/'; // Localhost
  // static const String baseUrl = 'http://your-ip-address:8000/'; // Localhost
  // static const String baseUrl = 'https://api.example.com/'; // Production URL
  static const String baseUrl = 'https://agronexus.app/';

  // AUTH
  static const String login = 'api/auth/login/';
  static const String registro = 'api/auth/registro/';
  static const String refresh = 'api/auth/refresh/';
  static const String logout = 'api/auth/logout/';

  static const String animais = 'api/v1/animais/';
  static String animalById(String id) => 'api/v1/animais/$id/';
  static const String animaisTemplateImportacao = 'api/v1/animais/template_importacao/';

  // Espécies e Raças
  static const String especies = 'api/v1/especies/';
  static String especieById(String id) => 'api/v1/especies/$id/';
  static const String racas = 'api/v1/racas/';
  static String racaById(String id) => 'api/v1/racas/$id/';

  // Dashboard não existe no servidor - comentado temporariamente
  // static const String dashboard = 'api/v1/dashboard/';

  // Fazendas não existe no servidor - usando propriedades ao invés
  // static const String fazendas = 'api/v1/fazendas/';
  // static String fazendasById(String id) => 'api/v1/fazendas/$id/';

  static const String lotes = 'api/v1/lotes/';
  static String lotesById(String id) => 'api/v1/lotes/$id/';

  static const String notification = 'api/v1/notifications/';
  static const String notificationDeleteAll = 'api/v1/notifications/delete-all/';
  static const String notificationMarkAllAsRead = 'api/v1/notifications/mark-all-as-read/';
  static const String notificationMarkAllAsUnread = 'api/v1/notifications/mark-all-as-unread/';
  static const String notificationUnreadCount = 'api/v1/notifications/unread-count/';
  static String notificationById(String id) => 'api/v1/notifications/$id/';
  static String notificationMarkAsRead(String id) => 'api/v1/notifications/$id/mark-as-read/';
  static String notificationMarkAsUnread(String id) => 'api/v1/notifications/$id/mark-as-unread/';

  static const String propriedades = 'api/v1/propriedades/';
  static String propriedadeById(String id) => 'api/v1/propriedades/$id/';

  static const String usuarios = 'api/v1/usuarios/';
  static String usuarioById(String id) => 'api/v1/usuarios/$id/';
  static const String usuariosMe = 'api/v1/usuarios/me/';
  static const String usuariosPassword = 'api/v1/usuarios/password/';
  static const String usuariosPasswordReset = 'api/v1/usuarios/password-reset/';
  static const String usuariosPasswordResetConfirm = 'api/v1/usuarios/password-reset-confirm/';

  // Reproduções
  static const String inseminacoes = 'api/v1/inseminacoes/';
  static String inseminacaoById(String id) => 'api/v1/inseminacoes/$id/';
  static const String diagnosticosGestacao = 'api/v1/diagnosticos-gestacao/';
  static String diagnosticoGestacaoById(String id) => 'api/v1/diagnosticos-gestacao/$id/';
  static const String partos = 'api/v1/partos/';
  static String partoById(String id) => 'api/v1/partos/$id/';
  static const String estacoesMonta = 'api/v1/estacoes-monta/';
  static String estacaoMontaById(String id) => 'api/v1/estacoes-monta/$id/';
  static const String protocolosIATF = 'api/v1/protocolos-iatf/';
  static String protocoloIATFById(String id) => 'api/v1/protocolos-iatf/$id/';
  static const String inseminacoesOpcoes = 'api/v1/inseminacoes/opcoes_cadastro/';

  // Relatórios
  static const String relatoriosPrenhez = 'api/v1/relatorios/prenhez/';
  static const String estatisticasReproducao = 'api/v1/inseminacoes/estatisticas_reproducao/';
  static const String relatoriosEstatisticasReproducao = 'api/v1/relatorios/estatisticas-reproducao/';

  // ÁREAS
  static const String areas = 'api/v1/areas/';
  static String areaById(String id) => 'api/v1/areas/$id/';

  // ROTAS DE NAVEGAÇÃO
  // Auth Routes
  static const String loginRoute = '/login';
  static const String splashRoute = '/splash';

  // Main Routes
  static const String homeRoute = '/home';
  static const String perfilRoute = '/perfil';

  // Propriedades Routes
  static const String propriedadesRoute = '/propriedades';
  static String propriedadeDetailRoute(String id) => '/propriedades/detalhes/$id';
  static String propriedadeEditRoute(String id) => '/propriedades/editar/$id';
  static const String propriedadeCadastroRoute = '/propriedades/cadastro';

  // Lotes Routes
  static const String lotesRoute = '/lotes';
  static String loteDetailRoute(String id) => '/lotes/detalhes/$id';
  static String loteEditRoute(String id) => '/lotes/editar/$id';
  static const String loteCadastroRoute = '/lotes/cadastro';

  // Animais Routes
  static const String animaisRoute = '/animais';
  static String animalDetailRoute(String id) => '/animais/detalhes/$id';
  static String animalEditRoute(String id) => '/animais/editar/$id';
  static const String animalCadastroRoute = '/animais/cadastro';

  // Manejo Reprodutivo Routes
  static const String manejoReprodutivoRoute = '/manejo-reprodutivo';

  // Fazenda Routes
  static const String fazendaRoute = '/fazenda';
  static String fazendaDetailRoute(String id) => '/fazenda/detalhes/$id';
  static String fazendaEditRoute(String id) => '/fazenda/editar/$id';
  static const String fazendaCadastroRoute = '/fazenda/cadastro';
}
