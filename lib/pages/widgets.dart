import 'package:flutter/material.dart';
import '../engine.dart';

class NumField extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? suffix;
  final int decimals;
  const NumField({
    super.key, required this.label, required this.value,
    required this.onChanged, this.suffix, this.decimals = 3,
  });
  @override
  State<NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<NumField> {
  late final TextEditingController c;
  @override
  void initState() {
    super.initState();
    c = TextEditingController(text: widget.value.toStringAsFixed(widget.decimals));
  }
  @override
  void didUpdateWidget(covariant NumField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        (double.tryParse(c.text.replaceAll(',', '.')) ?? -1e18) != widget.value) {
      c.text = widget.value.toStringAsFixed(widget.decimals);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.suffix,
        ),
        onChanged: (s) {
          final v = double.tryParse(s.replaceAll('٬', '').replaceAll(',', '.'));
          if (v != null) widget.onChanged(v);
        },
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const SectionCard({super.key, required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerHighest.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: scheme.primary)),
            ]),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool highlight;
  final Color? color;
  const ResultTile({
    super.key, required this.label, required this.value,
    this.unit, this.highlight = false, this.color,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? (highlight ? scheme.primary : scheme.onSurface);
    return Card(
      color: highlight ? scheme.primaryContainer : scheme.surfaceContainerHighest.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(fit: BoxFit.scaleDown, child: Text(label,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant))),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, child: Text(
              value + (unit == null ? '' : ' $unit'),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: c),
            )),
          ],
        ),
      ),
    );
  }
}

String fmt0(num v) => fmt(v);
