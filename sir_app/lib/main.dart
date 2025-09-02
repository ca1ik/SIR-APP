import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const OtomasyonUygulamasi());
}

class OtomasyonUygulamasi extends StatelessWidget {
  const OtomasyonUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Otomasyonu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF121212), // Koyu arka plan
        cardColor: const Color(0xFF1E1E1E), // Koyu kart rengi
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueGrey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shadowColor: Colors.black.withOpacity(0.5),
            elevation: 10,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
      home: const OtomasyonAnasayfasi(),
    );
  }
}

class OtomasyonAnasayfasi extends StatefulWidget {
  const OtomasyonAnasayfasi({super.key});

  @override
  State<OtomasyonAnasayfasi> createState() => _OtomasyonAnasayfasiState();
}

class _OtomasyonAnasayfasiState extends State<OtomasyonAnasayfasi> {
  final TextEditingController _sifreController = TextEditingController();
  final String _dogruSifre = 'forfuture';
  bool _otomasyonCalisiyor = false;

  @override
  void initState() {
    super.initState();
    // Enter tuşuyla butona basma işlevi
    HardwareKeyboard.instance.addHandler((KeyEvent event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        if (!_otomasyonCalisiyor) {
          _gosterSifrePenceresi(context);
        }
        return true;
      }
      return false;
    });
  }

  void _gosterSifrePenceresi(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title:
              const Text('Şifre Girin', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _sifreController,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Şifrenizi girin',
            ),
            onSubmitted: (_) {
              _baslatOtomasyon();
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              child:
                  const Text('İptal', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                _baslatOtomasyon();
                Navigator.of(context).pop();
              },
              child: const Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  void _baslatOtomasyon() async {
    if (_sifreController.text == _dogruSifre) {
      setState(() {
        _otomasyonCalisiyor = true;
      });

      const url = 'http://127.0.0.1:5000/baslat';
      try {
        final response = await http.post(Uri.parse(url), body: jsonEncode({}));
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Otomasyon başlatıldı!'),
                backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Hata: ${response.statusCode} - ${response.reasonPhrase}'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Bağlantı hatası: Sunucu çalışmıyor olabilir. Hata: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _otomasyonCalisiyor = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hatalı şifre!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sistem Otomasyon Aracı',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            _otomasyonCalisiyor
                ? const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.blueGrey),
                      SizedBox(height: 20),
                      Text('Otomasyon başlatılıyor...',
                          style: TextStyle(fontSize: 16)),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      _gosterSifrePenceresi(context);
                    },
                    child: const Text('Sistemi Başlat'),
                  ),
          ],
        ),
      ),
    );
  }
}
