import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas/views/configuracoes.dart';
import 'package:financas/views/relatorio.dart';
import 'package:flutter/material.dart';
import 'package:financas/util/database.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'mostrarCartao.dart';
import '../util/generate.dart' as generate;
import '../models/conta.dart';
import 'adicionarConta.dart';
import '../util/convert.dart' as convert;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';
import './components/addConta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  DateTime data = DateTime.now();
  SharedPreferences prefs;
  var f = new NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  DataBase database = new DataBase();
  int _anoSelecionado;
  @override
  void initState() {
    _prefs.then((value) => prefs = value);
    _anoSelecionado = int.parse(DateFormat('yyyy').format(data));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String now = DateFormat("yyyyMM").format(data);

    return WillPopScope(
        child: Scaffold(
          body: StreamBuilder(
              stream: database.streamFilterContas(_anoSelecionado),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  FirebaseException error = snapshot.error;
                  return Center(child: Text(error.message));
                }
                QuerySnapshot query = snapshot.data;
                List<QueryDocumentSnapshot> docs = query.docs;

                return DefaultTabController(
                    initialIndex: calcularIndex(docs, now),
                    length: docs.length,
                    child: Builder(builder: (context) {
                      return Scaffold(
                          key: _scaffoldKey,
                          appBar: AppBar(
                            automaticallyImplyLeading: false,
                            title: Text('Finanças'),
                            bottom: TabBar(isScrollable: true, tabs: [
                              for (final doc in docs)
                                Tab(
                                    text:
                                        '${doc.data()['mes']} ${doc.data()['ano']}')
                            ]),
                            actions: [
                              PopupMenuButton(onSelected: (selecao) {
                                switch (selecao) {
                                  case 0:
                                    _buscarAno();
                                    break;
                                  case 1:
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Configuracoes(id: docs[0].id)));
                                    break;
                                  case 2:
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Relatorio(
                                                ano: _anoSelecionado)));
                                    break;
                                  case 3:
                                    _deslogar();
                                    break;
                                }
                              }, itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: Text('Selecionar Ano'),
                                    value: 0,
                                  ),
                                  PopupMenuItem(
                                    child: Text('Configurações'),
                                    value: 1,
                                  ),
                                  PopupMenuItem(
                                      child: Text('Relatório'), value: 2),
                                  PopupMenuItem(
                                      child: Text('Deslogar'), value: 3),
                                ];
                              }),
                            ],
                          ),
                          floatingActionButton: FloatingActionButton(
                            child: Icon(Icons.add),
                            onPressed: () async {
                              String mes = generate
                                  .proximoMes(docs[docs.length - 1].id)[0];
                              int ano = generate
                                  .proximoMes(docs[docs.length - 1].id)[1];
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return AdicionarConta(
                                    id: '${int.parse(docs[docs.length - 1].id) + 1}',
                                    mes: mes,
                                    ano: ano);
                              }));
                            },
                          ),
                          body: TabBarView(
                            children: [
                              for (final doc in docs)
                                RefreshIndicator(
                                    onRefresh: () async {
                                      setState(() => null);
                                    },
                                    child: ListView(
                                      children: [
                                        ...templateContas(doc),
                                        FutureBuilder(
                                            future:
                                                database.getTotalCartao(doc.id),
                                            builder: (_, s) {
                                              if (s.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }

                                              if (s.hasError) {
                                                return Center(
                                                    child: Text(s.error));
                                              }

                                              double totalCartoes = s.data;
                                              return total(doc, totalCartoes);
                                            })
                                      ],
                                    )),
                            ],
                          ));
                    }));
              }),
        ),
        onWillPop: _onWillPop);
  }

  int calcularIndex(List<QueryDocumentSnapshot> docs, String now) {
    int count = 0;
    int index = 0;
    for (final doc in docs) {
      if (doc.id == now) {
        index = count;
      }
      count++;
    }
    return index;
  }

  List<Widget> templateContas(QueryDocumentSnapshot doc) {
    Conta conta = Conta.fromMap(doc.data());
    List<Widget> docs = [];
    for (int i = 0; i < conta.items.length; i++) {
      docs.add(ListTile(
        leading: Icon(
          IconData(conta.items[i].icon['code'], fontFamily: 'MaterialIcons'),
          color: Color(int.parse('0xff${conta.items[i].icon['color']}')),
        ),
        title: Row(
          children: [
            Text(
              '${conta.items[i].nome}: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${f.format(conta.items[i].valor)}')
          ],
        ),
        trailing: IconButton(
            icon: Icon(Icons.do_disturb_on_sharp, color: Colors.red),
            onPressed: () async {
              await database.removeItemConta(doc.id, i);
              ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
                  SnackBar(
                      content: Text(
                          '${conta.items[i].nome} removido com sucesso!')));
            }),
        onLongPress: () async {
          addConta(
              context: context,
              id: i,
              item: conta.items[i],
              onSubmit: (itemConta) async {
                await database.updateUnicoItemConta(doc.id, i, itemConta);
                ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
                    SnackBar(
                        content:
                            Text('${itemConta.nome} atualizado com sucesso!')));
                // _scaffoldKey.currentState.showSnackBar(SnackBar(
                //     content:
                //         Text('${itemConta.nome} atualizado com sucesso!')));
              });
        },
      ));
    }
    return docs;
  }

  Future<bool> _onWillPop() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Deseja sair do app?'),
            actions: [
              TextButton(
                child: Text('Sim'),
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
              TextButton(
                child: Text('Não'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<void> _deslogar() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> _buscarAno() async {
    List anos = await database.getAnos();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Selecionar outro Ano'),
            content: SingleChildScrollView(
                child: DropdownButton(
                    isExpanded: true,
                    items: anos
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Container(
                                child: Text(
                                  '$e',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (item) {
                      setState(() {
                        this._anoSelecionado = item;
                        Navigator.of(context).pop();
                      });
                    },
                    value: this._anoSelecionado)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar')),
            ],
          );
        });
  }

  Widget total(QueryDocumentSnapshot data, double totalCartoes) {
    Conta conta = Conta.fromMap(data.data());
    // double totalSemCarro =
    //     conta.total - conta.items[1].valor; // Deixar dinamicamente no futuro
    double total = totalCartoes + conta.total;
    // String totaldetalhado = '';
    // conta.items.forEach((element) {
    //   if (totaldetalhado.length != 0) {
    //     totaldetalhado += '+';
    //   }
    //   totaldetalhado += convert.doubleToCurrency(element.valor);
    // });
    // totaldetalhado += '+' + convert.doubleToCurrency(totalCartoes);

    for (var i in conta.items) {
      bool res = prefs.getBool(i.nome) ?? true;
      if (!res) {
        total -= i.valor;
      }
    }
    total = double.parse(
        total.toStringAsFixed(2)); // Arredondar com precisão de 2 digitos
    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return MostrarCartao(mes: data.id, data: data);
            }));
          },
          leading: Icon(Icons.credit_card, color: Colors.purple),
          title: Row(
            children: [
              Text(
                'Cartões: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${f.format(totalCartoes)}')
            ],
          ),
        ),
        // FloatingActionButton(
        //     mini: true, onPressed: () {}, child: Icon(Icons.add)),
        Divider(height: 5),
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('${f.format(total)}', style: TextStyle(fontSize: 18))
            ],
          ),
          onTap: () {
            Clipboard.setData(
                ClipboardData(text: '${convert.doubleToCurrency(total)}'));
            ScaffoldMessenger.of(_scaffoldKey.currentContext).showSnackBar(
                SnackBar(content: Text("${f.format(total)} copiado!")));
          },
        ),
        IconButton(
          icon: CircleAvatar(
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.green,
          ),
          onPressed: () async {
            //_showMyDialog(id: data.id);
            await addConta(
                context: context,
                onSubmit: (ItemConta item) async {
                  await database.insertItemConta(data.id, item);
                  ScaffoldMessenger.of(_scaffoldKey.currentContext)
                      .showSnackBar(SnackBar(
                          content: Text('${item.nome} Inserido com sucesso!')));
                });
          },
        )
      ],
    );
  }

  TextStyle estiloTexto() {
    return TextStyle(fontSize: 16, height: 2);
  }
}
