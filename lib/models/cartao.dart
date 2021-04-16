class Cartao {
  String nome;
  List descricao;
  Map style;
  double total;

  Cartao({this.nome, this.descricao, this.style, this.total});
  Cartao.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    descricao = this.itemsFromList(json['descricao']);
    style = json['style'];
    total = json['total'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['descricao'] = this.itensToMap();
    data['style'] = this.style;
    data['total'] = this.getTotal();
    return data;
  }

  List itemsFromList(List lista) {
    List desList = [];
    for (var i in lista) {
      desList.add(ItemCartao.fromJSON(i));
    }
    return desList;
  }

  void addItem(ItemCartao item) {
    this.descricao.add(item);
    this.total += item.valor;
  }

  void removeItem(int index) {
    this.total -= this.descricao[index].valor;
    this.descricao.removeAt(index);
  }

  void updateItem(int index, ItemCartao item) {
    for (int i = 0; i < this.descricao.length; i++) {
      if (this.descricao.indexOf(this.descricao[i]) == index) {
        this.descricao[i] = item;
      }
    }
  }

  List<String> getParcelas() {
    List<String> data = [];
    this.descricao.map((e) {
      data.add(e.parcela);
    });
    return data;
  }

  List itensToMap() {
    List itensList = [];
    for (var i in this.descricao) {
      itensList.add(i.toMap());
    }
    return itensList;
  }

  double getTotal() {
    double total = 0;
    for (var i in this.descricao) {
      total += i.valor;
    }
    this.total = total;
    return double.parse(total.toStringAsFixed(2));
  }
}

class ItemCartao {
  String item;
  String parcela;
  double valor;

  ItemCartao({this.item, this.parcela, this.valor});

  ItemCartao.fromJSON(Map<String, dynamic> json) {
    item = json['item'];
    parcela = json['parcela'];
    valor = json['valor'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item'] = this.item;
    data['parcela'] = this.parcela;
    data['valor'] = this.valor;
    return data;
  }
}
