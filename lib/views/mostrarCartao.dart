import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../util/database.dart';
import 'package:expandable/expandable.dart';
import '../models/conta.dart';
import './adicionarCartao.dart';
import 'package:intl/intl.dart';
import '../util/generate.dart' as generate;
import '../util/convert.dart' as convert;
import './components/addCartao.dart';
import '../models/cartao.dart';

class MostrarCartao extends StatefulWidget {
  MostrarCartao({Key? key, required this.mes, required this.data})
      : super(key: key);
  final String mes;
  final QueryDocumentSnapshot data;
  @override
  _MostrarCartaoState createState() =>
      _MostrarCartaoState(mes: mes, data: data);
}

class _MostrarCartaoState extends State<MostrarCartao> {
  _MostrarCartaoState({required this.mes, required this.data});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final String mes;
  final QueryDocumentSnapshot data;
  DataBase db = new DataBase();

  var f = new NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: db.streamCartao(mes),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error as String));
              }

              QuerySnapshot query = snapshot.data as QuerySnapshot;
              List<QueryDocumentSnapshot> docs = query.docs;

              return Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(title: Text('Cartões'), centerTitle: true),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdicionarCartao(mes: mes)));
                  },
                ),
                body: ListView(
                  children: [
                    for (final doc in docs)
                      Card(
                        child: ExpandablePanel(
                          // ignore: deprecated_member_use
                          // hasIcon: false,
                          header: Container(
                            decoration: BoxDecoration(
                                color: Color(int.parse(
                                    '0xff${(doc.data() as Map<String, dynamic>)['style']['background']}')),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5))),
                            child: Text(
                              (doc.data() as Map<String, dynamic>)['nome'],
                              style: TextStyle(
                                  color: Color(int.parse(
                                      '0xff${(doc.data() as Map<String, dynamic>)['style']['text']}')),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                            padding: EdgeInsets.all(15),
                          ),
                          collapsed: Container(
                            child: Text(
                              'Total: ${f.format(double.parse((doc.data() as Map<String, dynamic>)['total'].toString()))}',
                              style: TextStyle(fontSize: 16),
                            ),
                            padding: EdgeInsets.all(15),
                          ),
                          expanded: Column(
                            children: [
                              ...itens(doc),
                              ListTile(
                                trailing: IconButton(
                                  icon: CircleAvatar(
                                    backgroundColor: Color(int.parse(
                                        '0xff${(doc.data() as Map<String, dynamic>)['style']['background']}')),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await addCartao(
                                        context: context,
                                        onSubmit: (itemCartao) {
                                          if (itemCartao.parcela == '01/01') {
                                            db.insertItemCartao(
                                                mes, doc.id, itemCartao);
                                          } else {
                                            Conta conta = Conta.fromMap(
                                                data.data()
                                                    as Map<String, dynamic>);
                                            Cartao newCartao = Cartao.fromJson(
                                                doc.data()
                                                    as Map<String, dynamic>);
                                            newCartao.addItem(itemCartao);

                                            Map<String, dynamic> res =
                                                generate.parcelas(mes, conta,
                                                    doc.id, newCartao);
                                            db.runBatch(res);
                                          }
                                        });
                                    //_showMyDialog(doc, mes, doc.id);
                                  },
                                ),
                                title: Text(
                                  'Total: ${f.format(double.parse((doc.data() as Map<String, dynamic>)['total'].toString()))}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    docs.length == 0 ? Container() : total(docs)
                  ],
                ),
              );
            }));
  }

  Widget total(List<QueryDocumentSnapshot> docs) {
    double total = 0;
    for (var i in docs) {
      total += (i.data() as Map<String, dynamic>)['total'];
    }
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total: ',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '${f.format(total)}',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
      onTap: () {
        Clipboard.setData(
            ClipboardData(text: '${convert.doubleToCurrency(total)}'));
        // _scaffoldKey.currentState.showSnackBar(
        //     SnackBar(content: Text('${f.format(total)} copiado!')));
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(content: Text('${f.format(total)} copiado!')));
      },
    );
  }

  List<Widget> itens(QueryDocumentSnapshot doc) {
    Cartao cartao = Cartao.fromJson(doc.data() as Map<String, dynamic>);
    List<Widget> listaItens = [];
    for (int i = 0;
        i < (doc.data() as Map<String, dynamic>)['descricao'].length;
        i++)
      listaItens.add(ListTile(
        onLongPress: () {
          addCartao(
              context: context,
              item: cartao.descricao[i],
              id: i,
              onSubmit: (itemCartao) {
                db.updateUnicoItemCartao(mes, doc.id, i, itemCartao);
              });
        },
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 2.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(cartao.descricao[i].parcela)),
              Expanded(flex: 3, child: Text(cartao.descricao[i].item)),
              Expanded(
                  flex: 2, child: Text(f.format(cartao.descricao[i].valor))),
            ],
          ),
        ),
        trailing: IconButton(
            icon: Icon(Icons.do_not_disturb_on, color: Colors.red),
            onPressed: () async {
              db.removeItemCartao(mes, doc.id, i);
            }),
      ));
    return listaItens;
  }
}
