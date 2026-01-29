class MahyaData {
  static const List<String> messages = [
    'HOŞ GELDİN YA ŞEHR-İ RAMAZAN',
    'ORUÇ TUT SIHHAT BUL',
    'RAMAZAN BEREKETTİR',
    'KİTAP OKU HUZUR BUL',
    'KOMŞUSU AÇKEN TOK YATAN BİZDEN DEĞİLDİR',
    'SEVGİ EMEKTİR',
    'GÜZEL SÖZ SADAKADIR',
    'İYİLİK YAP İYİLİK BUL',
    'SABIR CENNETİN ANAHTARIDIR',
    'DUA MÜMİNİN SİLAHIDIR',
    'TEBESSÜM SÜNNETTİR',
    'İSRAF ETME İNSAF ET',
    'ÖFKE GELİR GÖZ KARARIR',
    'AFFETMEK BÜYÜKLÜKTÜR',
    'HER GECENİN BİR SABAHI VARDIR',
    'RAMAZAN PAYLAŞMAKTIR',
    'ELİNE BELİNE DİLİNE SAHİP OL',
    'ZAMAN EN BÜYÜK SERMAYEDİR',
    'BUGÜN ALLAH İÇİN NE YAPTIN?',
    'KALP KİRMA, GÖNÜL AL',
    "İLİM ÇİN'DE DE OLSA GİDİP ALINIZ",
    'DÜNYA MİSAFİRHANEDİR',
    'AZ YEMEK AZ UYUMAK AZ KONUŞMAK',
    'TEMİZLİK İMANDANDIR',
    'ANNE BABA RIZASI HAK RIZASIDIR',
    'YETİMİ GÜLDÜR',
    'KADİR GECEMİZ MÜBAREK OLSUN',
    'VEREN EL ALAN ELDEN ÜSTÜNDÜR',
    'ŞÜKÜR NİMETİ ARTIRIR',
    'ELVEDA YA ŞEHR-İ RAMAZAN',
  ];

  static String getMessageForDay(int day) {
    if (day < 1) return messages[0];
    if (day > 30) return messages[29];
    return messages[day - 1];
  }
}
