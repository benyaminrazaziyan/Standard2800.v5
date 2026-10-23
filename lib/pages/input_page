import 'package:flutter/material.dart';
import '../engine.dart';
import '../data.dart';
import '../state.dart';
import 'widgets.dart';

class InputPage extends StatefulWidget {
  final AppState state;
  final VoidCallback onGoResults;
  const InputPage({super.key, required this.state, required this.onGoResults});
  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  SeismicInput get inp => widget.state.input;

  void _refresh() => setState(() {});

  void _applySiteClass(String? c) {
    if (c == null) return;
    setState(() {
      inp.siteClass = c;
      // Type VI requires a site-specific study: never silently substitute Type IV.
      if (c != 'VI') {
        inp.fs = double.parse(suggestedFs(c, inp.ss).toStringAsFixed(3));
        inp.f1 = double.parse(suggestedF1(c, inp.s1).toStringAsFixed(3));
      }
    });
    widget.state.refresh();
    if (c == 'VI') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('زمین نوع VI: باید Fs و F1 بر اساس مطالعه ویژه ساختگاه وارد شوند؛ مقادیر قبلی به‌صورت خودکار جایگزین نشده‌اند.'),
        duration: Duration(seconds: 6),
      ));
    }
  }

  void _applySystem(int? i) {
    if (i == null) return;
    setState(() {
      inp.systemIndex = i;
      final s = systems[i];
      inp.ru = s.ru;
      inp.omega0 = s.omega0;
      inp.cd = s.cd;
    });
    widget.state.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        SectionCard(icon: Icons.domain, title: '۱) مشخصات ساختمان', children: [
          NumField(label: 'ارتفاع ساختمان H', suffix: 'm',
              value: inp.height, onChanged: (v) { inp.height = v; widget.state.refresh(); }),
          NumField(label: 'دوره تناوب تحلیلی Ta (ETABS)', suffix: 'sec',
              value: inp.ta, onChanged: (v) { inp.ta = v; widget.state.refresh(); }),
          DropdownButtonFormField<double>(
            value: inp.importance,
            decoration: const InputDecoration(labelText: 'ضریب اهمیت Ie (گروه ساختمان)'),
            items: const [
              DropdownMenuItem(value: 1.0, child: Text('1.0 — گروه ۳ (متوسط)')),
              DropdownMenuItem(value: 1.2, child: Text('1.2 — گروه ۲ (زیاد)')),
              DropdownMenuItem(value: 1.4, child: Text('1.4 — گروه ۱ ضروری (خیلی زیاد)')),
              DropdownMenuItem(value: 1.5, child: Text('1.5 — گروه ۱ خطرزا (خیلی زیاد)')),
            ],
            onChanged: (v) => setState(() { inp.importance = v ?? 1.0; widget.state.refresh(); }),
          ),
          SwitchListTile(
            title: const Text('میانقاب‌ها مانع حرکت جانبی قاب هستند'),
            subtitle: const Text('در صورت بله، Te طبق رابطه میانقاب‌دار (رابطه 3-9)'),
            value: inp.infillObstructs,
            onChanged: (v) => setState(() { inp.infillObstructs = v; widget.state.refresh(); }),
          ),
        ]),

        SectionCard(icon: Icons.public, title: '۲) انتخاب شهر و خطر لرزه‌ای', children: [
          DropdownButtonFormField<String>(
            value: inp.city,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'مرحله اول: شهر محل پروژه را انتخاب کنید'),
            items: (iranCities.toSet().toList()..sort()).map((city) => DropdownMenuItem<String>(value: city, child: Text(city))).toList(),
            onChanged: (v) => setState(() { if (v != null) inp.city = v; widget.state.refresh(); }),
          ),
          const SizedBox(height: 10),
          const Text('مرحله دوم: نقشه رسمی ویرایش پنجم را در محل شهر انتخاب‌شده بررسی کنید و مقدار نزدیک‌ترین خط هم‌مقدار را انتخاب کنید. این نقشه فقط شتاب طیفی در دوره ۱ ثانیه را نشان می‌دهد؛ انتخاب شهر به‌تنهایی مقدار دقیق را تعیین نمی‌کند.'),
          const SizedBox(height: 10),
          DropdownButtonFormField<double>(
            value: mapS1Values.contains(inp.s1) ? inp.s1 : 0.60,
            decoration: const InputDecoration(labelText: 'S1 — شتاب طیفی در دوره ۱ ثانیه (g)، از روی نقشه'),
            items: mapS1Values.map((v) => DropdownMenuItem<double>(value: v, child: Text('${v.toStringAsFixed(2)} g'))).toList(),
            onChanged: (v) { if (v != null) setState(() { inp.s1 = v; _applySiteClass(inp.siteClass); }); },
          ),
          const SizedBox(height: 10),
          NumField(label: 'Ss — شتاب طیفی در دوره کوتاه (g)، منبع جداگانه', value: inp.ss,
              onChanged: (v) { inp.ss = v; _applySiteClass(inp.siteClass); }),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: inp.siteClass,
            decoration: const InputDecoration(labelText: 'نوع زمین (جدول 2-5)'),
            items: siteClassNames.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: _applySiteClass,
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: NumField(label: 'Fs', value: inp.fs,
                onChanged: (v) { inp.fs = v; widget.state.refresh(); })),
            const SizedBox(width: 10),
            Expanded(child: NumField(label: 'F1', value: inp.f1,
                onChanged: (v) { inp.f1 = v; widget.state.refresh(); })),
          ]),
          TextButton.icon(
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('پیشنهاد خودکار Fs و F1 از جداول 2-1 و 2-2'),
            onPressed: () {
              if (inp.siteClass == 'VI') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('برای زمین نوع VI پیشنهاد خودکار وجود ندارد؛ Fs و F1 را بر اساس مطالعه ویژه ساختگاه وارد کنید.'),
                ));
              } else {
                _applySiteClass(inp.siteClass);
              }
            },
          ),
        ]),

        SectionCard(icon: Icons.account_tree, title: '۳) سیستم سازه‌ای (جدول 3-1)', children: [
          DropdownButtonFormField<int>(
            value: inp.systemIndex,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'سیستم مقاوم لرزه‌ای'),
            items: [
              for (var i = 0; i < systems.length; i++)
                DropdownMenuItem(value: i, child: Text('[${systems[i].group}] ${systems[i].name}', softWrap: true)),
            ],
            onChanged: _applySystem,
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'حداکثر ارتفاع مجاز (SDC-1 / SDC-2 / SDC-3): ${inp.system.hmax}',
              style: TextStyle(fontSize: 12.5, color: scheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: NumField(label: 'ضریب رفتار Ru', value: inp.ru,
                onChanged: (v) { inp.ru = v; widget.state.refresh(); })),
            const SizedBox(width: 10),
            Expanded(child: NumField(label: 'Ω₀', value: inp.omega0, decimals: 2,
                onChanged: (v) { inp.omega0 = v; widget.state.refresh(); })),
            const SizedBox(width: 10),
            Expanded(child: NumField(label: 'Cd', value: inp.cd, decimals: 2,
                onChanged: (v) { inp.cd = v; widget.state.refresh(); })),
          ]),
        ]),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('محاسبه و نمایش نتایج', style: TextStyle(fontSize: 16)),
            onPressed: widget.onGoResults,
          ),
        ),
      ],
    );
  }
}
