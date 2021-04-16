import '../../models/cartao.dart';
import 'package:flutter/material.dart';
import '../../util/convert.dart' as convert;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

Future<void> addCartao(
    {@required BuildContext context,
    int id,
    ItemCartao item,
    Function(ItemCartao) onSubmit}) {
  final _formKey = GlobalKey<FormState>();
  final _controllerParcela = TextEditingController();
  final _controllerValor =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');
  bool isNegative = false;
  final _controllerItem = TextEditingController();
  var maskParcela = new MaskTextInputFormatter(
      mask: '##/##', filter: {"#": RegExp(r'[0-9]')});

  String title = 'Adicionar Item';
  if (item != null) {
    title = 'Atualizar ${item.item}';
    _controllerParcela.text = item.parcela;
    _controllerItem.text = item.item;
    _controllerValor.text = convert.doubleToCurrency(item.valor);
    isNegative = item.valor < 0;
  }

  return showDialog(
      context: context,
      builder: (context) {
        return Builder(
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: ListBody(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Parcela', hintText: '01/10'),
                          controller: _controllerParcela,
                          inputFormatters: [maskParcela],
                          validator: (text) {
                            if (text.isEmpty) {
                              return 'Digite a parcela!';
                            }

                            if (text.split('/').length != 2) {
                              return 'Formato inválido. Ex: 01/10';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Item'),
                          controller: _controllerItem,
                          validator: (text) {
                            if (text.isEmpty) {
                              return 'Digite o nome do Item!';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Valor',
                              suffixIcon: IconButton(
                                icon: isNegative
                                    ? Icon(
                                        Icons.remove,
                                        color: Colors.indigo,
                                        semanticLabel: 'Menos',
                                      )
                                    : Icon(Icons.add,
                                        color: Colors.indigo,
                                        semanticLabel: 'Mais'),
                                tooltip: 'Definir sinal (+/-)',
                                onPressed: () {
                                  setState(() => isNegative = !isNegative);
                                },
                              )),
                          controller: _controllerValor,
                          keyboardType: TextInputType.number,
                          validator: (text) {
                            if (text.isEmpty) {
                              return 'Digite o Valor!';
                            }
                            if (text.split(',').length != 2) {
                              return 'Digite um valor válido';
                            }
                            return null;
                          },
                        )
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
                          onSubmit(ItemCartao(
                              item: _controllerItem.text,
                              parcela: _controllerParcela.text,
                              valor: isNegative
                                  ? -convert
                                      .currencyToDouble(_controllerValor.text)
                                  : convert.currencyToDouble(
                                      _controllerValor.text)));
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Adicionar'))
                ],
              );
            });
          },
        );
      });
}
