import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/barbeiro_controller.dart';
import '../controller/corte_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../data/dados_mock.dart';
import '../model/corte.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';

/// Funcionalidade: agendar horário — escolher barbeiro, serviço, dia da
/// semana e horário livre.
class AgendarView extends StatelessWidget {
  const AgendarView({super.key});

  Future<void> _confirmar(BuildContext context) async {
    final ctrl = g<AgendamentoController>();
    final novo = await ctrl.confirmar();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.confirmacao,
      arguments: novo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = g<AgendamentoController>();

    return Scaffold(
      appBar: AppBar(title: const Text('NOVA MISSÃO')),
      body: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(Espaco.s4),
          children: [
            const TituloSecao('1 · Escolhe o barbeiro'),
            _EscolhaBarbeiro(ctrl),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('2 · Escolhe o serviço'),
            _EscolhaCorte(ctrl),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('3 · Dia da semana'),
            _EscolhaDia(ctrl),
            const SizedBox(height: Espaco.s6),
            const TituloSecao('4 · Horário'),
            _EscolhaHora(ctrl),
            const SizedBox(height: Espaco.s6),
            _Resumo(ctrl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(Espaco.s4),
          decoration: const BoxDecoration(
            color: Cores.surface,
            border: Border(top: BorderSide(color: Cores.line, width: 2)),
          ),
          child: ListenableBuilder(
            listenable: ctrl,
            builder: (context, _) => SaBotao.primario(
              rotulo: 'Iniciar missão',
              icone: Icons.flag_outlined,
              carregando: ctrl.salvando,
              aoPressionar: ctrl.podeConfirmar
                  ? () => _confirmar(context)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão selecionável usado nas escolhas.
class _Opcao extends StatelessWidget {
  final bool selecionado;
  final bool habilitado;
  final VoidCallback onTap;
  final Widget child;
  final String rotuloSemantico;

  const _Opcao({
    required this.selecionado,
    required this.onTap,
    required this.child,
    required this.rotuloSemantico,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      enabled: habilitado,
      label: rotuloSemantico,
      child: Opacity(
        opacity: habilitado ? 1 : 0.35,
        child: Container(
          decoration: BoxDecoration(
            color: selecionado ? Cores.groveSoft : Cores.surfaceRaised,
            border: Border.all(
              color: selecionado ? Cores.grove : Cores.lineStrong,
              width: selecionado ? 3 : 2,
            ),
            boxShadow: selecionado ? Sombras.hard : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: habilitado ? onTap : null, child: child),
          ),
        ),
      ),
    );
  }
}

class _EscolhaBarbeiro extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaBarbeiro(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final barbeiros = g<BarbeiroController>().barbeiros;
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: barbeiros.length,
        separatorBuilder: (_, _) => const SizedBox(width: Espaco.s3),
        itemBuilder: (context, i) {
          final b = barbeiros[i];
          final sel = ctrl.barbeiro?.id == b.id;
          return SizedBox(
            width: 104,
            child: _Opcao(
              selecionado: sel,
              rotuloSemantico: 'Barbeiro ${b.nome}',
              onTap: () => ctrl.escolherBarbeiro(b),
              child: Padding(
                padding: const EdgeInsets.all(Espaco.s2),
                child: Column(
                  children: [
                    FotoMoldura(b.foto, tamanho: 72),
                    const SizedBox(height: Espaco.s2),
                    Text(
                      b.nome.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Estilos.displayMd.copyWith(
                        fontSize: 16,
                        color: sel ? Cores.grove : Cores.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EscolhaCorte extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaCorte(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final List<Corte> cortes = ctrl.barbeiro == null
        ? g<CorteController>().cortes
        : g<BarbeiroController>().cortesDe(ctrl.barbeiro!);

    return SizedBox(
      height: 152,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: cortes.length,
        separatorBuilder: (_, _) => const SizedBox(width: Espaco.s3),
        itemBuilder: (context, i) {
          final c = cortes[i];
          final sel = ctrl.corte?.id == c.id;
          return SizedBox(
            width: 112,
            child: _Opcao(
              selecionado: sel,
              rotuloSemantico: '${c.nome}, ${Formatos.preco(c.preco)}',
              onTap: () => ctrl.escolherCorte(c),
              child: Padding(
                padding: const EdgeInsets.all(Espaco.s2),
                child: Column(
                  children: [
                    FotoMoldura(c.imagem, tamanho: 64),
                    const SizedBox(height: Espaco.s1),
                    Text(
                      c.nome.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Estilos.displayMd.copyWith(
                        fontSize: 15,
                        color: sel ? Cores.grove : Cores.ink,
                      ),
                    ),
                    Text(Formatos.duracao(c.duracaoMin), style: Estilos.label),
                    PrecoHud(c.preco, hud: false, tamanho: 17),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EscolhaDia extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaDia(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final barbeiro = ctrl.barbeiro;
    if (barbeiro == null) {
      return const _Dica('Escolhe o barbeiro pra ver os dias que ele atende.');
    }

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: ctrl.diasDaSemana.length,
        separatorBuilder: (_, _) => const SizedBox(width: Espaco.s2),
        itemBuilder: (context, i) {
          final d = ctrl.diasDaSemana[i];
          final atende = barbeiro.atendeNo(d);
          final sel = ctrl.dia == d;
          return SizedBox(
            width: 60,
            child: _Opcao(
              selecionado: sel,
              habilitado: atende,
              rotuloSemantico:
                  '${Formatos.dataLonga(d)}${atende ? '' : ', sem atendimento'}',
              onTap: () => ctrl.escolherDia(d),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    i == 0 ? 'HOJE' : Formatos.diaCurto(d),
                    style: Estilos.label.copyWith(
                      fontSize: 8,
                      color: sel ? Cores.grove : Cores.inkMuted,
                    ),
                  ),
                  Text(
                    '${d.day}',
                    style: Estilos.displayMd.copyWith(
                      color: sel ? Cores.grove : Cores.ink,
                    ),
                  ),
                  Text(
                    Formatos.meses[d.month - 1].toUpperCase(),
                    style: Estilos.label.copyWith(fontSize: 8),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EscolhaHora extends StatelessWidget {
  final AgendamentoController ctrl;

  const _EscolhaHora(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final barbeiro = ctrl.barbeiro;
    final dia = ctrl.dia;
    if (barbeiro == null || dia == null) {
      return const _Dica(
        'Escolhe o barbeiro e o dia pra ver os horários livres.',
      );
    }

    final livres = DadosMock.horarios
        .where((h) => ctrl.horarioLivre(barbeiro, dia, h))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Espaco.s2,
          runSpacing: Espaco.s2,
          children: [
            for (final h in DadosMock.horarios)
              Builder(
                builder: (context) {
                  final livre = ctrl.horarioLivre(barbeiro, dia, h);
                  final sel = ctrl.hora == h;
                  return ChoiceChip(
                    label: Text(
                      '${h.toString().padLeft(2, '0')}:00',
                      style: Estilos.menu.copyWith(
                        fontSize: 10,
                        color: sel
                            ? Cores.onGrove
                            : livre
                            ? Cores.ink
                            : Cores.inkMuted,
                        decoration: livre ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    tooltip: livre ? null : 'Ocupado',
                    selected: sel,
                    onSelected: livre ? (_) => ctrl.escolherHora(h) : null,
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: Espaco.s2),
        Text(
          livres == 0
              ? 'Agenda lotada nesse dia. Tenta outro.'
              : '$livres horários livres · os riscados já estão ocupados.',
          style: Estilos.caption,
        ),
      ],
    );
  }
}

class _Resumo extends StatelessWidget {
  final AgendamentoController ctrl;

  const _Resumo(this.ctrl);

  @override
  Widget build(BuildContext context) {
    String ou(String? v) => v ?? '—';

    return Painel(
      destaque: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('RESUMO DA MISSÃO', style: Estilos.label),
          const SizedBox(height: Espaco.s2),
          _Linha('Barbeiro', ou(ctrl.barbeiro?.nome)),
          _Linha('Serviço', ou(ctrl.corte?.nome)),
          _Linha('Dia', ctrl.dia == null ? '—' : Formatos.dataLonga(ctrl.dia!)),
          _Linha(
            'Horário',
            ctrl.hora == null
                ? '—'
                : '${ctrl.hora.toString().padLeft(2, '0')}:00',
          ),
          const Divider(height: Espaco.s6, thickness: 2),
          Row(
            children: [
              const Expanded(child: Text('TOTAL', style: Estilos.label)),
              PrecoHud(ctrl.corte?.preco ?? 0),
            ],
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _Linha(this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(rotulo.toUpperCase(), style: Estilos.label),
          ),
          Expanded(
            child: Text(
              valor,
              style: Estilos.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dica extends StatelessWidget {
  final String texto;

  const _Dica(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Espaco.s3),
      decoration: BoxDecoration(
        color: Cores.breathSoft,
        border: Border.all(color: Cores.breath, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Cores.breath, size: 20),
          const SizedBox(width: Espaco.s2),
          Expanded(
            child: Text(
              texto,
              style: Estilos.bodySm.copyWith(color: Cores.breath),
            ),
          ),
        ],
      ),
    );
  }
}
