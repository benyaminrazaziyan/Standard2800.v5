import 'dart:math';
import 'data.dart';

enum TeFormula { steelMoment, concreteMoment, withInfill, braced, generic }

class Floor {
  double weight; // ton
  double height; // m from base
  Floor(this.weight, this.height);
}

class SeismicInput {
  double height = 15;        // H  (m)
  double importance = 1.0;   // Ie
  String city = 'تهران';     // selected Iranian city
  double ss = 1.4;           // short-period spectral acceleration; separate source/input
  double s1 = 0.6;           // 1.0-sec spectral acceleration read from map (g)
  String siteClass = 'III';  // soil type I..VI
  double fs = 1.0;
  double f1 = 1.3;
  int systemIndex = 11;      // default: قاب خمشی بتنی متوسط
  bool infillObstructs = false;
  double ta = 1.0;           // analytical period (ETABS)
  double ru = 5.0, omega0 = 3.0, cd = 4.5;
  // Default model is internally consistent: five 3 m storeys, H = 15 m.
  List<Floor> floors = [
    Floor(420, 3), Floor(400, 6), Floor(380, 9),
    Floor(360, 12), Floor(340, 15),
  ];
  SeismicSystem get system => systems[systemIndex];
  double get weight => floors.fold(0.0, (s, f) => s + f.weight);
}

class SPD {
  final double t, sa;
  SPD(this.t, this.sa);
}

class SeismicResults {
  final double sms, sm1, sds, sd1, t0, ts, tl, te, t, sa;
  final double cFromSa, cmin1, cmin2, cmin, cFinal, k, w, v, fvt;
  final int sdc;
  final bool cminGoverns;
  final List<double> fi, vi; // per floor (index 0 = first floor)
  const SeismicResults({
    required this.sms, required this.sm1, required this.sds, required this.sd1,
    required this.t0, required this.ts, required this.tl, required this.te,
    required this.t, required this.sa, required this.cFromSa, required this.cmin1,
    required this.cmin2, required this.cmin, required this.cFinal, required this.k,
    required this.w, required this.v, required this.fvt, required this.sdc,
    required this.cminGoverns, required this.fi, required this.vi,
  });
}

double _teFor(SeismicInput inp) {
  var f = inp.system.teFormula;
  if (inp.infillObstructs &&
      (f == TeFormula.steelMoment || f == TeFormula.concreteMoment)) {
    f = TeFormula.withInfill;
  }
  switch (f) {
    case TeFormula.steelMoment:    return 0.072  * pow(inp.height, 0.80).toDouble();
    case TeFormula.concreteMoment: return 0.047  * pow(inp.height, 0.90).toDouble();
    case TeFormula.withInfill:     return 0.0494 * pow(inp.height, 0.75).toDouble();
    case TeFormula.braced:         return 0.073  * pow(inp.height, 0.75).toDouble();
    case TeFormula.generic:        return 0.0494 * pow(inp.height, 0.75).toDouble();
  }
}

double saAt(double t, double sds, double sd1) {
  const tl = 6.0;
  final t0 = 0.2 * sd1 / sds;
  final ts = sd1 / sds;
  if (t <= 0) return sds * 0.4;
  if (t < t0) return sds * (0.4 + 0.6 * t / t0);
  if (t <= ts) return sds;
  if (t <= tl) return sd1 / t;
  return sd1 * tl / (t * t);
}

List<SPD> spectrum(double sds, double sd1, double maxT) {
  final pts = <SPD>[];
  const n = 320;
  final step = maxT / n;
  for (var i = 0; i <= n; i++) {
    final t = i * step;
    pts.add(SPD(t, saAt(t, sds, sd1)));
  }
  return pts;
}

SeismicResults compute(SeismicInput inp) {
  validateInput(inp);
  final sms = inp.fs * inp.ss;
  final sm1 = inp.f1 * inp.s1;
  final sds = 2.0 / 3.0 * sms;
  final sd1 = 2.0 / 3.0 * sm1;
  final t0 = 0.2 * sd1 / sds;
  final ts = sd1 / sds;
  const tl = 6.0;

  final te = _teFor(inp);
  final t = min(inp.ta, 1.4 * te); // بند 3-9-2: T <= 1.4Te
  final sa = saAt(t, sds, sd1);

  final c = sa / (inp.ru / inp.importance); // رابطه 3-2
  final cmin1 = max(0.044 * sds * inp.importance, 0.01); // رابطه 3-4
  double cmin2 = 0;
  var cmin = cmin1;
  if (inp.s1 >= 0.6) { // رابطه 3-5
    cmin2 = 0.5 * inp.s1 * inp.importance / inp.ru;
    cmin = max(cmin, cmin2);
  }
  final cFinal = max(c, cmin);
  final cminGoverns = cmin > c;

  double k;
  if (t < 0.5) { k = 1.0; }
  else if (t <= 2.5) { k = 0.75 + 0.5 * t; }
  else { k = 2.0; }

  int sdc; // جدول 2-6
  if (inp.importance * sd1 <= 0.40 && inp.importance * sds <= 0.75) {
    sdc = 1;
  } else if (inp.importance * inp.s1 <= 0.6) {
    sdc = 2;
  } else {
    sdc = 3;
  }

  final w = inp.weight;
  final v = cFinal * w;
  final fvt = 0.2 * sds * w; // رابطه 3-15 نیروی قائم

  final fi = <double>[];
  final vi = <double>[];
  var denom = 0.0;
  for (final f in inp.floors) {
    denom += f.weight * pow(f.height, k).toDouble();
  }
  if (denom > 0) {
    var cum = 0.0;
    for (var i = inp.floors.length - 1; i >= 0; i--) {
      final f = inp.floors[i];
      final force = v * f.weight * pow(f.height, k).toDouble() / denom;
      cum += force;
      fi.insert(0, force);
      vi.insert(0, cum);
    }
  }
  return SeismicResults(
    sms: sms, sm1: sm1, sds: sds, sd1: sd1, t0: t0, ts: ts, tl: tl,
    te: te, t: t, sa: sa, cFromSa: c, cmin1: cmin1, cmin2: cmin2,
    cmin: cmin, cFinal: cFinal, k: k, w: w, v: v, fvt: fvt, sdc: sdc,
    cminGoverns: cminGoverns, fi: fi, vi: vi,
  );
}


/// Reject physically invalid inputs before evaluating the seismic equations.
/// This is a numerical input check, not a substitute for code-compliance review.
void validateInput(SeismicInput inp) {
  if (!inp.height.isFinite || inp.height <= 0) {
    throw ArgumentError('ارتفاع ساختمان باید عددی مثبت باشد.');
  }
  if (!inp.ta.isFinite || inp.ta <= 0) {
    throw ArgumentError('دوره تناوب تحلیلی باید عددی مثبت باشد.');
  }
  if (!inp.importance.isFinite || inp.importance <= 0 ||
      !inp.ru.isFinite || inp.ru <= 0) {
    throw ArgumentError('ضریب اهمیت و ضریب رفتار باید مثبت باشند.');
  }
  if (!inp.ss.isFinite || inp.ss < 0 || !inp.s1.isFinite || inp.s1 < 0 ||
      !inp.fs.isFinite || inp.fs <= 0 || !inp.f1.isFinite || inp.f1 <= 0) {
    throw ArgumentError('پارامترهای طیف باید مقادیر معتبر و غیرمنفی/مثبت داشته باشند.');
  }
  if (inp.floors.isEmpty) {
    throw ArgumentError('حداقل یک طبقه تعریف کنید.');
  }
  final heights = <double>[];
  for (final floor in inp.floors) {
    if (!floor.height.isFinite || floor.height <= 0 ||
        !floor.weight.isFinite || floor.weight <= 0) {
      throw ArgumentError('ارتفاع و وزن مؤثر هر طبقه باید مثبت باشند.');
    }
    heights.add(floor.height);
  }
  for (var i = 1; i < heights.length; i++) {
    if (heights[i] <= heights[i - 1]) {
      throw ArgumentError('ارتفاع طبقات باید از پایین به بالا به‌صورت صعودی وارد شود.');
    }
  }
}

String fmt(num v, [int d = 3]) {
  final a = v.abs();
  if (a >= 10000) return v.toStringAsFixed(0);
  if (a >= 1000) return v.toStringAsFixed(1);
  if (a >= 100) return v.toStringAsFixed(2);
  return v.toStringAsFixed(d);
}
