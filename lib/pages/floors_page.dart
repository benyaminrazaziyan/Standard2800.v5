import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../engine.dart';
import '../state.dart';

class FloorsPage extends StatefulWidget {
  final AppState state;

  const FloorsPage({
    super.key,
    required this.state,
  });

  @override
  State<FloorsPage> createState() => _FloorsPageState();
}

class _FloorsPageState extends State<FloorsPage> {
  SeismicInput get inp => widget.state.input;

  late List<_FloorCtrl> ctrls;

  @override
  void initState() {
    super.initState();
    ctrls = [
      for (final floor in inp.floors) _FloorCtrl(floor),
    ];
  }

  void _syncBack() {
    inp.floors
      ..clear()
      ..addAll(ctrls.map((c) => c.floor));

    widget.state.refresh();
  }

  void _addFloor() {
    setState(() {
      final lastHeight =
          ctrls.isEmpty ? 0.0 : ctrls.last.floor.height;

      final floor = Floor(300, lastHeight + 4);

      ctrls.add(_FloorCtrl(floor));
      _syncBack();
    });
  }

  void _removeFloor(int index) {
    if (ctrls.length <= 1) return;

    setState(() {
      final removed = ctrls.removeAt(index);
      removed.dispose();
      _syncBack();
    });
  }

  void _updateHeight(int index, String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));

    if (value == null || !value.isFinite || value <= 0) {
      return;
    }

    setState(() {
      ctrls[index].floor.height = value;
      _syncBack();
    });
  }

  void _updateWeight(int index, String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));

    if (value == null || !value.isFinite || value <= 0) {
      return;
    }

    setState(() {
      ctrls[index].floor.weight = value;
      _syncBack();
    });
  }

  @override
  void dispose() {
    for (final ctrl in ctrls) {
      ctrl.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final result = compute(inp);
    final totalWeight = inp.weight;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      children: [
        Row(
          children: [
            Icon(
              Icons.apartment,
              color: scheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'وزن مؤثر لرزه‌ای طبقات',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('طبقه'),
              onPressed: _addFloor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Column(
            children: [
              for (var i = 0; i < ctrls.length; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ctrls[i].h,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'hi (m)',
                            isDense: true,
                          ),
                          onChanged: (text) =>
                              _updateHeight(i, text),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ctrls[i].w,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Wi (ton)',
                            isDense: true,
                          ),
                          onChanged: (text) =>
                              _updateWeight(i, text),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                        ),
                        onPressed: ctrls.length > 1
                            ? () => _removeFloor(i)
                            : null,
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.scale_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'وزن کل W = ${fmt(totalWeight, 1)} ton',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'K = ${fmt(result.k)}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (result.fi.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'نیروی جانبی هر طبقه Fi (ton)',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: Card(
              color: scheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
                child: BarChart(
                  BarChartData(
                    maxY: result.fi.reduce(max) * 1.25,
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'ط${value.toInt() + 1}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < result.fi.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: result.fi[i],
                              width: 20,
                              borderRadius: BorderRadius.circular(5),
                              color: scheme.primary,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
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

  late final TextEditingController h;
  late final TextEditingController w;

  _FloorCtrl(this.floor) {
    h = TextEditingController(
      text: floor.height.toString(),
    );

    w = TextEditingController(
      text: floor.weight.toString(),
    );
  }

  void dispose() {
    h.dispose();
    w.dispose();
  }
}
