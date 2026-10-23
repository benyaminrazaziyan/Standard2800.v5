import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../engine.dart';
import '../state.dart';

class FloorsPage extends StatefulWidget {
  final AppState state;
  const FloorsPage({super.key, required this.state});
  @override
  State<FloorsPage> createState() => _FloorsPageState();
}

class _FloorsPageState extends State<FloorsPage> {
  SeismicInput get inp => widget.state.input;
  late List<_FloorCtrl> ctrls;

  @override
  void initState() {
    super.initState();
    ctrls = [for (final f in inp.floors) _FloorCtrl(f)];
  }

  void _syncBack() {
    inp.floors
      ..clear()
      ..addAll([for (final c in ctrls) Floor(c.w, c.h)]);
    widget.state.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = compute(inp);
    final wTotal = inp.weight;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      children: [
        Row(
          children: [
            Icon(Icons.apartment, color: scheme.primary),
            const SizedBox(width: 8),
            Text('وزن مؤثر لرزه‌ای طبقات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: scheme.primary)),
            const Spacer(),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('طبقه'),
              onPressed: () => setState(() {
                final lastH = ctrls.isEmpty ? 0.0 : ctrls.last.h;
                ctrls.add(_FloorCtrl(Floor(300, lastH + 4)));
                _syncBack();
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: scheme.surfaceContainerHighest.withOpacity(0.5),
          child: Column(children: [
            for (var i = 0; i < ctrls.length; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: Row(children: [
                  Container(
                    width: 34, height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text('${i + 1}', style: TextStyle(
                        fontWeight: FontWeight.bold, color: scheme.primary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(
                    controller: ctrls[i].h,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'hi (m)', isDense: true),
                    onChanged: (s) {
                      final v = double.tryParse(s.replaceAll(',', '.'));
                      if (v != null) { ctrls[i].floor.height = v; _syncBack(); }
                    },
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(
                    controller: ctrls[i].w,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Wi (ton)', isDense: true),
                    onChanged: (s) {
                      final v = double.tryParse(s.replaceAll(',', '.'));
                      if (v != null) { ctrls[i].floor.weight = v; _syncBack(); }
                    },
                  )),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: ctrls.length > 1 ? () => setState(() {
                      ctrls.removeAt(i);
                      _syncBack();
                    }) : null,
                  ),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const Icon(Icons.scale_outlined, size: 18),
                const SizedBox(width: 6),
                Text('وزن کل W = ${fmt(wTotal, 1)} ton',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('K = ${fmt(r.k)}', style: TextStyle(color: scheme.onSurfaceVariant)),
              ]),
            ),
          ]),
        ),
        if (r.fi.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('نیروی جانبی هر طبقه Fi (ton)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: scheme.primary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: Card(
              color: scheme.surfaceContainerHighest.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
                child: BarChart(BarChartData(
                  maxY: r.fi.reduce(max) * 1.25,
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 40,
                      getTitlesWidget: (v, m) => Text(v.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10)),
                    )),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('ط${v.toInt() + 1}',
                            style: const TextStyle(fontSize: 10)),
                      ),
                    )),
                  ),
                  barGroups: [
                    for (var i = 0; i < r.fi.length; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: r.fi[i],
                          width: 20,
                          borderRadius: BorderRadius.circular(5),
                          color: scheme.primary,
                        ),
                      ]),
                  ],
                )),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FloorCtrl {
  final Floor floor;
  late final TextEditingController h = TextEditingController(text: floor.height.toStringAsFixed(1));
  late final TextEditingController w = TextEditingController(text: floor.weight.toStringAsFixed(0));
  _FloorCtrl(this.floor);
}
