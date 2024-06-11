/// Converte a moeda do padrão 🇧🇷BRL para o 🇺🇸USD
///
/// Recebe um valor string no formato
/// ``` dart
/// String valor = '1.000,00'
/// ```
/// e retorna um valor tipo double
/// ``` dart
/// double valor = 1000.00
/// ```
double currencyToDouble(String value) {
  List<String> result = value.split(',');
  return double.parse('${result[0].split('.').join('')}.${result[1]}');
}

/// Converte a moeda do padrão 🇺🇸USD para o 🇧🇷BRL
///
/// Recebe um valor double no formato
/// ``` dart
/// double valor = 1000.00
/// ```
/// e retorna um valor tipo double
/// ``` dart
/// String valor =  '1000,00'
/// ```
String doubleToCurrency(double value) {
  List<String> result = value.toString().split('.');
  return '${result[0]},${result[1].padRight(2, '0')}';
}
