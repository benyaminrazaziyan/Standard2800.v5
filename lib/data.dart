import 'engine.dart';

class SeismicSystem {
  final String group; // الف/ب/پ/ت/ث/ج
  final String name;
  final TeFormula teFormula;
  final double ru, omega0, cd;
  final String hmax;
  const SeismicSystem({
    required this.group, required this.name, required this.teFormula,
    required this.ru, required this.omega0, required this.cd, required this.hmax,
  });
}

/// جدول 3-1 آیین‌نامه 2800 ویرایش 5 - مقادیر پیش‌فرض و قابل ویرایش در اپ
const systems = <SeismicSystem>[
  SeismicSystem(group: 'الف', name: 'دیوار برشی بتن‌آرمه ویژه (همبند شکل‌پذیر)', teFormula: TeFormula.generic, ru: 6.0, omega0: 2.5, cd: 5.0, hmax: '∞ / 50 / 50 m'),
  SeismicSystem(group: 'الف', name: 'دیوار برشی بتن‌آرمه معمولی', teFormula: TeFormula.generic, ru: 4.0, omega0: 2.5, cd: 4.0, hmax: '∞ / 50 / 30 m'),
  SeismicSystem(group: 'الف', name: 'دیوار برشی بنایی مسلح', teFormula: TeFormula.generic, ru: 2.0, omega0: 2.5, cd: 2.0, hmax: '9 / 9 / 9 m'),
  SeismicSystem(group: 'ب', name: 'قاب مهاربندی‌شده فولادی ویژه همگرا', teFormula: TeFormula.braced, ru: 6.0, omega0: 2.0, cd: 5.0, hmax: '∞ / 50 / 50 m'),
  SeismicSystem(group: 'ب', name: 'قاب مهاربندی‌شده فولادی متوسط همگرا', teFormula: TeFormula.braced, ru: 5.0, omega0: 2.0, cd: 4.5, hmax: '∞ / 35 / ممنوع'),
  SeismicSystem(group: 'ب', name: 'قاب مهاربندی‌شده فولادی معمولی همگرا', teFormula: TeFormula.braced, ru: 3.0, omega0: 2.0, cd: 2.5, hmax: '∞ / 20 / ممنوع'),
  SeismicSystem(group: 'ب', name: 'سیستم قاب ساده/دوگانه مهاربند واگرا و کمانش‌تاب', teFormula: TeFormula.braced, ru: 7.0, omega0: 2.0, cd: 6.0, hmax: '∞ / 50 / 50 m'),
  SeismicSystem(group: 'پ', name: 'قاب خمشی فولادی ویژه', teFormula: TeFormula.steelMoment, ru: 8.0, omega0: 3.0, cd: 5.5, hmax: '∞ / 65 / 48 m'),
  SeismicSystem(group: 'پ', name: 'قاب خمشی فولادی متوسط', teFormula: TeFormula.steelMoment, ru: 4.5, omega0: 3.0, cd: 4.0, hmax: '∞ / 48 / ممنوع'),
  SeismicSystem(group: 'پ', name: 'قاب خمشی فولادی معمولی', teFormula: TeFormula.steelMoment, ru: 3.0, omega0: 3.0, cd: 2.5, hmax: '∞ / 20* / ممنوع'),
  SeismicSystem(group: 'پ', name: 'قاب خمشی بتنی ویژه', teFormula: TeFormula.concreteMoment, ru: 8.0, omega0: 3.0, cd: 5.5, hmax: '∞ / 50 / 50 m'),
  SeismicSystem(group: 'پ', name: 'قاب خمشی بتنی متوسط', teFormula: TeFormula.concreteMoment, ru: 5.0, omega0: 3.0, cd: 4.5, hmax: '∞ / 50 / ممنوع'),
  SeismicSystem(group: 'پ', name: 'قاب خمشی بتنی معمولی', teFormula: TeFormula.concreteMoment, ru: 3.0, omega0: 3.0, cd: 2.5, hmax: '∞ / 20* / ممنوع'),
  SeismicSystem(group: 'ت', name: 'سیستم دوگانه (دیوار/مهاربند ویژه + قاب خمشی ویژه)', teFormula: TeFormula.steelMoment, ru: 7.0, omega0: 2.5, cd: 5.5, hmax: '∞ / 65 / 48 m'),
  SeismicSystem(group: 'ت', name: 'سیستم دوگانه (دیوار/مهاربند متوسط + قاب خمشی متوسط)', teFormula: TeFormula.braced, ru: 6.0, omega0: 2.5, cd: 5.0, hmax: '∞ / 50 / ممنوع'),
  SeismicSystem(group: 'ث', name: 'سیستم ستون کنسولی', teFormula: TeFormula.generic, ru: 2.5, omega0: 2.0, cd: 2.5, hmax: '10 / 10 / 10 m'),
];

/// جدول 2-1 (Fs) و جدول 2-2 (F1) - ویرایش 5
const ssCols = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5];
const s1Cols = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6];

const faTable = {
  'I':   [0.8, 0.8, 0.8, 0.8, 0.8, 0.8],
  'II':  [1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
  'III': [1.2, 1.2, 1.1, 1.0, 1.0, 1.0],
  'IV':  [1.6, 1.4, 1.2, 1.1, 1.0, 1.0],
  'V':   [2.5, 1.7, 1.2, 0.9, 0.9, 0.8],
};

const fvTable = {
  'I':   [0.8, 0.8, 0.8, 0.8, 0.8, 0.8],
  'II':  [1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
  'III': [1.7, 1.6, 1.5, 1.4, 1.3, 1.2],
  'IV':  [2.4, 2.0, 1.8, 1.6, 1.5, 1.4],
  'V':   [3.5, 3.2, 2.8, 2.4, 2.0, 1.9],
};

double _interp(List<double> cols, List<double> vals, double x) {
  if (x <= cols.first) return vals.first;
  if (x >= cols.last) return vals.last;
  for (var i = 0; i < cols.length - 1; i++) {
    if (x >= cols[i] && x <= cols[i + 1]) {
      final t = (x - cols[i]) / (cols[i + 1] - cols[i]);
      return vals[i] + t * (vals[i + 1] - vals[i]);
    }
  }
  return vals.last;
}

/// پیشنهاد Fs - برای زمین نوع VI مطالعات ویژه الزامی است؛ موقتاً مقادیر نوع IV
double suggestedFs(String siteClass, double ss) =>
    _interp(ssCols, faTable[siteClass == 'VI' ? 'IV' : siteClass]!, ss);

/// پیشنهاد F1 - برای زمین نوع VI مطالعات ویژه الزامی است؛ موقتاً مقادیر نوع IV
double suggestedF1(String siteClass, double s1) =>
    _interp(s1Cols, fvTable[siteClass == 'VI' ? 'IV' : siteClass]!, s1);

const siteClassNames = {
  'I': 'I — سنگ سخت',
  'II': 'II — سنگ',
  'III': 'III — خاک رسی ماسه‌ای محکم',
  'IV': 'IV — خاک نرم تا محکم',
  'V': 'V — خاک نرم',
  'VI': 'VI — نیازمند مطالعه ویژه',
};


/// شهرهای قابل انتخاب؛ انتخاب شهر به‌تنهایی مقدار شتاب را تعیین نمی‌کند.
/// کاربر باید مقدار S1 را با مراجعه به نقشه رسمی ویرایش پنجم انتخاب کند.
const iranCities = <String>[
  'تهران', 'تبریز', 'ارومیه', 'اردبیل', 'رشت', 'ساری', 'گرگان', 'مشهد',
  'زنجان', 'قزوین', 'کرج', 'قم', 'همدان', 'سنندج', 'کرمانشاه', 'ایلام',
  'خرم‌آباد', 'اراک', 'اصفهان', 'شهرکرد', 'یاسوج', 'اهواز', 'شیراز',
  'بوشهر', 'یاسوج', 'کرمان', 'بندرعباس', 'یزد', 'بیرجند', 'زاهدان',
  'سمنان', 'بجنورد', 'کاشان', 'قشم', 'کیش',
];

/// مقادیر راهنمای قابل انتخاب از راهنمای رنگی نقشه ارسالی (واحد g).
/// برای مقدار دقیق باید خطوط هم‌مقدار روی نقشه رسمی در محل شهر بررسی شوند.
const mapS1Values = <double>[0.35, 0.40, 0.45, 0.50, 0.55, 0.60];
