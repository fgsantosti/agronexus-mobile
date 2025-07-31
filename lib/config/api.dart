class API {
  static const String baseUrl = 'http://localhost:8000/';

  // AUTH
  static const String login = 'api/auth/login/';
  static const String refresh = 'api/auth/refresh/';
  static const String logout = 'api/auth/logout/';

  static const String animais = 'api/v1/animais/';
  static String animalById(String id) => 'api/v1/animais/$id/';

  // Dashboard não existe no servidor - comentado temporariamente
  // static const String dashboard = 'api/v1/dashboard/';

  // Fazendas não existe no servidor - usando propriedades ao invés
  // static const String fazendas = 'api/v1/fazendas/';
  // static String fazendasById(String id) => 'api/v1/fazendas/$id/';

  static const String lotes = 'api/v1/lotes/';
  static String lotesById(String id) => 'api/v1/lotes/$id/';

  static const String notification = 'api/v1/notifications/';
  static const String notificationDeleteAll = 'api/v1/notifications/delete-all/';
  static const String notificationMarkAllAsRead =
      'api/v1/notifications/mark-all-as-read/';
  static const String notificationMarkAllAsUnread =
      'api/v1/notifications/mark-all-as-unread/';
  static const String notificationUnreadCount = 'api/v1/notifications/unread-count/';
  static String notificationById(String id) => 'api/v1/notifications/$id/';
  static String notificationMarkAsRead(String id) =>
      'api/v1/notifications/$id/mark-as-read/';
  static String notificationMarkAsUnread(String id) =>
      'api/v1/notifications/$id/mark-as-unread/';

  static const String propriedades = 'api/v1/propriedades/';
  static String propriedadeById(String id) => 'api/v1/propriedades/$id/';

  static const String usuarios = 'api/v1/usuarios/';
  static String usuarioById(String id) => 'api/v1/usuarios/$id/';
  static const String usuariosMe = 'api/v1/usuarios/me/';
  static const String usuariosPassword = 'api/v1/usuarios/password/';
  static const String usuariosPasswordReset = 'api/v1/usuarios/password-reset/';
  static const String usuariosPasswordResetConfirm =
      'api/v1/usuarios/password-reset-confirm/';
}
