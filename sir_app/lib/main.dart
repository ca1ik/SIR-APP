import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const OtomasyonApp());
}

class OtomasyonApp extends StatelessWidget {
  const OtomasyonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Otomasyonu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1E1E1E),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
          titleLarge: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6200EE),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const OtomasyonSayfasi(),
    );
  }
}

class OtomasyonSayfasi extends StatefulWidget {
  const OtomasyonSayfasi({super.key});

  @override
  State<OtomasyonSayfasi> createState() => _OtomasyonSayfasiState();
}

class _OtomasyonSayfasiState extends State<OtomasyonSayfasi>
    with SingleTickerProviderStateMixin {
  final String _sifre = 'forfuture';
  final FocusNode _sifreFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyPress);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: const Color(0xFF121212),
      end: const Color(0xFF1E1E30),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);
    _sifreFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !Navigator.of(context).canPop()) {
      _showPasswordDialog();
    }
  }

  Future<void> _showPasswordDialog() async {
    final TextEditingController sifreController = TextEditingController();
    bool sifreHatali = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            FocusScope.of(context).requestFocus(_sifreFocusNode);
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Şifre Girin',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      focusNode: _sifreFocusNode,
                      controller: sifreController,
                      obscureText: true,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                        hintText: 'Şifreniz',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorText: sifreHatali ? 'Yanlış şifre' : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      onSubmitted: (String value) async {
                        if (value == _sifre) {
                          await _sendRequest(context);
                          if (mounted) Navigator.of(context).pop();
                        } else {
                          setState(() {
                            sifreHatali = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal',
                      style: TextStyle(color: Color(0xFFBB86FC))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB86FC),
                  ),
                  child: const Text('Onayla',
                      style: TextStyle(color: Colors.black)),
                  onPressed: () async {
                    if (sifreController.text == _sifre) {
                      await _sendRequest(context);
                      if (mounted) Navigator.of(context).pop();
                    } else {
                      setState(() {
                        sifreHatali = true;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendRequest(BuildContext context) async {
    try {
      final response =
          await http.post(Uri.parse('http://127.0.0.1:5000/baslat'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Otomasyon başlatıldı.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showErrorDialog(context, 'Otomasyon başlatılırken bir hata oluştu.');
      }
    } catch (e) {
      _showErrorDialog(context,
          'Sunucuya bağlanılamadı. Python sunucusunun çalıştığından emin olun.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value!,
                _colorAnimation.value!.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Hoş Geldiniz',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _showPasswordDialog,
                    child: const Text(
                      'Sistemi Başlat',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
