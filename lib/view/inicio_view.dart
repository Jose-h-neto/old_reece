import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/barbeiro_controller.dart';
import '../controller/corte_controller.dart';
import '../controller/home_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/agendamento.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';
import '../widgets/texto_contorno.dart';

/// Funcionalidade: painel inicial no estilo HUD — saudação, barra de
/// respeito (fidelidade), próxima missão e atalhos.
class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = g<AuthController>();
    final agenda = g<AgendamentoController>();
    final home = g<HomeController>();

    return ListenableBuilder(
      listenable: Listenable.merge([auth, agenda]),
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(Espaco.s4),
        children: [
          TituloZona(
            'E aí, ${auth.primeiroNome}',
            subtitulo: 'Old Reece · Hair & Facial Studio',
          ),
          const SizedBox(height: Espaco.s4),
          Painel(
            child: Column(
              children: [
                BarraHud(
                  rotulo: 'Respeito',
                  rotuloValor:
                      '${agenda.respeito}/${AgendamentoController.metaRespeito}',
                  valor: agenda.respeito.toDouble(),
                  maximo: AgendamentoController.metaRespeito.toDouble(),
                ),
                const SizedBox(height: Espaco.s2),
                Text(
                  'Faltam ${AgendamentoController.metaRespeito - agenda.respeito} '
                  'cortes pro próximo por conta da casa.',
                  style: Estilos.bodySm,
                ),
              ],
            ),
          ),
          const SizedBox(height: Espaco.s6),
          const TituloSecao('Próxima missão'),
          agenda.proximo == null
              ? _SemMissao()
              : _ProximaMissao(
                  agendamento: agenda.proximo!,
                  aoTocar: () => home.irPara(HomeController.agenda),
                ),
          if (agenda.pendentesDeAvaliacao > 0) ...[
            const SizedBox(height: Espaco.s4),
            Painel(
              cor: Cores.goldSoft,
              corBorda: Cores.gold,
              aoTocar: () => home.irPara(HomeController.agenda),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Cores.goldFill),
                  const SizedBox(width: Espaco.s3),
                  Expanded(
                    child: Text(
                      agenda.pendentesDeAvaliacao == 1
                          ? 'Tem 1 atendimento esperando tua avaliação.'
                          : 'Tem ${agenda.pendentesDeAvaliacao} atendimentos '
                                'esperando tua avaliação.',
                      style: Estilos.body.copyWith(color: Cores.gold),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Cores.gold),
                ],
              ),
            ),
          ],
          const SizedBox(height: Espaco.s6),
          TituloSecao(
            'Barbeiros',
            acao: 'Ver todos',
            aoTocarAcao: () => home.irPara(HomeController.barbeiros),
          ),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: g<BarbeiroController>().barbeiros.length,
              separatorBuilder: (_, _) => const SizedBox(width: Espaco.s3),
              itemBuilder: (context, i) {
                final b = g<BarbeiroController>().barbeiros[i];
                return SizedBox(
                  width: 112,
                  child: Painel(
                    padding: const EdgeInsets.all(Espaco.s2),
                    aoTocar: () => Navigator.pushNamed(
                      context,
                      AppRoutes.barbeiroDetalhe,
                      arguments: b,
                    ),
                    child: Column(
                      children: [
                        FotoMoldura(b.foto, tamanho: 84),
                        const SizedBox(height: Espaco.s2),
                        Text(
                          b.nome.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Estilos.displayMd.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Espaco.s6),
          TituloSecao(
            'Em alta no bairro',
            acao: 'Catálogo',
            aoTocarAcao: () => home.irPara(HomeController.cortes),
          ),
          for (final c in g<CorteController>().destaques) ...[
            Painel(
              aoTocar: () {
                agenda.iniciar(corte: c);
                Navigator.pushNamed(context, AppRoutes.agendar);
              },
              child: Row(
                children: [
                  FotoMoldura(c.imagem, tamanho: 64),
                  const SizedBox(width: Espaco.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.nome.toUpperCase(),
                          style: Estilos.displayMd.copyWith(fontSize: 22),
                        ),
                        Text(
                          Formatos.duracao(c.duracaoMin),
                          style: Estilos.label,
                        ),
                      ],
                    ),
                  ),
                  PrecoHud(c.preco, hud: false, tamanho: 22),
                ],
              ),
            ),
            const SizedBox(height: Espaco.s3),
          ],
        ],
      ),
    );
  }
}

class _SemMissao extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Painel(
      destaque: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextoContorno(
            'NENHUMA MISSÃO MARCADA',
            estilo: Estilos.displayMd.copyWith(color: Cores.ink),
          ),
          const SizedBox(height: Espaco.s1),
          const Text(
            'Esse cabelo tá pedindo um trato. Escolhe o barbeiro e o horário.',
            style: Estilos.bodySm,
          ),
          const SizedBox(height: Espaco.s4),
          SaBotao.primario(
            rotulo: 'Agendar horário',
            icone: Icons.event_available,
            aoPressionar: () {
              g<AgendamentoController>().iniciar();
              Navigator.pushNamed(context, AppRoutes.agendar);
            },
          ),
        ],
      ),
    );
  }
}

class _ProximaMissao extends StatelessWidget {
  final Agendamento agendamento;
  final VoidCallback aoTocar;

  const _ProximaMissao({required this.agendamento, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final a = agendamento;
    return Painel(
      destaque: true,
      aoTocar: aoTocar,
      child: Row(
        children: [
          FotoMoldura(a.barbeiro.foto, tamanho: 72),
          const SizedBox(width: Espaco.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.corte.nome.toUpperCase(),
                  style: Estilos.displayMd.copyWith(fontSize: 22),
                ),
                Text('com ${a.barbeiro.nome}', style: Estilos.bodySm),
                const SizedBox(height: Espaco.s1),
                Text(
                  Formatos.dataHora(a.data),
                  style: Estilos.caption.copyWith(color: Cores.gold),
                ),
              ],
            ),
          ),
          PrecoHud(a.corte.preco, hud: false, tamanho: 22),
        ],
      ),
    );
  }
}
