import 'package:flutter/material.dart';
import '../models/conta.dart';
import '../util/database.dart';
import 'package:intl/intl.dart';
import './components/addConta.dart';

class AdicionarConta extends StatefulWidget {
  AdicionarConta(
      {Key? key, required this.id, required this.mes, required this.ano})
      : super(key: key);
  final String id;
  final String mes;
  final int ano;
  @override
  _AdicionarContaState createState() =>
      _AdicionarContaState(id: id, mes: mes, ano: ano);
}

class _AdicionarContaState extends State<AdicionarConta> {
  _AdicionarContaState(
      {required this.id, required this.mes, required this.ano});
  final String id;
  final String mes;
  final int ano;
  List<ItemConta> items = [];
  var f = new NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    int _index = 0;
    DataBase db = DataBase();
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar $mes $ano')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await addConta(
              context: context,
              onSubmit: (itemConta) {
                items.add(itemConta);
              });
          setState(() => null);
          //_showMyDialog();
        },
      ),
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                IconData(items[index].icon['code'],
                    fontFamily: 'MaterialIcons'),
                color: Color(int.parse('0xff${items[index].icon['color']}')),
              ),
              title: Row(
                children: [
                  Text('${items[index].nome}: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${f.format(items[index].valor)}')
                ],
              ),
              onLongPress: () async {
                await addConta(
                    context: context,
                    id: index,
                    item: items[index],
                    onSubmit: (itemConta) {
                      items.removeAt(index);
                      items.add(itemConta);
                    });
                setState(() {});
                //_showMyDialog(id: index, item: items[index]);
              },
              trailing: IconButton(
                icon: Icon(
                  Icons.do_disturb_on_sharp,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    items.removeAt(index);
                  });
                },
              ),
            );
          }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (item) {
          switch (item) {
            case 0:
              setState(() {
                items = [
                  ItemConta(icon: {
                    'code': Icons.water_drop_sharp.codePoint,
                    'color': '2196f3'
                  }, nome: 'Água', valor: 34.27),
                  ItemConta(icon: {
                    'code': Icons.time_to_leave.codePoint,
                    'color': '607d8b'
                  }, nome: 'Carro', valor: 830.92),
                  ItemConta(icon: {
                    'code': Icons.language.codePoint,
                    'color': '3f51b5'
                  }, nome: 'Internet', valor: 75),
                  ItemConta(icon: {
                    'code': Icons.lightbulb_rounded.codePoint,
                    'color': 'f4511e'
                  }, nome: 'Luz', valor: 100.14),
                  ItemConta(
                      icon: {'code': Icons.moped.codePoint, 'color': 'f44336'},
                      nome: 'Moto',
                      valor: 133.16),
                  ItemConta(icon: {
                    'code': Icons.verified_user.codePoint,
                    'color': '4caf50'
                  }, nome: 'Plano de Saúde', valor: 260.80),
                  ItemConta(
                      icon: {'code': Icons.phone.codePoint, 'color': '2196f3'},
                      nome: 'Telefone',
                      valor: 40.00)
                ];
                _index = 0;
                print(Icons.lightbulb_sharp.codePoint);
                print(Icons.lightbulb_rounded.codePoint);
              });
              break;
            case 1:
              setState(() {
                items = [];
                _index = 1;
              });
              break;
            case 2:
              db
                  .insertConta(
                      id, Conta(ano: ano, mes: mes, items: items, total: 0))
                  .then((value) => print('ok'))
                  .catchError((onError) => print(onError));
              _index = 2;
              Navigator.pop(context);
              break;
          }
        },
        items: [
          BottomNavigationBarItem(label: 'Padrão', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: 'Recarregar',
            icon: Icon(Icons.replay),
          ),
          BottomNavigationBarItem(label: 'Enviar', icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
