import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(const OtomasyonApp());
}

class OtomasyonApp extends StatelessWidget {
  const OtomasyonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halil App',
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
      home: const DilSecimiSayfasi(),
    );
  }
}

class DilSecimiSayfasi extends StatelessWidget {
  const DilSecimiSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halil App'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Lütfen bir dil seçin', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OtomasyonSayfasi(
                      language: 'tr',
                    ),
                  ),
                );
              },
              child: const Text('Türkçe'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OtomasyonSayfasi(
                      language: 'en',
                    ),
                  ),
                );
              },
              child: const Text('English'),
            ),
          ],
        ),
      ),
    );
  }
}

class OtomasyonSayfasi extends StatefulWidget {
  final String language;
  const OtomasyonSayfasi({super.key, required this.language});

  @override
  State<OtomasyonSayfasi> createState() => _OtomasyonSayfasiState();
}

class _OtomasyonSayfasiState extends State<OtomasyonSayfasi>
    with SingleTickerProviderStateMixin {
  final FocusNode _sifreFocusNode = FocusNode();
  final TextEditingController _chatController = TextEditingController();
  final String _sifre = 'forfuture';
  bool _isChatVisible = false;

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
    _chatController.dispose();
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !_isChatVisible &&
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
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                widget.language == 'tr' ? 'Şifre Girin' : 'Enter Password',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
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
                        hintText:
                            widget.language == 'tr' ? 'Şifreniz' : 'Password',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorText: sifreHatali
                            ? (widget.language == 'tr'
                                ? 'Yanlış şifre'
                                : 'Incorrect password')
                            : null,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      onSubmitted: (String value) async {
                        if (value == _sifre) {
                          await _sendMusicRequest(widget.language, context);
                          if (mounted) Navigator.of(context).pop();
                          setState(() {
                            _isChatVisible = true;
                          });
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
                  child: Text(
                    widget.language == 'tr' ? 'İptal' : 'Cancel',
                    style: const TextStyle(color: Color(0xFFBB86FC)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB86FC),
                  ),
                  child: Text(
                    widget.language == 'tr' ? 'Onayla' : 'Confirm',
                    style: const TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    if (sifreController.text == _sifre) {
                      await _sendMusicRequest(widget.language, context);
                      if (mounted) Navigator.of(context).pop();
                      setState(() {
                        _isChatVisible = true;
                      });
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

  Future<void> _sendMusicRequest(String language, BuildContext context) async {
    try {
      final response = await http
          .post(Uri.parse('http://127.0.0.1:5000/play_music/$language'));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.language == 'tr'
                    ? 'Müzik çalıyor...'
                    : 'Music playing...',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.purple,
            ),
          );
        }
      } else {
        if (mounted)
          _showErrorDialog(context, 'Müzik başlatılırken bir hata oluştu.');
      }
    } catch (e) {
      if (mounted)
        _showErrorDialog(context,
            'Sunucuya bağlanılamadı. Python sunucusunun çalıştığından emin olun.');
    }
  }

  Future<void> _sendAutomationRequest(BuildContext context) async {
    try {
      final response =
          await http.post(Uri.parse('http://127.0.0.1:5000/baslat'));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.language == 'tr'
                    ? 'Otomasyon başlatıldı.'
                    : 'Automation started.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted)
          _showErrorDialog(context, 'Otomasyon başlatılırken bir hata oluştu.');
      }
    } catch (e) {
      if (mounted)
        _showErrorDialog(context,
            'Sunucuya bağlanılamadı. Python sunucusunun çalıştığından emin olun.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.language == 'tr' ? 'Hata' : 'Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(widget.language == 'tr' ? 'Tamam' : 'OK'),
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
            appBar: AppBar(
              title: const Text('Halil App'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.language == 'tr' ? 'Hoş Geldiniz' : 'Welcome',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _showPasswordDialog,
                    child: Text(
                      widget.language == 'tr'
                          ? 'Sistemi Başlat'
                          : 'Start System',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  if (_isChatVisible) ...[
                    const SizedBox(height: 48),
                    Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBB86FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: widget.language == 'tr'
                              ? 'Komutunuzu girin...'
                              : 'Enter your command...',
                          hintStyle:
                              TextStyle(color: Colors.black.withOpacity(0.5)),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (String value) {
                          if (value.toLowerCase() == "wake up daddy's home!") {
                            _sendAutomationRequest(context);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
