import 'package:flutter/material.dart';

import '../controller/barbeiro_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../model/barbeiro.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';

/// Funcionalidade: lista dos barbeiros (ListView), com filtro de quem
/// atende hoje.
class BarbeirosView extends StatelessWidget {
  const BarbeirosView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = g<BarbeiroController>();

    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final lista = ctrl.barbeiros;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Espaco.s4,
                Espaco.s3,
                Espaco.s4,
                0,
              ),
              child: FilterChip(
                label: const Text('SÓ QUEM ATENDE HOJE'),
                avatar: Icon(
                  Icons.today,
                  size: 16,
                  color: ctrl.soHoje ? Cores.onGrove : Cores.inkMuted,
                ),
                selected: ctrl.soHoje,
                onSelected: (_) => ctrl.alternarSoHoje(),
              ),
            ),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(Espaco.s6),
                        child: Text(
                          'Hoje a barbearia tá fechada. Volta amanhã!',
                          textAlign: TextAlign.center,
                          style: Estilos.body,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(Espaco.s4),
                      itemCount: lista.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: Espaco.s4),
                      itemBuilder: (context, i) => _CartaoBarbeiro(lista[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CartaoBarbeiro extends StatelessWidget {
  final Barbeiro barbeiro;

  const _CartaoBarbeiro(this.barbeiro);

  @override
  Widget build(BuildContext context) {
    final b = barbeiro;
    return Painel(
      aoTocar: () =>
          Navigator.pushNamed(context, AppRoutes.barbeiroDetalhe, arguments: b),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FotoMoldura(b.foto, tamanho: 92),
              const SizedBox(width: Espaco.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.nome.toUpperCase(),
                      style: Estilos.displayMd.copyWith(color: Cores.ink),
                    ),
                    Text(b.apelido.toUpperCase(), style: Estilos.label),
                    const SizedBox(height: Espaco.s1),
                    Text(b.especialidade, style: Estilos.bodySm),
                    const SizedBox(height: Espaco.s2),
                    Estrelas(valor: b.estrelas, tamanho: 14),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Cores.inkMuted),
            ],
          ),
          const SizedBox(height: Espaco.s3),
          DiasAtendimento(b.diasAtendimento),
        ],
      ),
    );
  }
}
