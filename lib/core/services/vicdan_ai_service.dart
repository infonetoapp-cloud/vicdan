import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class VicdanAIService {
  static const int _dailyLimit = 5;
  static const String _usageKey = 'ai_usage_count';
  static const String _dateKey = 'ai_usage_date';

  final SharedPreferences _prefs;
  late final GenerativeModel _model;

  VicdanAIService(this._prefs) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('API Key not found in .env');
    }
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  /// Main entry point:  /// Get Spiritual Prescription (Verse + Advice)
  Future<String> getPrescription(String mood) async {
    // 0. Quota & Network Check
    final bool hasQuota = _hasQuota();

    // 🧠 SMART QUOTA SAVER:
    // User requested to save limit.
    // 'Şükür' and 'Huzur' are better served by our curated Local Database (it's faster & cheaper).
    // 'Daraldım' and 'Karışık' need complex AI empathy.
    final m = mood.toLowerCase();
    bool prioritizeLocal = m.contains('sukur') || m.contains('huzur');

    if (!hasQuota || prioritizeLocal) {
      if (prioritizeLocal)
        debugPrint("VicdanAI: Saving quota for simple mood: $mood");
      return _getLocalFallback(mood);
    }

    try {
      // 1. Normalize Mood for AI Prompt (Translate Enum to Turkish Meaning)
      String moodContext = "Genel Maneviyat";
      String moodInstruction = "genel bir ferahlık";

      if (m.contains('daral')) {
        moodContext = "Sıkıntılı ve Daralmış";
        moodInstruction =
            "iç sıkıntısına iyi gelecek, ferahlatıcı (İnşirah/Duha gibi)";
      } else if (m.contains('sukur')) {
        moodContext = "Şükür ve Minnet";
        moodInstruction = "nimetlerin farkına vardıran, şükrü artıran";
      } else if (m.contains('huzur')) {
        moodContext = "Huzurlu ve Sakin";
        moodInstruction = "bu huzuru pekiştiren, kalbi Allah ile mutmain kılan";
      } else if (m.contains('karisik')) {
        moodContext = "Kafası Karışık ve Yorgun";
        moodInstruction =
            "yol gösteren, zihni berraklaştıran, teslimiyeti hatırlatan";
      }

      // 2. Prepare Prompt
      final prompt = '''
      Sen 'Vicdan' adında bilge, şefkatli ve manevi bir dostsun.
      Kullanıcının şu anki ruh hali: $moodContext.
      
      Ona $moodInstruction bir Kur'an ayeti ve yanına kısa, kalbe dokunan bir tavsiye ver.
      
      Format Şöyle Olsun:
      Ayet: 'Ayet Meali' (Sure Adı, Ayet No)
      Tavsiye: (Senin 1-2 cümlelik, samimi, tasavvufi yorumun)
      
      Lütfen samimi ol, robotik olma. "Nasılsın" diye sorma, direkt şifayı sun.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        await _incrementUsage(); // Only increment if successful
        return response.text!;
      } else {
        return _getLocalFallback(mood);
      }
    } catch (e) {
      debugPrint("VicdanAI Error: $e");
      return _getLocalFallback(mood);
    }
  }

  /// Local Fallback Logic (Offline / No Quota)
  String _getLocalFallback(String mood) {
    debugPrint("VicdanAI: Raw mood input: '$mood'");

    // 🔍 NORMALIZATION & MAPPING
    // We map strictly to one of the 4 keys.
    String key = 'Genel';
    final m = mood.toLowerCase();

    if (m.contains('daral') || m.contains('bunal') || m.contains('sikil')) {
      key = 'Daraldım';
    } else if (m.contains('huzur') ||
        m.contains('sakin') ||
        m.contains('dingin')) {
      key = 'Huzur';
    } else if (m.contains('sukur') ||
        m.contains('nimet') ||
        m.contains('tesekkur')) {
      key = 'Şükür';
    } else if (m.contains('karisik') ||
        m.contains('bilmi') ||
        m.contains('yorgun')) {
      key = 'Karışık';
    }

    debugPrint("VicdanAI: Selected Key: '$key'");

    // 🌟 STRICT CATEGORIZED DATABASE

    final List<String> daraldimList = [
      "Ayet: 'Biz senin göğsünü açıp genişletmedik mi?' (İnşirah, 1)\nTavsiye: Göğsündeki o sıkışma, genişleyecek bir kalbin doğum sancısıdır. Sabret, ferahlık yakında.",
      "Ayet: 'Şüphesiz güçlükle beraber bir kolaylık vardır.' (İnşirah, 5)\nTavsiye: Her yokuşun bir inişi, her gecenin bir sabahı var. Şu an yokuştasın, manzara az sonra.",
      "Ayet: 'Rabbin seni terk etmedi ve sana darılmadı.' (Duha, 3)\nTavsiye: Yalnızlık hissi bir illüzyon. O, şah damarından yakın sana. Sadece fısılda.",
      "Ayet: 'Rabbim, göğsüme genişlik ver, işimi bana kolaylaştır.' (Taha, 25-26)\nTavsiye: Bu duayı şimdi, şu an kalbinden geçir. Dua, kaderin yönünü değiştirebilen tek oktur.",
      "Ayet: 'Allah sabredenlerle beraberdir.' (Bakara, 153)\nTavsiye: En güzel dost, en zor zamanda yanında olandır. O seninle. Yalnız yürümüyorsun.",
      "Ayet: 'Üzülme, Allah bizimle beraberdir.' (Tevbe, 40)\nTavsiye: Bu his kalıcı değil. Bulutlar dağılır, güneş yine doğar. İman et ve bekle.",
      "Ayet: 'Allah kuluna kafi değil mi?' (Zümer, 36)\nTavsiye: O sana yeter. Kapılar kapandıysa üzülme, O'nun kapısı her zaman açık.",
    ];

    final List<String> sukurList = [
      "Ayet: 'Eğer şükrederseniz, elbette size (nimetimi) artırırım.' (İbrahim, 7)\nTavsiye: Şükür, nimeti değil, Nimeti Vereni görmektir. Bugün, fark ettiğin her güzellik artarak döner.",
      "Ayet: 'Rabbinin nimetini minnet ve şükranla an.' (Duha, 11)\nTavsiye: Bugün aldığın nefes, görebildiğin renkler... Hepsi sana özel birer mektup. Okumasını bilene.",
      "Ayet: 'Ölü toprağa can verdik. Şükretmeniz gerekmez mi?' (Yasin, 33-35)\nTavsiye: Bahardaki her çiçek, sofrandaki her lokma bir mucize. Sıradan görünen bu mucizeleri kutla.",
      "Ayet: 'Bana şükredin, nankörlük etmeyin.' (Bakara, 152)\nTavsiye: Şikayet etmek zehir, şükretmek panzehirdir. Bugün dilini güzelliğe alıştır.",
      "Ayet: 'Hamd, alemlerin Rabbi olan Allah'a mahsustur.' (Fatiha, 2)\nTavsiye: Hamd, her durumda 'İyi ki varsın Allah'ım' diyebilmektir. O seninle, ne güzel.",
      "Ayet: 'Yeryüzünde ne varsa hepsini sizin için yarattı.' (Bakara, 29)\nTavsiye: Kendini değersiz hissetme. Tüm bu kâinat senin hizmetine sunuldu, kıymetini bil.",
      "Ayet: 'Verdiğimiz rızıkların temiz olanlarından yiyin ve şükredin.' (Bakara, 172)\nTavsiye: Bir yudum suyun, sıcak bir ekmeğin lezzetini hisset. Mutluluk küçük detaylarda gizlidir.",
    ];

    final List<String> huzurList = [
      // REMOVED: Verses implying death, fear, or heavy warning. KEPT: Pure serenity.
      "Ayet: 'Bilesiniz ki, kalpler ancak Allah'ı anmakla huzur bulur.' (Ra'd, 28)\nTavsiye: Dışarıda aradığın huzur, aslında kalbinin en derin odasında saklı. Oraya dön.",
      "Ayet: 'O, müminlerin kalplerine sükûnet (sekine) indirendir.' (Fetih, 4)\nTavsiye: Telaşı bırak. Suyun durulması gibi, ruhunun durulmasına izin ver. Anın tadını çıkar.",
      "Ayet: 'Rahman'ın kulları yeryüzünde vakarla (sakinlik ve tevazu ile) yürürler.' (Furkan, 63)\nTavsiye: Acele etme. Yavaşlamak, ruhun hızını yakalamaktır. Bugün adımlarını yavaşlat.",
      "Ayet: 'Allah esenlik yurduna (huzura) çağırır.' (Yunus, 25)\nTavsiye: İçindeki kavgaları bitir. Barış kendinle başlar. Bugün aynaya bak ve kendine gülümse.",
      "Ayet: 'Geceyi sizin için bir sükûnet, uykuyu bir dinlenme kıldık.' (Furkan, 47)\nTavsiye: Dinlenmek de ibadettir. Bedenin O'nun emaneti. Ona nazik davran.",
      "Ayet: 'Sabahın aydınlığına andolsun.' (Duha, 1)\nTavsiye: Her sabah yeni bir başlangıçtır. Dünü bırak, bugünün nuruna odaklan.",
      "Ayet: 'Nerede olursanız olun O sizinle beraberdir.' (Hadid, 4)\nTavsiye: En sessiz anında bile yalnız değilsin. Bu güven hissi, en büyük huzur kaynağıdır.",
    ];

    final List<String> karisikList = [
      "Ayet: 'Belki sevmediğiniz şey hakkınızda hayırlıdır.' (Bakara, 216)\nTavsiye: Resmin bütününü göremiyorsun. Olan bitende bir hayır ara, yargılamak için acele etme.",
      "Ayet: 'İnsan hayır ister gibi şerri ister. İnsan çok acelecisidir.' (İsra, 11)\nTavsiye: İstediğin şey olmuyorsa, belki de korunduğun içindir. Akışa güven.",
      "Ayet: 'Biz insanı en güzel biçimde yarattık.' (Tin, 4)\nTavsiye: Kendini eksik hissetme. Sen tamamlanmış bir esersin. Kusur sandıkların imzan olabilir.",
      "Ayet: 'Göklerin ve yerin krallığı Allah'ındır.' (Al-i İmran, 189)\nTavsiye: Her şeyi kontrol edemezsin. Dümeni Kaptan'a bırak, sen yolculuğun tadını çıkar.",
      "Ayet: 'O'na güvenip dayana, O yeter.' (Talak, 3)\nTavsiye: Yüklerini yere bırak. Hepsini sırtlamak zorunda değilsin. Hafiflemek haktır.",
      "Ayet: 'Her zorlukla beraber bir kolaylık vardır.' (İnşirah, 5)\nTavsiye: Bu karmaşa geçici. Su bulanmadan durulmaz. Sabret.",
    ];

    List<String> selectedList;
    switch (key) {
      case 'Daraldım':
        selectedList = daraldimList;
        break;
      case 'Şükür':
        selectedList = sukurList;
        break;
      case 'Huzur':
        selectedList = huzurList;
        break;
      case 'Karışık':
        selectedList = karisikList;
        break;
      default:
        selectedList = daraldimList; // Fallback
    }

    // Use Random() for true variations
    final random = Random();
    return selectedList[random.nextInt(selectedList.length)];
  }

  /// Quota Management
  bool _hasQuota() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDate = _prefs.getString(_dateKey);

    if (lastDate != today) {
      // New day, reset
      _prefs.setString(_dateKey, today);
      _prefs.setInt(_usageKey, 0);
      return true;
    }

    final usage = _prefs.getInt(_usageKey) ?? 0;
    return usage < _dailyLimit;
  }

  Future<void> _incrementUsage() async {
    final current = _prefs.getInt(_usageKey) ?? 0;
    await _prefs.setInt(_usageKey, current + 1);
  }
}
