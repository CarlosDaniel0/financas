import 'package:financas/views/components/addCartao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../util/database.dart';
import '../util/generate.dart' as gn;
import '../models/conta.dart';
import 'package:intl/intl.dart';
import '../models/cartao.dart';

class AdicionarCartao extends StatefulWidget {
  AdicionarCartao({Key? key, required this.mes}) : super(key: key);
  final String mes;
  @override
  _AdicionarCartaoState createState() => _AdicionarCartaoState(mes: mes);
}

class _AdicionarCartaoState extends State<AdicionarCartao> {
  _AdicionarCartaoState({required this.mes});
  final String mes;
  Color _currentColorText = Colors.indigo;
  Color _currentColorBackground = Colors.red;
  List<ItemCartao> itensCartao = [];
  TextEditingController _controllerId = TextEditingController();
  TextEditingController _controllerNome = TextEditingController();
  DataBase db = DataBase();
  var f = new NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  Future<void> enviarCartao() async {
    Conta? conta = await db.getConta(mes);
    Cartao cartao = Cartao(
        descricao: [...itensCartao],
        nome: _controllerNome.text,
        style: {
          'background': _currentColorBackground.toString().substring(10, 16),
          'text': _currentColorText.toString().substring(10, 16)
        },
        total: 0);

    Map<String, dynamic> data =
        gn.parcelas(mes, conta!, _controllerId.text, cartao);
    db.runBatch(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Novo Cartao')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addCartao(
              context: context,
              onSubmit: (ItemCartao item) {
                itensCartao.add(item);
                setState(() {});
              });
        },
        child: Icon(Icons.add),
      ),
      body: ListView(children: [
        TextField(
          controller: _controllerId,
          decoration: InputDecoration(hintText: 'hipercard', labelText: 'id'),
        ),
        TextField(
          controller: _controllerNome,
          decoration: InputDecoration(
              hintText: 'Hipercard', labelText: 'Nome do Cartão'),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: _currentColorText,
                    borderRadius: BorderRadius.circular(45)),
                child: TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.text_fields,
                          color: _currentColorText == Colors.white
                              ? Colors.black
                              : Colors.white,
                        ),
                        Text(
                          'Cor do Texto',
                          style: TextStyle(
                              color: _currentColorText == Colors.white
                                  ? Colors.black
                                  : Colors.white),
                        )
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            titlePadding: const EdgeInsets.all(0.0),
                            contentPadding: const EdgeInsets.all(0.0),
                            content: SingleChildScrollView(
                              child: MaterialPicker(
                                pickerColor: _currentColorText,
                                onColorChanged: (Color color) {
                                  setState(() => _currentColorText = color);
                                  Navigator.pop(context);
                                },
                                enableLabel: true,
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ),
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    color: _currentColorBackground,
                    borderRadius: BorderRadius.circular(45)),
                child: TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.format_paint,
                          color: _currentColorBackground == Colors.white
                              ? Colors.black
                              : Colors.white,
                        ),
                        Text(
                          'Cor do Fundo',
                          style: TextStyle(
                              color: _currentColorBackground == Colors.white
                                  ? Colors.black
                                  : Colors.white),
                        )
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            titlePadding: const EdgeInsets.all(0.0),
                            contentPadding: const EdgeInsets.all(0.0),
                            content: SingleChildScrollView(
                              child: MaterialPicker(
                                pickerColor: _currentColorBackground,
                                onColorChanged: (Color color) {
                                  setState(
                                      () => _currentColorBackground = color);
                                  Navigator.pop(context);
                                },
                                enableLabel: true,
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ),
            )
          ],
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: itensCartao.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                        flex: 2, child: Text('${itensCartao[index].item}')),
                    Expanded(
                        flex: 3, child: Text('${itensCartao[index].parcela}')),
                    Expanded(
                        flex: 2,
                        child: Text('${f.format(itensCartao[index].valor)}')),
                  ],
                ),
                onLongPress: () async {
                  addCartao(
                      context: context,
                      item: itensCartao[index],
                      id: index,
                      onSubmit: (ItemCartao item) {
                        itensCartao.removeAt(index);
                        itensCartao.add(item);
                        setState(() {});
                      });
                },
                trailing: IconButton(
                  icon: Icon(Icons.do_disturb_on_sharp, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      itensCartao.removeAt(index);
                    });
                  },
                ),
              );
            })
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              setState(() {
                _controllerId.text = 'hipercard';
                _controllerNome.text = 'Hipercard';
              });
              break;
            case 1:
              setState(() {
                itensCartao = [];
                _controllerId.text = '';
                _controllerNome.text = '';
              });
              break;
            case 2:
              enviarCartao();
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Padrão'),
          BottomNavigationBarItem(icon: Icon(Icons.replay), label: 'Resetar'),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Enviar')
        ],
      ),
    );
  }
}
