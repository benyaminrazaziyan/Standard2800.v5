import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../engine.dart';
import '../report.dart';
import '../state.dart';
import 'widgets.dart';

class ResultsPage extends StatefulWidget {
  final AppState state;
  const ResultsPage({super.key, required this.state});
  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  Widget build(BuildContext context) {
    final inp = widget.state.input;
    final r = compute(inp);
    final scheme = Theme.of(context).colorScheme;
    const maxT = 3.0;
    final pts = spectrum(r.sds, r.sd1, maxT);
    final maxSa = pts.map((p) => p.sa).reduce(max) * 1.15;

    final tiles = <Widget>[
      ResultTile(label: 'SMS', value: fmt(r.sms), unit: 'g'),
      ResultTile(label: 'SM1', value: fmt(r.sm1), unit: 'g'),
      ResultTile(label: 'SDS', value: fmt(r.sds), unit: 'g', highlight: true),
      ResultTile(label: 'SD1', value: fmt(r.sd1), unit: 'g', highlight: true),
      ResultTile(label: 'T0', value: fmt(r.t0), unit: 's'),
      ResultTile(label: 'Ts', value: fmt(r.ts), unit: 's'),
      ResultTile(label: 'Te تجربی', value: fmt(r.te), unit: 's'),
      ResultTile(label: 'T محاسباتی', value: fmt(r.t), unit: 's', highlight: true),
      ResultTile(label: 'Sa', value: fmt(r.sa), unit: 'g', highlight: true),
      ResultTile(label: 'C = Sa/(Ru/Ie)', value: fmt(r.cFromSa)),
      ResultTile(label: 'Cmin (3-4)', value: fmt(r.cmin1)),
      ResultTile(label: 'Cmin (3-5)', value: r.cmin2 > 0 ? fmt(r.cmin2) : '—'),
      ResultTile(label: 'C نهایی', value: fmt(r.cFinal), highlight: true),
      ResultTile(label: 'K توزیع ارتفاع', value: fmt(r.k)),
      ResultTile(label: 'W', value: fmt(r.w, 1), unit: 'ton'),
      ResultTile(label: 'V برش پایه', value: fmt(r.v, 2), unit: 'ton', highlight: true),
      ResultTile(label: 'Fvt نیروی قائم', value: fmt(r.fvt, 2), unit: 'ton'),
      ResultTile(label: 'SDC', value: '${r.sdc}', color: r.sdc == 3 ? scheme.error : scheme.primary),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
      children: [
        if (r.cminGoverns)
          Card(
            color: scheme.tertiaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: const ListTile(
              leading: Icon(Icons.warning_amber_rounded),
              title: Text('کنترل برش پایه حداقل حاکم است', style: TextStyle(fontSize: 13.5)),
              subtitle: Text('بند 3-9-1-2: C نهایی برابر حداقل ضریب زلزله در نظر گرفته شد.', style: TextStyle(fontSize: 12)),
            ),
          ),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: tiles,
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
            child: Column(children: [
              Text('طیف طرح استاندارد — نقطه طراحی T = ${fmt(r.t)} s',
                  style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
              const SizedBox(height: 8),
              SizedBox(
                height: 240,
                child: LineChart(LineChartData(
                  minX: 0, maxX: maxT, minY: 0, maxY: maxSa,
                  gridData: const FlGridData(show: true, drawVerticalLine: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, interval: 0.5, reservedSize: 26,
                      getTitlesWidget: (v, m) => Text(v.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10)),
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 36,
                      getTitlesWidget: (v, m) => Text(v.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10)),
                    )),
                  ),
                  extraLinesData: ExtraLinesData(verticalLines: [
                    VerticalLine(x: r.t, color: Colors.red.withOpacity(0.55),
                        dashArray: const [6, 4], strokeWidth: 1),
                  ]),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [for (final p in pts) FlSpot(p.t, p.sa)],
                      isCurved: false,
                      barWidth: 3,
                      color: scheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: scheme.primary.withOpacity(0.10),
                      ),
                    ),
                    LineChartBarData(
                      spots: [FlSpot(r.t, r.sa)],
                      barWidth: 0,
                      dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) =>
                          FlDotCirclePainter(radius: 6, color: Colors.red,
                              strokeWidth: 2, strokeColor: Colors.white)),
                    ),
                  ],
                )),
              ),
            ]),
          ),
        ),
        if (r.fi.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('توزیع نیروی جانبی در ارتفاع — رابطه 3-12',
                      style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStatePropertyAll(scheme.primaryContainer),
                    columns: const [
                      DataColumn(label: Text('طبقه')),
                      DataColumn(label: Text('hi (m)')),
                      DataColumn(label: Text('Wi (ton)')),
                      DataColumn(label: Text('Fi (ton)')),
                      DataColumn(label: Text('Vi (ton)')),
                    ],
                    rows: [
                      for (var i = inp.floors.length - 1; i >= 0; i--)
                        DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(fmt(inp.floors[i].height, 1))),
                          DataCell(Text(fmt(inp.floors[i].weight, 1))),
                          DataCell(Text(fmt(r.fi[i], 2), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(fmt(r.vi[i], 2))),
                        ]),
                      DataRow(cells: [
                        const DataCell(Text('Σ', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('')),
                        DataCell(Text(fmt(r.w, 1))),
                        DataCell(Text(fmt(r.fi.fold(0.0, (a, b) => a + b), 2),
                            style: const TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('')),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.share),
            label: const Text('تهیه و اشتراک‌گذاری گزارش HTML حرفه‌ای',
                style: TextStyle(fontSize: 15)),
            onPressed: () async {
              await shareReport(inp, r);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'مقادیر Ru، Ω₀، Cd و Hm به‌صورت پیش‌فرض از جدول 3-1 بارگذاری می‌شوند و از صفحه ورودی قابل ویرایش‌اند. برای زمین نوع VI طیف ویژه ساختگاه الزامی است.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
