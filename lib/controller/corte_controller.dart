import 'package:flutter/material.dart';

import '../data/dados_mock.dart';
import '../model/corte.dart';

class CorteController extends ChangeNotifier {
  final List<Corte> _todos = DadosMock.cortes;

  /// Filtro por categoria (null = todos).
  CategoriaCorte? categoria;

  List<Corte> get cortes => categoria == null
      ? _todos
      : _todos.where((c) => c.categoria == categoria).toList();

  List<Corte> get destaques => _todos.where((c) => c.destaque).toList();

  void filtrar(CategoriaCorte? nova) {
    categoria = nova;
    notifyListeners();
  }
}
