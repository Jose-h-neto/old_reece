import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/barbeiro_controller.dart';
import '../core/app_routes.dart';
import '../core/dependencias.dart';
import '../core/formatos.dart';
import '../core/tema.dart';
import '../model/barbeiro.dart';
import '../model/corte.dart';
import '../widgets/hud.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';
import '../widgets/texto_contorno.dart';

/// Funcionalidade: perfil do barbeiro — foto, avaliação, dias de
/// atendimento e os cortes que ele faz.
class BarbeiroDetalheView extends StatelessWidget {
  final Barbeiro barbeiro;

  const BarbeiroDetalheView({super.key, required this.barbeiro});

  void _agendar(BuildContext context, {Corte? corte}) {
    g<AgendamentoController>().iniciar(barbeiro: barbeiro, corte: corte);
    Navigator.pushNamed(context, AppRoutes.agendar);
  }

  @override
  Widget build(BuildContext context) {
    final b = barbeiro;
    final cortes = g<BarbeiroController>().cortesDe(b);

    return Scaffold(
      appBar: AppBar(title: Text(b.nome.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Espaco.s6),
        children: [
          SizedBox(
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(b.foto, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Cores.outline, width: 3),
                    ),
                  ),
                ),
                Positioned(
                  left: Espaco.s4,
                  right: Espaco.s4,
                  bottom: Espaco.s4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextoContorno(b.nome, estilo: Estilos.zone, contorno: 3),
                      TextoContorno(
                        '“${b.frase}”',
                        estilo: Estilos.subtitle.copyWith(color: Cores.onHud),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Espaco.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Dado(
                        rotulo: 'Experiência',
                        valor: '${b.anosExperiencia} anos',
                      ),
                    ),
                    const SizedBox(width: Espaco.s3),
                    Expanded(
                      child: Painel(
                        padding: const EdgeInsets.all(Espaco.s3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PROCURADO', style: Estilos.label),
                            const SizedBox(height: Espaco.s1),
                            FittedBox(child: Estrelas(valor: b.estrelas)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Espaco.s6),
                TituloSecao(b.apelido),
                Text(b.bio, style: Estilos.body),
                const SizedBox(height: Espaco.s2),
                Etiqueta(b.especialidade, tom: TomEtiqueta.breath),
                const SizedBox(height: Espaco.s6),
                const TituloSecao('Dias de atendimento'),
                DiasAtendimento(b.diasAtendimento),
                const SizedBox(height: Espaco.s6),
                const TituloSecao('Serviços'),
                Painel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final c in cortes)
                        ListTile(
                          leading: FotoMoldura(c.imagem, tamanho: 44),
                          title: Text(c.nome),
                          subtitle: Text(
                            Formatos.duracao(c.duracaoMin),
                            style: Estilos.label,
                          ),
                          trailing: PrecoHud(c.preco, hud: false, tamanho: 20),
                          onTap: () => _agendar(context, corte: c),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(Espaco.s4),
          decoration: const BoxDecoration(
            color: Cores.surface,
            border: Border(top: BorderSide(color: Cores.line, width: 2)),
          ),
          child: SaBotao.primario(
            rotulo: 'Agendar com ${b.nome}',
            icone: Icons.event_available,
            aoPressionar: () => _agendar(context),
          ),
        ),
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _Dado({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Painel(
      padding: const EdgeInsets.all(Espaco.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo.toUpperCase(), style: Estilos.label),
          const SizedBox(height: Espaco.s1),
          Text(
            valor.toUpperCase(),
            style: Estilos.displayMd.copyWith(fontSize: 20, color: Cores.gold),
          ),
        ],
      ),
    );
  }
}
