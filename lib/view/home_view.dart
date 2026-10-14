import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/home_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../widgets/mensagem.dart';
import 'agendamentos_view.dart';
import 'barbeiros_view.dart';
import 'cortes_view.dart';
import 'inicio_view.dart';

/// Estrutura principal depois do login: barra superior, menu lateral e
/// barra de navegação inferior com as quatro áreas do app.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _titulos = ['OLD REECE', 'BARBEIROS', 'CORTES', 'MINHA AGENDA'];

  @override
  Widget build(BuildContext context) {
    final home = g<HomeController>();

    return ListenableBuilder(
      listenable: home,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(_titulos[home.aba]),
          actions: [
            IconButton(
              tooltip: 'Meu perfil',
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
            ),
          ],
        ),
        drawer: const _MenuLateral(),
        body: IndexedStack(
          index: home.aba,
          children: const [
            InicioView(),
            BarbeirosView(),
            CortesView(),
            AgendamentosView(),
          ],
        ),
        floatingActionButton: home.aba == HomeController.agenda
            ? FloatingActionButton.extended(
                backgroundColor: Cores.grove,
                foregroundColor: Cores.onGrove,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Cores.frame, width: 3),
                ),
                onPressed: () {
                  g<AgendamentoController>().iniciar();
                  Navigator.pushNamed(context, AppRoutes.agendar);
                },
                icon: const Icon(Icons.add),
                label: Text(
                  'AGENDAR',
                  style: Estilos.menu.copyWith(color: Cores.onGrove),
                ),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: home.aba,
          onDestinationSelected: home.irPara,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Barbeiros',
            ),
            NavigationDestination(
              icon: Icon(Icons.content_cut_outlined),
              selectedIcon: Icon(Icons.content_cut),
              label: 'Cortes',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Agenda',
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuLateral extends StatelessWidget {
  const _MenuLateral();

  Future<void> _sair(BuildContext context) async {
    Navigator.pop(context);
    final ok = await confirmar(
      context,
      titulo: 'Sair da conta?',
      mensagem: 'Vai precisar entrar de novo pra agendar.',
      rotuloConfirmar: 'Sair',
      perigo: true,
    );
    if (!ok || !context.mounted) return;
    g<AuthController>().sair();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = g<AuthController>();
    final home = g<HomeController>();

    void irPara(int aba) {
      Navigator.pop(context);
      home.irPara(aba);
    }

    return Drawer(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: auth,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(Espaco.s4),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Cores.line, width: 2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo.png', height: 96),
                    const SizedBox(height: Espaco.s3),
                    Text(
                      auth.usuario?.nome ?? '',
                      style: Estilos.subtitle.copyWith(color: Cores.ink),
                    ),
                    Text(auth.usuario?.email ?? '', style: Estilos.bodySm),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Início'),
                onTap: () => irPara(HomeController.inicio),
              ),
              ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Agendar horário'),
                onTap: () {
                  Navigator.pop(context);
                  g<AgendamentoController>().iniciar();
                  Navigator.pushNamed(context, AppRoutes.agendar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: const Text('Minha agenda'),
                onTap: () => irPara(HomeController.agenda),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Meu perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.perfil);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.sobre);
                },
              ),
              const Spacer(),
              const Divider(height: 2, thickness: 2),
              ListTile(
                leading: const Icon(Icons.logout, color: Cores.health),
                title: const Text(
                  'Sair',
                  style: TextStyle(color: Cores.health),
                ),
                onTap: () => _sair(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
