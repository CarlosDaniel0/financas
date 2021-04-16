import 'package:flutter_test/flutter_test.dart';
import '../lib/util/convert.dart' as convert;
import '../lib/util/generate.dart' as generate;
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

void main() {
  test('converter para double', () {
    double value = convert.currencyToDouble('25,30');
    expect(value, 25.30);
  });

  test('converter para String', () {
    String value = convert.doubleToCurrency(25.30);
    expect(value, '25,3');
  });

  test('Gerar Parcelas', () {
    String id = '202101';
    List<dynamic> lista = generate.proximoMes(id);
    expect(lista, ['Fevereiro', 2021]);
  });

  test('Maior valor em uma lista', () {
    List<int> lista = [0, 10, 5, 3, 4, 2, 1, -2, 5, 6, 15, 20];
    int maior = generate.max(lista);
    expect(maior, 20);
  });

  test('Calcular intervalos incluindo o valor inicial', () {
    int inicio = 1;
    int fim = 9;
    int intervalo = generate.intervalo(inicio, fim);
    expect(intervalo, 10);
  });
}
