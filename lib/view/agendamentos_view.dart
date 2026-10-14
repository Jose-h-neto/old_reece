import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/agendamento.dart';
import '../widgets/hud.dart';
import '../widgets/mensagem.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: minha agenda (ListView) — próximos horários com opção de
/// cancelar e o histórico com avaliações.
class AgendamentosView extends StatelessWidget {
  const AgendamentosView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = g<AgendamentoController>();

    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final proximos = ctrl.proximos;
        final historico = ctrl.historico;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            Espaco.s4,
            Espaco.s4,
            Espaco.s4,
            96, // espaço para o botão flutuante
          ),
          children: [
            const TituloSecao('Próximas missões'),
            if (proximos.isEmpty)
              const Painel(
                child: Text(
                  'Nada marcado por enquanto. Toca em AGENDAR pra escolher '
                  'barbeiro e horário.',
                  style: Estilos.bodySm,
                ),
              ),
            for (final a in proximos) ...[
              _ItemAgendamento(a),
              const SizedBox(height: Espaco.s3),
            ],
            const SizedBox(height: Espaco.s6),
            const TituloSecao('Histórico'),
            if (historico.isEmpty)
              const Text('Teu histórico aparece aqui.', style: Estilos.bodySm),
            for (final a in historico) ...[
              _ItemAgendamento(a),
              const SizedBox(height: Espaco.s3),
            ],
          ],
        );
      },
    );
  }
}

class _ItemAgendamento extends StatelessWidget {
  final Agendamento agendamento;

  const _ItemAgendamento(this.agendamento);

  Future<void> _cancelar(BuildContext context) async {
    final ok = await confirmar(
      context,
      titulo: 'Cancelar missão?',
      mensagem:
          '${agendamento.corte.nome} com ${agendamento.barbeiro.nome}, '
          '${Formatos.dataHora(agendamento.data)}.',
      rotuloConfirmar: 'Cancelar horário',
      perigo: true,
    );
    if (!ok || !context.mounted) return;
    g<AgendamentoController>().cancelar(agendamento);
    mostrarMensagem(context, 'Missão cancelada. A cadeira foi liberada.');
  }

  @override
  Widget build(BuildContext context) {
    final a = agendamento;
    final (tom, cancelado) = switch (a.status) {
      StatusAgendamento.agendado => (TomEtiqueta.grove, false),
      StatusAgendamento.concluido => (TomEtiqueta.breath, false),
      StatusAgendamento.cancelado => (TomEtiqueta.health, true),
    };

    return Painel(
      destaque: a.status == StatusAgendamento.agendado,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: cancelado ? 0.5 : 1,
                child: FotoMoldura(a.barbeiro.foto, tamanho: 60),
              ),
              const SizedBox(width: Espaco.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.corte.nome.toUpperCase(),
                      style: Estilos.displayMd.copyWith(
                        fontSize: 20,
                        color: cancelado ? Cores.inkMuted : Cores.ink,
                        decoration: cancelado
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text('com ${a.barbeiro.nome}', style: Estilos.bodySm),
                    const SizedBox(height: 2),
                    Text(
                      Formatos.dataHora(a.data),
                      style: Estilos.caption.copyWith(
                        color: a.status == StatusAgendamento.agendado
                            ? Cores.gold
                            : Cores.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Etiqueta(a.status.rotulo, tom: tom),
                  const SizedBox(height: Espaco.s2),
                  PrecoHud(a.corte.preco, hud: false, tamanho: 18),
                ],
              ),
            ],
          ),
          if (a.status == StatusAgendamento.agendado) ...[
            const SizedBox(height: Espaco.s3),
            Align(
              alignment: Alignment.centerRight,
              child: SaBotao(
                rotulo: 'Cancelar',
                icone: Icons.close,
                variante: VarianteBotao.perigo,
                aoPressionar: () => _cancelar(context),
              ),
            ),
          ],
          if (a.podeAvaliar) ...[
            const SizedBox(height: Espaco.s3),
            Align(
              alignment: Alignment.centerRight,
              child: SaBotao(
                rotulo: 'Avaliar',
                icone: Icons.star_outline,
                aoPressionar: () => Navigator.pushNamed(
                  context,
                  AppRoutes.avaliar,
                  arguments: a,
                ),
              ),
            ),
          ],
          if (a.avaliacao != null) ...[
            const SizedBox(height: Espaco.s3),
            Row(
              children: [
                const Text('TUA NOTA  ', style: Estilos.label),
                Estrelas(valor: a.avaliacao!, tamanho: 14),
              ],
            ),
            if (a.comentario != null) ...[
              const SizedBox(height: Espaco.s1),
              Text('“${a.comentario}”', style: Estilos.bodySm),
            ],
          ],
        ],
      ),
    );
  }
}
