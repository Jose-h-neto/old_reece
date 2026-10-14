import 'package:flutter/material.dart';

import '../data/dados_mock.dart';
import '../model/barbeiro.dart';
import '../model/corte.dart';

class BarbeiroController extends ChangeNotifier {
  final List<Barbeiro> _todos = DadosMock.barbeiros;

  /// Quando ligado, mostra só quem atende hoje.
  bool soHoje = false;

  List<Barbeiro> get barbeiros {
    if (!soHoje) return _todos;
    final hoje = DateTime.now();
    return _todos.where((b) => b.atendeNo(hoje)).toList();
  }

  void alternarSoHoje() {
    soHoje = !soHoje;
    notifyListeners();
  }

  List<Corte> cortesDe(Barbeiro barbeiro) =>
      barbeiro.cortes.map(DadosMock.corte).toList();

  List<Barbeiro> quemFaz(Corte corte) =>
      _todos.where((b) => b.cortes.contains(corte.id)).toList();
}
