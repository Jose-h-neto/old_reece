import 'package:flutter/material.dart';

import '../controller/agendamento_controller.dart';
import '../controller/perfil_controller.dart';
import '../core/dependencias.dart';
import '../core/tema.dart';
import '../core/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/hud.dart';
import '../widgets/mensagem.dart';
import '../widgets/painel.dart';
import '../widgets/sa_botao.dart';
import '../widgets/texto_contorno.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final ctrl = g<PerfilController>();
  final agenda = g<AgendamentoController>();
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: ctrl.nome);
  late final _email = TextEditingController(text: ctrl.email);
  late final _telefone = TextEditingController(text: ctrl.telefone);

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    super.dispose();
  }

  String get _iniciais {
    final partes = ctrl.nome.trim().split(RegExp(r'\s+'));
    final letras = partes.where((p) => p.isNotEmpty).take(2).map((p) => p[0]);
    return letras.join().toUpperCase();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) {
      mostrarMensagem(context, 'Confere o nome informado.', erro: true);
      return;
    }
    await ctrl.salvar(_nome.text);
    if (!mounted) return;
    mostrarMensagem(context, 'Perfil atualizado. Respeito +');
  }

  void _cancelar() {
    _nome.text = ctrl.nome;
    _form.currentState!.reset();
    mostrarMensagem(context, 'Alterações descartadas.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MEU PERFIL')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ctrl,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(Espaco.s4),
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Cores.groveSoft,
                      border: Border.all(color: Cores.grove, width: 3),
                      boxShadow: Sombras.hard,
                    ),
                    child: TextoContorno(
                      _iniciais,
                      estilo: Estilos.displayMd.copyWith(color: Cores.grove),
                    ),
                  ),
                  const SizedBox(width: Espaco.s4),
                  Expanded(
                    child: TituloZona(
                      ctrl.nome,
                      tamanho: 30,
                      subtitulo: 'Cliente Old Reece',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Espaco.s6),
              Painel(
                child: BarraHud(
                  rotulo: 'Respeito',
                  rotuloValor:
                      '${agenda.respeito}/${AgendamentoController.metaRespeito}',
                  valor: agenda.respeito.toDouble(),
                  maximo: AgendamentoController.metaRespeito.toDouble(),
                ),
              ),
              const SizedBox(height: Espaco.s6),
              const TituloSecao('Dados da conta'),
              Form(
                key: _form,
                child: Column(
                  children: [
                    CampoTexto(
                      controller: _nome,
                      rotulo: 'Nome',
                      icone: Icons.person_outline,
                      teclado: TextInputType.name,
                      acao: TextInputAction.done,
                      validador: Validadores.nome,
                      aoEnviar: (_) => _salvar(),
                    ),
                    const SizedBox(height: Espaco.s4),
                    CampoTexto(
                      controller: _email,
                      rotulo: 'E-mail (login)',
                      icone: Icons.alternate_email,
                      somenteLeitura: true,
                    ),
                    const SizedBox(height: Espaco.s4),
                    CampoTexto(
                      controller: _telefone,
                      rotulo: 'Telefone',
                      icone: Icons.phone_outlined,
                      somenteLeitura: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Espaco.s6),
              SaBotao.primario(
                rotulo: 'Salvar alterações',
                icone: Icons.save_outlined,
                carregando: ctrl.salvando,
                aoPressionar: _salvar,
              ),
              const SizedBox(height: Espaco.s3),
              SaBotao(
                rotulo: 'Cancelar edição',
                icone: Icons.undo,
                largo: true,
                aoPressionar: ctrl.salvando ? null : _cancelar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
