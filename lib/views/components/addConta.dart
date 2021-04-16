import 'package:financas/models/conta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import '../../util/convert.dart' as convert;
import 'package:flutter_masked_text/flutter_masked_text.dart';

Future<void> addConta(
    {@required BuildContext context,
    int id,
    ItemConta item,
    Function(ItemConta) onSubmit}) {
  final _formKey = GlobalKey<FormState>();
  final _controllerValor =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  final _controllerNome = TextEditingController();
  Icon _icon = Icon(Icons.edit);
  Color _currentColor = Colors.indigo;
  String title = item == null ? 'Adicionar Item' : 'Atualizar ${item.nome}';

  return showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            if (item != null) {
              setState(() {
                _currentColor = Color(int.parse('0xff${item.icon['color']}'));
                _icon = Icon(
                    IconData(item.icon['code'], fontFamily: 'MaterialIcons'));
              });
              _controllerNome.text = item.nome;
              _controllerValor.text = convert.doubleToCurrency(item.valor);
            }

            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(children: [
                        Text('Icone: '),
                        IconButton(
                            icon: CircleAvatar(child: _icon),
                            onPressed: () async {
                              IconData icon =
                                  await FlutterIconPicker.showIconPicker(
                                context,
                                adaptiveDialog: true,
                                showTooltips: false,
                                showSearchBar: true,
                                iconPickerShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                iconPackMode: IconPack.material,
                              );
                              if (icon != null) {
                                setState(() {
                                  _icon = Icon(icon);
                                });
                              }
                            }),
                        Text('Cor: '),
                        IconButton(
                            color: _currentColor,
                            icon: CircleAvatar(
                              backgroundColor: _currentColor,
                            ),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    titlePadding: const EdgeInsets.all(0.0),
                                    contentPadding: const EdgeInsets.all(0.0),
                                    content: SingleChildScrollView(
                                      child: MaterialPicker(
                                        pickerColor: _currentColor,
                                        onColorChanged: (Color color) {
                                          setState(() => _currentColor = color);
                                          //  FocusNode.
                                          Navigator.pop(context);
                                        },
                                        enableLabel: true,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ]),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Nome'),
                        controller: _controllerNome,
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Digite o nome do item";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Valor'),
                          controller: _controllerValor,
                          validator: (text) {
                            if (text.isEmpty) {
                              return "Digite o valor do item";
                            }
                            if (text.split(',').length != 2) {
                              return "Digite um formato de valor válido!";
                            }
                            return null;
                          })
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancelar')),
                TextButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        // Atualizar valor
                        onSubmit(ItemConta(
                            icon: {
                              'code': _icon.icon.codePoint,
                              'color':
                                  _currentColor.toString().substring(10, 16)
                            },
                            nome: _controllerNome.text,
                            valor: convert
                                .currencyToDouble(_controllerValor.text)));
                        setState(() {});

                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Adicionar'))
              ],
            );
          });
        });
      });
}
