import '../domain/entities/journey_item.dart';

class JourneyData {
  static const List<JourneyItem> allItems = [
    JourneyItem(
      day: 1,
      title: 'Niyet',
      content:
          'Yolculuklar adım atarak değil, niyet ederek başlar. Bugün, kalbini bu 30 günlük değişime aç. Niyetin, pusuladır.',
      action: 'Sessiz bir an bul ve bu yolculuktan ne beklediğini kendine sor.',
      isLocked: false,
    ),
    JourneyItem(
      day: 2,
      title: 'Teşekkür',
      content:
          'Sahip olduklarımız çoğu zaman başkalarının hayalidir. Şükür, sahip olduklarımızı çoğaltan bir anahtardır.',
      action: 'Bugün en az 3 küçük şey için içtenlikle teşekkür et.',
    ),
    JourneyItem(
      day: 3,
      title: 'Sessizlik',
      content:
          'Gürültülü bir dünyada en büyük lüks sessizliktir. Ruhun ancak sükunette konuşur.',
      action:
          'Bugün 10 dakika boyunca hiçbir şey yapmadan sadece sessizce dur.',
    ),
    JourneyItem(
      day: 4,
      title: 'Paylaşmak',
      content:
          'Bir mum, diğer mumu tutuşturmakla ışığından bir şey kaybetmez. Paylaşmak zenginleştirir.',
      action:
          'Bugün birine, karşılık beklemeden küçük bir iyilik yap veya bir şey ısmarla.',
    ),
    JourneyItem(
      day: 5,
      title: 'Sabır',
      content:
          'Sabır, boyun eğmek değil, mücadele etmektir. Zorlukların seni güçlendirmesine izin ver.',
      action:
          'Bugün seni zorlayan bir duruma karşı hemen tepki verme, önce derin bir nefes al.',
    ),
    JourneyItem(
      day: 6,
      title: 'Affetmek',
      content:
          'Affetmek, geçmişi değiştirmez ama geleceğin önünü açar. Yüklerinden kurtul.',
      action:
          'Kırgın olduğun biri varsa, içinde onu affetmeye niyet et veya bir adım at.',
    ),
    JourneyItem(
      day: 7,
      title: 'Doğa',
      content:
          'Toprak, gökyüzü ve ağaçlar... Hepsi bize sessizce bir şeyler anlatır. Onları dinle.',
      action:
          'Bugün dışarı çık, bir ağaca dokun veya gökyüzünü uzun uzun izle.',
    ),
    JourneyItem(
      day: 8,
      title: 'Tebessüm',
      content:
          'Gülümsemek, iki insan arasındaki en kısa mesafedir. Sadakadır, şifadır.',
      action: 'Bugün karşılaştığın, tanımadığın birine içtenlikle gülümse.',
    ),
    JourneyItem(
      day: 9,
      title: 'Sadeleşmek',
      content:
          'Fazlalıklar, zihnini de kalbini de yorar. Azalmak, öze dönmektir.',
      action:
          'Bugün kullanmadığın 3 eşyayı ayır ve ihtiyacı olan birine vermeyi planla.',
    ),
    JourneyItem(
      day: 10,
      title: 'Dua',
      content:
          'Dua, acizliğin ilanı, gücün kaynağına bağlanışıdır. En samimi kelimelerini fısılda.',
      action:
          'Bugün sadece kendin için değil, hiç tanımadığın insanlar için de dua et.',
    ),
    // Days 11-30 are placeholders effectively populated for layout logic
    JourneyItem(
        day: 11,
        title: 'Tevazu',
        content: 'Kibir insanı yalnızlaştırır, tevazu ise yüceltir.',
        action: 'Bugün bir hatanı kabul et.'),
    JourneyItem(
        day: 12,
        title: 'Sıla-i Rahim',
        content: 'Köklerinle bağını koparma.',
        action: 'Uzun süredir aramadığın bir akrabanı ara.'),
    JourneyItem(
        day: 13,
        title: 'Tefekkür',
        content: 'Bakmak ile görmek arasındaki farkı anla.',
        action: 'Yaratılıştaki bir detayı incele (bir yaprak, bir el).'),
    JourneyItem(
        day: 14,
        title: 'İnfak',
        content: 'Vermek sadece para değildir, zamandır, emektir.',
        action: 'Bir hayır kurumuna, az da olsa bağışta bulun.'),
    JourneyItem(
        day: 15,
        title: 'Muhasebe',
        content: 'Yolun yarısı. Nereye gidiyorsun?',
        action:
            "Bu Ramazan'ın ilk yarısını düşün, neleri daha iyi yapabilirsin?"),
    JourneyItem(
        day: 16,
        title: 'Kuran',
        content: 'O, kalplere şifadır.',
        action: 'Bugün mealinden en az 1 sayfa oku ve anlamaya çalış.'),
    JourneyItem(
        day: 17,
        title: 'Komşuluk',
        content: 'Komşusu açken tok yatan bizden değildir.',
        action: 'Bir komşuna hal hatır sor veya ikramda bulun.'),
    JourneyItem(
        day: 18,
        title: 'İhlas',
        content: 'Sadece Allah rızası için yapmak.',
        action: 'Kimse görmeden bir iyilik yap ve gizli kalsın.'),
    JourneyItem(
        day: 19,
        title: 'Vefa',
        content: 'Yapılan iyiliği unutma.',
        action: 'Üzerinde emeği olan bir öğretmeni veya büyüğünü an/ara.'),
    JourneyItem(
        day: 20,
        title: 'Ümit',
        content: "Allah'ın rahmetinden ümit kesilmez.",
        action: 'Karamsarlığa düştüğün bir konuda kendine umut aşıla.'),
    JourneyItem(
        day: 21,
        title: 'İtidal',
        content: 'Her işte aşırılıktan kaçın.',
        action: 'Yeme, içme veya harcamada bugün daha dikkatli ol.'),
    JourneyItem(
        day: 22,
        title: 'Emanet',
        content: 'Bedenin, kalbin ve dünya sana emanettir.',
        action: 'Sağlığın için bugün zararlı bir alışkanlığından uzak dur.'),
    JourneyItem(
        day: 23,
        title: 'Adalet',
        content: 'Kendin aleyhine bile olsa adaleti gözet.',
        action: 'Bir tartışmada haklı olsan bile yapıcı ol.'),
    JourneyItem(
        day: 24,
        title: 'İstikamet',
        content: 'Dosdoğru yol üzere olmak.',
        action: 'Bugün verdiğin bir sözü tutmaya azami gayret göster.'),
    JourneyItem(
        day: 25,
        title: 'Tevekkül',
        content: "Elinden geleni yap, gerisini O'na bırak.",
        action: "Endişe ettiğin bir konuyu Allah'a havale et ve rahatla."),
    JourneyItem(
        day: 26,
        title: 'Samimiyet',
        content: 'İçtenlik her kapıyı açar.',
        action: 'Bugün yapmacık nezaketten uzak dur, samimi ol.'),
    JourneyItem(
        day: 27,
        title: 'Kadir',
        content: 'Bin aydan daha hayırlı bir gece.',
        action: 'Bu geceyi, ömrünün en kıymetli gecesiymiş gibi değerlendir.'),
    JourneyItem(
        day: 28,
        title: 'Kardeşlik',
        content: 'Müminler ancak kardeştir.',
        action: 'Bir arkadaşının derdini dinle veya ona destek ol.'),
    JourneyItem(
        day: 29,
        title: 'Arınma',
        content: 'Bayrama temiz bir kalp ile gir.',
        action:
            'Kalbini kıran veya kırdığın herkesle helalleşmeyi (içinden de olsa) dene.'),
    JourneyItem(
        day: 30,
        title: 'Veda ve Bayram',
        content: 'Ayrılık hüzünlüdür ama vuslat yakındır.',
        action:
            'Ramazan biterken kazandığın güzellikleri kaybetmemeye niyet et.'),
  ];
}
