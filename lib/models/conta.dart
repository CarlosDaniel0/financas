class Conta {
  List items;
  String mes;
  int ano;
  double total;

  Conta({this.items, this.mes, this.ano, this.total});
  Conta.fromMap(Map<String, dynamic> map) {
    items = this.itemsFromList(map['items']);
    mes = map['mes'];
    ano = map['ano'];
    total = map['total'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['items'] = this.itensToMap();
    map['mes'] = mes;
    map['ano'] = ano;
    map['total'] = this.getTotal();
    return map;
  }

  List itemsFromList(List lista) {
    List desList = [];
    for (var i in lista) {
      desList.add(ItemConta.fromMap(i));
    }
    return desList;
  }

  void addItem(ItemConta item) {
    this.total += item.valor;
    this.items.add(item);
  }

  void removeItem(int id) {
    this.total -= this.items[id].valor;
    this.items.removeAt(id);
  }

  void updateItem(int index, ItemConta item) {
    for (int i = 0; i < this.items.length; i++) {
      if (this.items.indexOf(this.items[i]) == index) {
        this.items[i] = item;
      }
    }
  }

  double getTotal() {
    double total = 0;
    for (var i in this.items) {
      total += i.valor;
    }
    this.total = total;
    return double.parse(total.toStringAsFixed(2));
  }

  List itensToMap() {
    List itensList = [];
    for (var i in this.items) {
      itensList.add(i.toMap());
    }
    return itensList;
  }
}

class ItemConta {
  Map icon;
  String nome;
  double valor;

  ItemConta({this.icon, this.nome, this.valor});
  ItemConta.fromMap(Map<String, dynamic> map) {
    icon = map['icon'];
    nome = map['nome'];
    valor = map['valor'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['icon'] = icon;
    map['nome'] = nome;
    map['valor'] = valor;
    return map;
  }
}

/*
  {
    "descricao" : [
      {
        "item": "Smart TV",
        "parcela": "02/10",
        "valor": 2000
      }
    ],
    "total": 2000
  }
*/

/*
{
  'agua': 40,
  'cartoes': {
    'digio': {
      'descricao': [
        {'item': 'Smartphone', 'parcela': '01/10', 'valor': 200}
      ],
      'total': 250
    },
    'hipercard': {
      'descricao': [
        {'item': 'Smartphone', 'parcela': '01/10', 'valor': 200}
      ],
      'total': 200
    },
    'nubank': {
      'descricao': [
        {'item': 'Smartphone', 'parcela': '01/10', 'valor': 200}
      ],
      'total': 9.99
    }
  },
  'internet': 75,
  'luz': 100,
  'telefone': 40
}
*/
