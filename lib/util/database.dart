import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conta.dart';
import '../models/cartao.dart';

class DataBase {
  CollectionReference db = FirebaseFirestore.instance.collection('contas');

  Stream<QuerySnapshot> streamContas() {
    return FirebaseFirestore.instance.collection('contas').snapshots();
  }

  Stream<QuerySnapshot> streamFilterContas(int ano) {
    return FirebaseFirestore.instance
        .collection('contas')
        .where('ano', isEqualTo: ano)
        .snapshots();
  }

  Future<void> insertConta(String id, Conta conta) async {
    await db.doc(id).set(conta.toMap());
    int ano = conta.ano;
    this.insertAnos(ano);
  }

  Future<void> insertItemConta(String id, ItemConta item) async {
    DocumentSnapshot doc = await db.doc(id).get();
    Conta conta = Conta.fromMap(doc.data());
    conta.addItem(item);
    await db.doc(id).set(conta.toMap());
  }

  Future<Conta> getConta(String id) async {
    DocumentSnapshot doc = await db.doc(id).get();
    if (!doc.exists) {
      return null;
    } else {
      return Conta.fromMap(doc.data());
    }
  }

  Future<QuerySnapshot> getAllContasPorAno(int ano) async {
    return await db.where('ano', isEqualTo: ano).get();
  }

  Future<void> updateUnicoItemConta(
      String id, int index, ItemConta itemConta) async {
    DocumentSnapshot doc = await db.doc(id).get();
    Conta conta = Conta.fromMap(doc.data());
    conta.updateItem(index, itemConta);
    await db.doc(id).update(conta.toMap());
  }

  Future<void> updateItemConta(String id, List<ItemConta> itensConta) async {
    List itens = [];
    List total = [];

    itensConta.forEach((element) {
      itens.add(element.toMap());
      total.add(element.valor);
    });

    await db.doc(id).update({
      'itens': FieldValue.arrayUnion(itens),
      'total': FieldValue.increment(
          total.reduce((value, element) => value + element))
    });
  }

  Future<void> removeItemConta(String id, int index) async {
    DocumentSnapshot doc = await db.doc(id).get();
    Conta conta = Conta.fromMap(doc.data());
    conta.removeItem(index);
    await db.doc(id).set(conta.toMap());
  }

  Future<void> removeConta(String id) async {
    WriteBatch batch = db.firestore.batch();
    QuerySnapshot data = await db.get();
    data.docs.forEach((element) {
      batch.delete(db.doc(id).collection('cartoes').doc(element.id));
    });
    batch.delete(db.doc(id));
    await batch.commit();
  }

  Future<void> insertCartao(String id, String idCartao, Cartao cartao) async {
    await db.doc(id).collection('cartoes').doc(idCartao).set(cartao.toMap());
  }

  Future<Cartao> getCartao(String id, String cartao) async {
    DocumentSnapshot doc =
        await db.doc(id).collection('cartoes').doc(cartao).get();
    if (!doc.exists) {
      return null;
    } else {
      return Cartao.fromJson(doc.data());
    }
  }

  Stream<QuerySnapshot> streamCartao(String id) {
    return FirebaseFirestore.instance
        .collection('contas')
        .doc(id)
        .collection('cartoes')
        .snapshots();
  }

  Future<double> getTotalCartao(String id) async {
    QuerySnapshot query = await db.doc(id).collection('cartoes').get();
    List<QueryDocumentSnapshot> docs = query.docs;
    double total = 0;
    docs.forEach((cartao) {
      total += double.parse(cartao.data()['total'].toString());
    });
    return total;
  }

  Future<QuerySnapshot> getAllCartoes(String mes) async {
    return await db.doc(mes).collection('cartoes').get();
  }

  Future<void> createItemCartao(String id, String cartao, Cartao item) async {
    await db.doc(id).collection('cartoes').doc(cartao).set(item.toMap());
  }

  Future<void> insertItemCartao(
      String id, String cartao, ItemCartao item) async {
    DocumentSnapshot snapshot =
        await db.doc(id).collection('cartoes').doc(cartao).get();
    Cartao data = Cartao.fromJson(snapshot.data());
    data.addItem(item);
    await db.doc(id).collection('cartoes').doc(cartao).set(data.toMap());
  }

  Future<void> updateUnicoItemCartao(
      String id, String cartao, int index, ItemCartao item) async {
    DocumentSnapshot snapshot =
        await db.doc(id).collection('cartoes').doc(cartao).get();
    Cartao data = Cartao.fromJson(snapshot.data());
    data.updateItem(index, item);
    await db.doc(id).collection('cartoes').doc(cartao).update(data.toMap());
  }

  Future<void> updateItemCartao(
      String id, String cartao, List<ItemCartao> itens) async {
    List data = [];
    List total = [];
    itens.forEach((e) {
      print(e);
      data.add(e.toMap());
      total.add(e.valor);
    });
    print(data);
    print(total);
    await db.doc(id).collection('cartoes').doc(cartao).update({
      'descricao': FieldValue.arrayUnion(data),
      'total': FieldValue.increment(
          total.reduce((value, element) => value + element))
    });
  }

  Future<void> removeCartao(String id, String cartao) async {
    await db.doc(id).collection('cartoes').doc(cartao).delete();
  }

  Future<void> removeItemCartao(String id, String cartao, int index) async {
    DocumentSnapshot snapshot =
        await db.doc(id).collection('cartoes').doc(cartao).get();
    Cartao data = Cartao.fromJson(snapshot.data());
    data.removeItem(index);
    await db.doc(id).collection('cartoes').doc(cartao).update(data.toMap());

    Cartao checkCartao = await getCartao(id, cartao);
    if (checkCartao.descricao.length == 0) {
      removeCartao(id, cartao);
    }
  }

  Future<void> runBatch(Map<String, dynamic> itens) async {
    WriteBatch batch = db.firestore.batch();
    for (int i = 0; i < itens['cartoes'].length; i++) {
      batch.set(db.doc(itens['ids'][i]), itens['contas'][i].toMap());
      batch.set(
          db.doc(itens['ids'][i]).collection('cartoes').doc(itens['idCartao']),
          itens['cartoes'][i].toMap());
    }
    batch.commit();
    int ano = itens['contas'][itens['contas'].length - 1].ano;
    this.insertAnos(ano);
  }

  Future<void> insertAnos(int ano) async {
    CollectionReference anos = FirebaseFirestore.instance.collection('anos');
    DocumentSnapshot doc = await anos.doc('ids').get();
    bool exists;
    for (var i in doc.data()['docs']) {
      if (ano == i) {
        exists = true;
      } else {
        exists = false;
      }
    }
    if (!exists) {
      await anos.doc('ids').update({
        'docs': FieldValue.arrayUnion([ano])
      });
    }
  }

  Future<List> getAnos() async {
    CollectionReference anos = FirebaseFirestore.instance.collection('anos');
    DocumentSnapshot doc = await anos.doc('ids').get();
    return doc.data()['docs'];
  }
}
