import '../models/conta.dart';
import '../models/cartao.dart';

/// Gera as próximas parcelas de um cartão
///
/// Recebe uma instância de Conta e cartão com os
/// respectivos ids
Map<String, dynamic> parcelas(
    String id, Conta conta, String idCartao, Cartao cartao) {
  List<String> itens = [];
  List<String> parcelas = [];
  List<double> valores = [];
  cartao.descricao.forEach((e) {
    itens.add(e.item);
    parcelas.add(e.parcela);
    valores.add(e.valor);
  });
  List data = calcularParcelas(id, parcelas);
  List ids = [];
  double valorTotal;
  data.forEach((element) => ids.add(element['id']));
  List<Conta> contas = [];
  List<Cartao> cartoes = [];

  for (int i = 0; i < data.length; i++) {
    List<ItemCartao> itensCartao = [];
    List total = [];
    for (int j = 0; j < data[i]['parcelas'].length; j++) {
      if (data[i]['parcelas'][j] != null) {
        itensCartao.add(ItemCartao(
            item: itens[j],
            parcela: data[i]['parcelas'][j],
            valor: valores[j]));
        total.add(valores[j]);
      }
    }
    valorTotal = total.reduce((value, element) => value + element);
    contas.add(Conta(
        items: [...conta.items],
        mes: data[i]['mes'],
        ano: data[i]['ano'],
        total: conta.total));
    cartoes.add(Cartao(
        descricao: [...itensCartao],
        nome: cartao.nome,
        style: cartao.style,
        total: valorTotal));
  }

  return {
    'ids': ids,
    'contas': contas,
    'idCartao': idCartao,
    'cartoes': cartoes,
  };
}

intervalo(int inicio, int fim) {
  return (fim - inicio) + 2;
}

max(List lista) {
  int maior = 0;
  for (var i in lista) {
    if (i > maior) {
      maior = i;
    }
  }
  return maior;
}

List<dynamic> proximoMes(String id) {
  int mes = int.parse(id.substring(4, 6));
  int ano = int.parse(id.substring(0, 4));
  List meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];
  String proxMes;
  if (mes == 12) {
    proxMes = meses[0];
    ano += 1;
  }
  proxMes = meses[mes];
  return [proxMes, ano];
}

List<Map<String, dynamic>> calculaMes(String id, int max) {
  int mes = int.parse(id.substring(4, 6));
  int ano = int.parse(id.substring(0, 4));
  List meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];
  List<Map<String, dynamic>> data = [];
  for (int i = 0; i <= max; i++) {
    data.add({
      'id': '$ano${mes.toString().padLeft(2, '0')}',
      'mes': '${meses[mes - 1]}',
      'ano': ano
    });
    if (mes == 12) {
      mes = 1;
      ano++;
    } else {
      mes++;
    }
  }
  return data;
}

List calcularParcelas(String id, List<String> parcelas) {
  List<int> atual = [];
  List<int> ultima = [];
  parcelas.forEach((element) {
    atual.add(int.parse(element.split('/')[0]));
    ultima.add(int.parse(element.split('/')[1]));
  });

  // Intervalo de meses
  List intervaloMaior = [];
  for (int i = 0; i < atual.length; i++) {
    intervaloMaior.add(intervalo(atual[i], ultima[i]));
  }
  int maior = max(intervaloMaior);
  List<Map<String, dynamic>> meses = calculaMes(id, maior);
  List data = [];

  // Gerar próximos meses
  for (int i = 0; i < parcelas.length; i++) {
    int increment = 1;
    Map<int, String> parcelas = Map<int, String>();
    for (int j = atual[i]; j <= ultima[i]; j++) {
      parcelas[increment] =
          '${(j).toString().padLeft(2, '0')}/${ultima[i].toString().padLeft(2, '0')}';
      increment++;
    }
    data.add(parcelas);
  }

  // Cria um Map para armazenar o mes e uma lista de parcelas
  int count = 0;
  List resultado = [];
  for (int i = 1; i < maior; i++) {
    List itens = [];
    for (int j = 0; j < data.length; j++) {
      itens.add(data[j][i]);
    }
    resultado.add({
      'id': meses[count]['id'],
      'mes': meses[count]['mes'],
      'ano': meses[count]['ano'],
      'parcelas': itens
    });
    count++;
  }

  return resultado;
}
