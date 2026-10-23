import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'engine.dart';
import 'data.dart';

Future<void> shareReport(SeismicInput inp, SeismicResults r) async {
  final html = buildReportHtml(inp, r);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/seismic2800_v5_report.html');
  await file.writeAsString(html, encoding: utf8);
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'گزارش محاسبه ضریب زلزله — استاندارد 2800 ویرایش 5',
  );
}

String _row(String k, String v) => '<tr><th>$k</th><td>$v</td></tr>';

String _svgSpectrum(SeismicResults r, double maxT) {
  final pts = spectrum(r.sds, r.sd1, maxT);
  final maxSa = pts.map((p) => p.sa).reduce((a, b) => a > b ? a : b) * 1.1;
  const w = 720.0, h = 340.0, ml = 52.0, mb = 40.0, mt = 14.0;
  double sx(double t) => ml + (w - ml - 12) * (t / maxT);
  double sy(double sa) => mt + (h - mb - mt) * (1 - sa / maxSa);
  final sb = StringBuffer();
  sb.write('<polyline fill="none" stroke="#0f766e" stroke-width="2.5" points="');
  for (final p in pts) {
    sb.write('${sx(p.t).toStringAsFixed(1)},${sy(p.sa).toStringAsFixed(1)} ');
  }
  sb.write('"/>');
  final xt = sx(r.t), ys = sy(r.sa);
  sb.write('<circle cx="$xt" cy="$ys" r="5.5" fill="#dc2626"/>');
  sb.write('<line x1="$xt" y1="${h - mb}" x2="$xt" y2="$ys" stroke="#dc2626" stroke-dasharray="5 4" stroke-width="1.4"/>');
  sb.write('<line x1="$ml" y1="$ys" x2="$xt" y2="$ys" stroke="#dc2626" stroke-dasharray="5 4" stroke-width="1.4"/>');
  sb.write('<text x="${(xt + 7).toStringAsFixed(0)}" y="${(ys - 8).toStringAsFixed(0)}" font-size="12" fill="#dc2626">T=${fmt(r.t)} s , Sa=${fmt(r.sa)} g</text>');
  var x = 0.0;
  while (x <= maxT + 1e-6) {
    sb.write('<line x1="${sx(x).toStringAsFixed(1)}" y1="${h - mb}" x2="${sx(x).toStringAsFixed(1)}" y2="${h - mb + 5}" stroke="#333"/>');
    sb.write('<text x="${(sx(x) - 8).toStringAsFixed(1)}" y="${(h - mb + 18).toStringAsFixed(1)}" font-size="11" fill="#333">${x.toStringAsFixed(1)}</text>');
    x += 0.5;
  }
  var y = 0.0;
  final stepY = maxSa > 1.2 ? 0.5 : 0.2;
  while (y <= maxSa + 1e-6) {
    sb.write('<line x1="${ml - 5}" y1="${sy(y).toStringAsFixed(1)}" x2="$ml" y2="${sy(y).toStringAsFixed(1)}" stroke="#333"/>');
    sb.write('<text x="8" y="${(sy(y) + 4).toStringAsFixed(1)}" font-size="11" fill="#333">${y.toStringAsFixed(1)}</text>');
    y += stepY;
  }
  sb.write('<line x1="$ml" y1="$mt" x2="$ml" y2="${h - mb}" stroke="#333" stroke-width="1.4"/>');
  sb.write('<line x1="$ml" y1="${h - mb}" x2="${w - 10}" y2="${h - mb}" stroke="#333" stroke-width="1.4"/>');
  sb.write('<text x="${(w / 2 - 60).toStringAsFixed(0)}" y="${(h - 6).toStringAsFixed(0)}" font-size="12" fill="#333">دوره تناوب T (ثانیه)</text>');
  return '<svg xmlns="http://www.w3.org/2000/svg" width="$w" height="$h" '
      'style="background:#f8fafc;border:1px solid #cbd5e1;border-radius:10px">$sb</svg>';
}

String buildReportHtml(SeismicInput inp, SeismicResults r) {
  final sys = inp.system;
  final buf = StringBuffer();
  buf.write('''<!DOCTYPE html><html lang="fa" dir="rtl"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>گزارش محاسبه ضریب زلزله — 2800 ویرایش 5</title>
<style>
body{font-family:Tahoma,'Segoe UI',sans-serif;background:#f1f5f9;color:#0f172a;margin:0;padding:24px}
.sheet{max-width:860px;margin:auto;background:#fff;border-radius:16px;padding:32px;box-shadow:0 6px 24px rgba(2,44,34,.12)}
h1{font-size:20px;color:#0f766e;margin:0 0 4px}
h2{font-size:15px;color:#0f766e;border-right:4px solid #0f766e;padding-right:8px;margin:26px 0 10px}
.sub{color:#64748b;font-size:12px;margin-bottom:18px}
table{width:100%;border-collapse:collapse;font-size:13px;margin-bottom:10px}
th,td{border:1px solid #cbd5e1;padding:7px 10px;text-align:right}
th{background:#ecfeff;width:55%;font-weight:600;color:#134e4a}
.badge{display:inline-block;background:#0f766e;color:#fff;border-radius:999px;padding:4px 14px;font-size:13px}
.warn{background:#fef3c7;border:1px solid #f59e0b;border-radius:10px;padding:10px 14px;font-size:12.5px;color:#92400e;margin:10px 0}
.note{background:#e0f2fe;border:1px solid #38bdf8;border-radius:10px;padding:10px 14px;font-size:12px;color:#075985;margin:10px 0}
footer{margin-top:26px;font-size:11px;color:#94a3b8;border-top:1px dashed #cbd5e1;padding-top:12px}
</style></head><body><div class="sheet">''');

  buf.write('<h1>گزارش محاسبه ضریب زلزله و برش پایه</h1>');
  buf.write('<div class="sub">استاندارد 2800 — آیین‌نامه طراحی ساختمان‌ها در برابر زلزله (ویرایش 5) &nbsp;|&nbsp; خروجی نرم‌افزار موبایل</div>');

  buf.write('<h2>۱. مشخصات ساختمان</h2><table>');
  buf.write(_row('سیستم سازه‌ای', '[${sys.group}] ${sys.name}'));
  buf.write(_row('حداکثر ارتفاع مجاز Hm (SDC1/2/3)', sys.hmax));
  buf.write(_row('ارتفاع ساختمان H', '${fmt(inp.height)} m'));
  buf.write(_row('ضریب اهمیت Ie', fmt(inp.importance, 2)));
  buf.write(_row('ضریب رفتار Ru', fmt(inp.ru, 2)));
  buf.write(_row('ضریب اضافه مقاومت Ω₀', fmt(inp.omega0, 2)));
  buf.write(_row('ضریب بزرگ‌نمایی تغییرمکان Cd', fmt(inp.cd, 2)));
  buf.write(_row('دوره تناوب تحلیلی Ta (ETABS)', '${fmt(inp.ta)} s'));
  buf.write(_row('میانقاب مانع حرکت جانبی قاب', inp.infillObstructs ? 'بله' : 'خیر'));
  buf.write('</table>');

  buf.write('<h2>۲. خطر لرزه‌ای و ساختگاه</h2><table>');
  buf.write(_row('شهر محل پروژه', inp.city));
  buf.write(_row('Ss (منبع جداگانه)', fmt(inp.ss)));
  buf.write(_row('S1 (خوانده‌شده از نقشه، g)', fmt(inp.s1)));
  buf.write(_row('نوع زمین', inp.siteClass));
  buf.write(_row('Fs', fmt(inp.fs)));
  buf.write(_row('F1', fmt(inp.f1)));
  buf.write(_row('گروه طراحی لرزه‌ای SDC', '<span class="badge">SDC-${r.sdc}</span>'));
  buf.write('</table>');

  buf.write('<h2>۳. نتایج محاسبه</h2><table>');
  buf.write(_row('SMS = Fs·Ss', fmt(r.sms)));
  buf.write(_row('SM1 = F1·S1', fmt(r.sm1)));
  buf.write(_row('SDS = 2/3 SMS', fmt(r.sds)));
  buf.write(_row('SD1 = 2/3 SM1', fmt(r.sd1)));
  buf.write(_row('T0 = 0.2·SD1/SDS', '${fmt(r.t0)} s'));
  buf.write(_row('Ts = SD1/SDS', '${fmt(r.ts)} s'));
  buf.write(_row('TL', '${fmt(r.tl, 1)} s'));
  buf.write(_row('Te (روابط تجربی)', '${fmt(r.te)} s'));
  buf.write(_row('T = min(Ta , 1.4Te)', '<b>${fmt(r.t)} s</b>'));
  buf.write(_row('Sa (طیف طرح)', '<b>${fmt(r.sa)} g</b>'));
  buf.write(_row('C = Sa/(Ru/Ie)', fmt(r.cFromSa)));
  buf.write(_row('Cmin (رابطه 3-4)', fmt(r.cmin1)));
  buf.write(_row('Cmin (رابطه 3-5، S1≥0.6)', r.cmin2 > 0 ? fmt(r.cmin2) : '—'));
  buf.write(_row('C نهایی', '<b>${fmt(r.cFinal)}</b>'));
  buf.write(_row('ضریب توزیع در ارتفاع K', fmt(r.k)));
  buf.write(_row('وزن مؤثر لرزه‌ای W', '${fmt(r.w)} ton'));
  buf.write(_row('برش پایه V = C·W', '<b>${fmt(r.v)} ton</b>'));
  buf.write(_row('نیروی قائم Fvt = 0.2·SDS·W', '${fmt(r.fvt)} ton'));
  buf.write('</table>');

  if (r.cminGoverns) {
    buf.write('<div class="warn">⚠ کنترل برش پایه حداقل (بند 3-9-1-2) حاکم است؛ ضریب نهایی برابر حداقل ضریب زلزله در نظر گرفته شد.</div>');
  }

  buf.write('<h2>۴. طیف طرح استاندارد</h2>');
  buf.write(_svgSpectrum(r, 3.0));

  if (r.fi.isNotEmpty) {
    buf.write('<h2>۵. توزیع نیرو در ارتفاع (رابطه 3-12)</h2>');
    buf.write('<table><tr><th>طبقه</th><th>hi (m)</th><th>Wi (ton)</th><th>Fi (ton)</th><th>Vi (ton)</th></tr>');
    for (var i = inp.floors.length - 1; i >= 0; i--) {
      buf.write('<tr><td>${i + 1}</td><td>${fmt(inp.floors[i].height, 1)}</td>'
          '<td>${fmt(inp.floors[i].weight, 1)}</td>'
          '<td><b>${fmt(r.fi[i], 2)}</b></td><td>${fmt(r.vi[i], 2)}</td></tr>');
    }
    final sum = r.fi.fold(0.0, (a, b) => a + b);
    buf.write('<tr style="background:#ecfeff"><td colspan="3"><b>جمع</b></td><td><b>${fmt(sum, 2)}</b></td><td></td></tr>');
    buf.write('</table>');
  }

  buf.write('<div class="note">یادآوری: مقادیر Ru، Ω₀، Cd و حداکثر ارتفاع مجاز سیستم‌ها از جدول 3-1 پیش‌فرض درج شده‌اند و در اپلیکیشن قابل ویرایش‌اند؛ پیش از صدور نظام فنی، با متن آیین‌نامه کنترل شوند. برای زمین نوع VI، تهیه طیف ویژه ساختگاه (بند 2-6-4) الزامی است.</div>');
  buf.write('<footer>این گزارش توسط اپلیکیشن «زلزله ۲۸۰۰ — ویرایش 5» تولید شده است و جایگزین محاسبات کنترلی مهندس مسئول نمی‌باشد.</footer>');
  buf.write('</div></body></html>');
  return buf.toString();
}
