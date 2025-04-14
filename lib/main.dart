import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitap Günlüğüm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFFC107),
        scaffoldBackgroundColor: Color(0xFFFDF6EC),
        fontFamily: GoogleFonts.quicksand().fontFamily,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 4,
          backgroundColor: Color(0xFFFFC107),
          foregroundColor: Colors.brown[800],
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('tr', 'TR'),
      ],
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> kitaplar = [
    {
      'isim': 'Simyacı',
      'yazar': 'Paulo Coelho',
      'puan': 5,
      'yorum': 'Hayatın anlamını arayan bir çobanın yolculuğu. Gerçekten ilham verici bir hikaye.',
      'tarih': DateTime(2024, 5, 10),
      'benimEkleme': true,
    },
    {
      'isim': 'Suç ve Ceza',
      'yazar': 'Dostoyevski',
      'puan': 4,
      'yorum': 'Zihinsel çatışmaların ve vicdan muhasebesinin derinlemesine anlatıldığı bir başyapıt.',
      'tarih': DateTime(2024, 1, 20),
      'benimEkleme': true,
    },
  ];

  String _arama = '';
  String _sirala = 'Tarihe Göre (Yeni)';

  List<Map<String, dynamic>> get _filtreliListe {
    List<Map<String, dynamic>> liste = _arama.isEmpty
        ? List.from(kitaplar)
        : kitaplar.where((k) => k['isim'].toLowerCase().contains(_arama.toLowerCase())).toList();

    switch (_sirala) {
      case 'Kitap Adı':
        liste.sort((a, b) => a['isim'].compareTo(b['isim']));
        break;
      case 'Yazar Adı':
        liste.sort((a, b) => a['yazar'].compareTo(b['yazar']));
        break;
      case 'Tarihe Göre (Yeni)':
        liste.sort((a, b) => b['tarih'].compareTo(a['tarih']));
        break;
      case 'Tarihe Göre (Eski)':
        liste.sort((a, b) => a['tarih'].compareTo(b['tarih']));
        break;
    }
    return liste;
  }

  int get buYilOkunanlar {
    final now = DateTime.now();
    return kitaplar.where((k) => k['tarih'].year == now.year).length;
  }

  void _siralaMenusuAc(BuildContext context) async {
    final secilen = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Tarihe Göre (Yeni)'),
            onTap: () => Navigator.pop(context, 'Tarihe Göre (Yeni)'),
          ),
          ListTile(
            leading: Icon(Icons.schedule_outlined),
            title: Text('Tarihe Göre (Eski)'),
            onTap: () => Navigator.pop(context, 'Tarihe Göre (Eski)'),
          ),
          ListTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text('Kitap Adı'),
            onTap: () => Navigator.pop(context, 'Kitap Adı'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Yazar Adı'),
            onTap: () => Navigator.pop(context, 'Yazar Adı'),
          ),
        ],
      ),
    );

    if (secilen != null) {
      setState(() {
        _sirala = secilen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    Map<String, List<Map<String, dynamic>>> kategorilenmis = {};
    for (var kitap in _filtreliListe) {
      String yazar = kitap['yazar'];
      if (!kategorilenmis.containsKey(yazar)) {
        kategorilenmis[yazar] = [];
      }
      kategorilenmis[yazar]!.add(kitap);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kitap Günlüğüm', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            tooltip: 'Sırala',
            onPressed: () => _siralaMenusuAc(context),
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            tooltip: 'İstatistikler',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => IstatistikSayfasi(total: kitaplar.length, thisYear: buYilOkunanlar)),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Kitap ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                setState(() {
                  _arama = val;
                });
              },
            ),
          ),
          Expanded(
            child: _filtreliListe.isEmpty
                ? Center(child: Text("Henüz kitap yok 🙁"))
                : ListView(
              padding: EdgeInsets.all(10),
              children: kategorilenmis.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.person_pin, color: Colors.brown[700]),
                          SizedBox(width: 6),
                          Text(
                            entry.key,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[700]),
                          ),
                        ],
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: entry.value.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final kitap = entry.value[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KitapDetaySayfasi(kitap: kitap),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                if (result['sil'] == true) {
                                  kitaplar.remove(kitap);
                                } else if (result['guncelle'] != null) {
                                  final i = kitaplar.indexOf(kitap);
                                  kitaplar[i] = {
                                    ...result['guncelle'],
                                    'tarih': kitap['tarih'],
                                  };
                                }
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kitap['isim'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown[800],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  kitap['yazar'],
                                  style: TextStyle(color: Colors.brown[600]),
                                ),
                                SizedBox(height: 8),
                                Text('Puan: ${kitap['puan']} ⭐'),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Detaylar için tıkla',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.brown,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFFFFC107),
        icon: Icon(Icons.add),
        label: Text('Kitap Ekle'),
        onPressed: () async {
          final yeniKitap = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KitapEklemeSayfasi()),
          );
          if (yeniKitap != null) {
            setState(() {
              yeniKitap['tarih'] = DateTime.now();
              kitaplar.add(yeniKitap);
            });
          }
        },
      ),
    );
  }
}




class IstatistikSayfasi extends StatelessWidget {
  final int total;
  final int thisYear;

  IstatistikSayfasi({required this.total, required this.thisYear});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('İstatistikler')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📚 Toplam Okunan Kitap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('$total kitap', style: TextStyle(fontSize: 22)),
                  Divider(height: 32),
                  Text('🗓 Bu Sene Okunanlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('$thisYear kitap', style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KitapEklemeSayfasi extends StatefulWidget {
  final Map<String, dynamic>? kitap;

  KitapEklemeSayfasi({this.kitap});

  @override
  _KitapEklemeSayfasiState createState() => _KitapEklemeSayfasiState();
}

class _KitapEklemeSayfasiState extends State<KitapEklemeSayfasi> {
  late TextEditingController _kitapAdiController;
  late TextEditingController _yazarAdiController;
  late TextEditingController _yorumController;
  late int _puan;
  late DateTime? _okumaTarihi;

  @override
  void initState() {
    super.initState();
    _kitapAdiController = TextEditingController(text: widget.kitap?['isim'] ?? '');
    _yazarAdiController = TextEditingController(text: widget.kitap?['yazar'] ?? '');
    _yorumController = TextEditingController(text: widget.kitap?['yorum'] ?? '');
    _puan = widget.kitap?['puan'] ?? 5;
    _okumaTarihi = widget.kitap?['tarih'] ?? DateTime.now();

  }

  @override
  void dispose() {
    _kitapAdiController.dispose();
    _yazarAdiController.dispose();
    _yorumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool duzenlemeModu = widget.kitap != null;

    return Scaffold(
      appBar: AppBar(title: Text(duzenlemeModu ? 'Kitabı Düzenle' : 'Kitap Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _kitapAdiController,
              decoration: InputDecoration(labelText: '📖 Kitap Adı'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _yazarAdiController,
              decoration: InputDecoration(labelText: '👤 Yazar Adı'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _yorumController,
              maxLines: 4,
              decoration: InputDecoration(labelText: '📝 Yorum'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _puan,
              decoration: InputDecoration(labelText: '⭐ Puan'),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _puan = val;
                  });
                }
              },
              items: [1, 2, 3, 4, 5]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.brown),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _okumaTarihi != null
                        ? DateFormat('dd MMMM yyyy', 'tr_TR').format(_okumaTarihi!)
                        : 'Tarih seçilmedi',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime now = DateTime.now();
                    final secilen = await showDatePicker(
                      context: context,
                      initialDate: _okumaTarihi ?? now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(now.year + 1),
                      locale: const Locale('tr', 'TR'),
                    );
                    if (secilen != null) {
                      setState(() {
                        _okumaTarihi = secilen;
                      });
                    }
                  },
                  child: Text('Tarih Seç'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, {
                  'isim': _kitapAdiController.text,
                  'yazar': _yazarAdiController.text,
                  'puan': _puan,
                  'yorum': _yorumController.text,
                  'benimEkleme': true,
                  'tarih': _okumaTarihi ?? DateTime.now(),
                });
              },
              icon: Icon(Icons.check),
              label: Text(duzenlemeModu ? 'Güncelle' : 'Kaydet'),
            )
          ],
        ),
      ),
    );
  }
}


class KitapDetaySayfasi extends StatelessWidget {
  final Map<String, dynamic> kitap;

  KitapDetaySayfasi({required this.kitap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kitap['isim']),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'düzenle') {
                final guncellenenKitap = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KitapEklemeSayfasi(kitap: kitap),
                  ),
                );
                if (guncellenenKitap != null) {
                  Navigator.pop(context, {'guncelle': guncellenenKitap});
                }
              } else if (value == 'sil') {
                final onay = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Kitap Sil'),
                    content: Text('Bu kitabı silmek istediğinize emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('İptal')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Sil', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (onay == true) {
                  Navigator.pop(context, {'sil': true});
                }
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'düzenle', child: Text('Düzenle')),
              PopupMenuItem(value: 'sil', child: Text('Sil')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kitap['isim'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                ),
                SizedBox(height: 8),
                Text('Yazar: ${kitap['yazar']}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('Puan: ${kitap['puan']} ⭐', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                if (kitap['tarih'] != null)
                  Text('Okuma Tarihi: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(kitap['tarih'])}'),
                SizedBox(height: 20),
                Text('Yorum:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text(
                  kitap['yorum'],
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
