import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../util/database.dart';
import '../models/conta.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class Relatorio extends StatefulWidget {
  Relatorio({Key? key, required this.ano}) : super(key: key);
  final int ano;
  @override
  _RelatorioState createState() => _RelatorioState(ano: ano);
}

class _RelatorioState extends State<Relatorio> {
  _RelatorioState({required this.ano});
  final int ano;
  final db = DataBase();
  late Conta conta;
  List<QueryDocumentSnapshot> docs = [];
  Map cartoes = {};
  @override
  void initState() {
    super.initState();
  }

  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório anual'),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                height: 350,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(text: 'Half yearly sales analysis'),
                    // Enable legend
                    legend: Legend(isVisible: true),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: [
                      LineSeries<_SalesData, String>(
                          dataSource: data,
                          xValueMapper: (_SalesData sales, _) => sales.year,
                          yValueMapper: (_SalesData sales, _) => sales.sales,
                          name: 'Sales',
                          // Enable data label
                          dataLabelSettings: DataLabelSettings(isVisible: true))
                    ]) //StackedBarChart(_createSampleData(docs)),
                ),
            Container(
              width: double.infinity,
              height: 350,
              child: SfSparkBarChart(
                data: [10, 15, 0, 20, 35, 10, 15, 10],
                axisCrossesAt: 24,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
