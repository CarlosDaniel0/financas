import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conta.dart';
import '../util/database.dart';

class Configuracoes extends StatefulWidget {
  Configuracoes({Key? key, required this.id}) : super(key: key);
  final String id;
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState(id: id);
}

class _ConfiguracoesState extends State<Configuracoes> {
  _ConfiguracoesState({required this.id});
  final String id;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<bool> activeConta = [];
  List<bool> activeDetails = [];
  late SharedPreferences prefs;
  DataBase db = DataBase();
  Conta conta = Conta(items: [], mes: '', ano: 0, total: 0);
  @override
  void initState() {
    _prefs.then((res) => prefs = res);
    db.getConta(id).then((v) {
      conta = v!;
      getSelectedItems();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: ListView(
        children: [
          Card(
              child: ListTile(
            onTap: () async {
              await selecaoItens();
            },
            leading: Icon(
              Icons.add_box,
              color: Colors.amber,
              size: 35,
            ),
            title: Text(
              'Soma de itens',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text('Seleção de itens somados'),
          )),
          // Card(
          //     child: ListTile(
          //   onTap: () {
          //     selecaoDetalhada();
          //   },
          //   leading: Icon(
          //     Icons.lock_outlined,
          //     color: Colors.blueAccent,
          //     size: 35,
          //   ),
          //   title: Text(
          //     'Soma detalhada',
          //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          //   ),
          //   subtitle: Text(
          //       'Define o valor que será passado quando o total for copiado para área de transferência'),
          // ))
        ],
      ),
    );
  }

  Future<void> getSelectedItems() async {
    //print(prefs.getKeys());
    if (activeConta.length == 0) {
      for (var i in conta.items) {
        activeConta.add(prefs.getBool(i.nome) ?? true);
      }
    }
  }

  List<Widget> generateListCheck(List<bool> list, _setState) {
    List<Widget> newList = [];
    for (int i = 0; i < list.length; i++)
      newList.add(CheckboxListTile(
        title: Text(conta.items[i].nome),
        selected: list[i],
        value: list[i],
        onChanged: (value) {
          prefs.setBool(conta.items[i].nome, value!);
          _setState(() => list[i] = value);
        },
      ));
    return newList;
  }

  Future<void> selecaoItens() async {
    return showDialog(
        context: context,
        builder: (context) {
          return Builder(
            builder: (context) {
              return StatefulBuilder(builder: (_, _setState) {
                List<Widget> res = generateListCheck(activeConta, _setState);
                return AlertDialog(
                  title: Text('Contas somadas:'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [...res],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Concluir'),
                    ),
                  ],
                );
              });
            },
          );
        });
  }

  // Future<void> selecaoDetalhada() {
  //   return showDialog(
  //       context: context,
  //       builder: (conext) {
  //         return Builder(
  //           builder: (context) {
  //             return StatefulBuilder(builder: (context, setState) {
  //               return AlertDialog(
  //                 title: Text("Soma detalhada"),
  //                 content: SingleChildScrollView(
  //                   child: Column(
  //                     children: [
  //                       CheckboxListTile(
  //                         onChanged: (value) {},
  //                         value: true,
  //                         title: Text('Contas'),
  //                       ),
  //                       CheckboxListTile(
  //                         onChanged: (value) {},
  //                         value: true,
  //                         title: Text('Cartões'),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text('Concluir'),
  //                   ),
  //                 ],
  //               );
  //             });
  //           },
  //         );
  //       });
  // }
}
