part of 'bottom_bar_cubit.dart';

enum BottomBarItems {
  home(
    label: "Início",
    icon: FontAwesomeIcons.house,
    route: AgroNexusRouter.homePath,
  ),
  lotes(
    label: "Lotes",
    icon: FontAwesomeIcons.clone,
    route: AgroNexusRouter.lotesPath,
  ),
  animais(
    label: "Animais",
    icon: FontAwesomeIcons.cow,
    route: AgroNexusRouter.animaisPath,
  ),
  perfil(
    label: "Perfil",
    icon: FontAwesomeIcons.user,
    route: AgroNexusRouter.perfilPath,
  ),
  ;

  final String label;
  final IconData icon;
  final String route;
  const BottomBarItems({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class BottomBarState extends Equatable {
  final BottomBarItems item;

  const BottomBarState({required this.item});

  @override
  List<Object> get props => [item];
}
