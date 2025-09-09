import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  // Geleneksel olarak masaüstü uygulamaları için URL'lerin doğru çalışmasını sağlar.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const HalilApp());
}

class HalilApp extends StatelessWidget {
  const HalilApp({super.key});

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
      home: const DilSecimSayfasi(),
    );
  }
}

class DilSecimSayfasi extends StatelessWidget {
  const DilSecimSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Language',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SifreGirisSayfasi(
                              lang: 'tr',
                              title: 'Şifrenizi Girin',
                              sifreHatali: 'Yanlış Şifre')),
                    );
                  },
                  child: const Text('Türkçe', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SifreGirisSayfasi(
                              lang: 'en',
                              title: 'Enter Your Password',
                              sifreHatali: 'Wrong Password')),
                    );
                  },
                  child: const Text('English', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SifreGirisSayfasi extends StatefulWidget {
  final String lang;
  final String title;
  final String sifreHatali;

  const SifreGirisSayfasi({
    super.key,
    required this.lang,
    required this.title,
    required this.sifreHatali,
  });

  @override
  State<SifreGirisSayfasi> createState() => _SifreGirisSayfasiState();
}

class _SifreGirisSayfasiState extends State<SifreGirisSayfasi> {
  final TextEditingController _sifreController = TextEditingController();
  final String _sifre = 'forfuture';
  bool _isPasswordWrong = false;

  void _checkPassword() {
    if (_sifreController.text == _sifre) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChatSayfasi(lang: widget.lang),
        ),
      );
    } else {
      setState(() {
        _isPasswordWrong = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFBB86FC).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBB86FC).withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 20,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Color(0xFFBB86FC),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _sifreController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    hintText: '*********',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _isPasswordWrong ? widget.sifreHatali : null,
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  onSubmitted: (value) => _checkPassword(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB86FC),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.lang == 'tr' ? 'Giriş Yap' : 'Login',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoChatSayfasi extends StatefulWidget {
  final String lang;

  const VideoChatSayfasi({super.key, required this.lang});

  @override
  State<VideoChatSayfasi> createState() => _VideoChatSayfasiState();
}

class _VideoChatSayfasiState extends State<VideoChatSayfasi> {
  late VideoPlayerController _videoController;
  final TextEditingController _chatController = TextEditingController();
  final List<String> _messages = [];

  String get _komut =>
      widget.lang == 'tr' ? 'Uyan Baba Evde!' : 'Wake up Daddy\'s Home!';

  String get _mesajGonder =>
      widget.lang == 'tr' ? 'Mesaj Gönder' : 'Send Message';

  String get _hataMesaji => widget.lang == 'tr'
      ? 'Sunucuya bağlanılamadı. Python sunucusunun çalıştığından emin olun.'
      : 'Could not connect to the server. Make sure the Python server is running.';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoPath =
        'assets/${widget.lang == 'tr' ? 'wakeuptr.mp4' : 'wakeup.mp4'}';
    _videoController = VideoPlayerController.asset(videoPath);
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.play();
    setState(() {});
  }

  void _sendMessage() async {
    final message = _chatController.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add(message);
    });

    if (message.toLowerCase() == _komut.toLowerCase()) {
      await _sendAutomationRequest();
    }

    _chatController.clear();
  }

  Future<void> _sendAutomationRequest() async {
    try {
      final videoPath = Platform.isWindows
          ? 'C:\\Users\\user\\Documents\\GitHub\\SIR-APP\\sir_app\\assets\\${widget.lang == 'tr' ? 'wakeuptr.mp4' : 'wakeup.mp4'}'
          : 'assets/${widget.lang == 'tr' ? 'wakeuptr.mp4' : 'wakeup.mp4'}';

      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/start_automation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'video_path': videoPath}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.lang == 'tr'
                    ? 'Otomasyon başarıyla başlatıldı!'
                    : 'Automation started successfully!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorDialog(context, _hataMesaji);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, _hataMesaji);
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.lang == 'tr' ? 'Hata' : 'Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(widget.lang == 'tr' ? 'Tamam' : 'OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video arka planı
          if (_videoController.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          // Mor renkli şeffaf katman
          Container(
            color: const Color(0xFFBB86FC).withOpacity(0.2),
          ),
          // Chat bloğu
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _messages[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          hintText: widget.lang == 'tr'
                              ? 'Komutunuzu girin...'
                              : 'Enter your command...',
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: const Color(0xFFBB86FC),
                      child: const Icon(Icons.send, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
aimport 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const HalilApp());
}

/// --- Çoklu Dil Yönetimi ---
class AppTexts {
  static const texts = {
    'tr': {
      'selectLanguage': 'Dil Seçiniz',
      'enterPassword': 'Şifrenizi Girin',
      'wrongPassword': 'Yanlış Şifre',
      'login': 'Giriş Yap',
      'command': 'Komutunuzu girin...',
      'sendMessage': 'Mesaj Gönder',
      'automationStarted': 'Otomasyon başarıyla başlatıldı!',
      'error': 'Sunucuya bağlanılamadı. Python sunucusunun çalıştığından emin olun.',
      'wakeCommand': 'Uyan Baba Evde!',
    },
    'en': {
      'selectLanguage': 'Select Your Language',
      'enterPassword': 'Enter Your Password',
      'wrongPassword': 'Wrong Password',
      'login': 'Login',
      'command': 'Enter your command...',
      'sendMessage': 'Send Message',
      'automationStarted': 'Automation started successfully!',
      'error': 'Could not connect to the server. Make sure the Python server is running.',
      'wakeCommand': 'Wake up Daddy\'s Home!',
    },
  };

  static String get(String lang, String key) {
    return texts[lang]?[key] ?? key;
  }
}

/// --- Ana Uygulama ---
class HalilApp extends StatelessWidget {
  const HalilApp({super.key});

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
      home: const DilSecimSayfasi(),
    );
  }
}

/// --- Dil Seçim Sayfası ---
class DilSecimSayfasi extends StatelessWidget {
  const DilSecimSayfasi({super.key});

  void _navigate(BuildContext context, String lang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SifreGirisSayfasi(lang: lang),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTexts.get('en', 'selectLanguage'),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _navigate(context, 'tr'),
                  child: const Text('Türkçe', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => _navigate(context, 'en'),
                  child: const Text('English', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Şifre Giriş Sayfası ---
class SifreGirisSayfasi extends StatefulWidget {
  final String lang;

  const SifreGirisSayfasi({super.key, required this.lang});

  @override
  State<SifreGirisSayfasi> createState() => _SifreGirisSayfasiState();
}

class _SifreGirisSayfasiState extends State<SifreGirisSayfasi> {
  final TextEditingController _sifreController = TextEditingController();
  final String _sifre = 'forfuture';
  bool _isPasswordWrong = false;

  void _checkPassword() {
    if (_sifreController.text == _sifre) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChatSayfasi(lang: widget.lang),
        ),
      );
    } else {
      setState(() {
        _isPasswordWrong = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFBB86FC).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppTexts.get(widget.lang, 'enterPassword'),
                style: const TextStyle(
                  color: Color(0xFFBB86FC),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _sifreController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '********',
                  errorText: _isPasswordWrong
                      ? AppTexts.get(widget.lang, 'wrongPassword')
                      : null,
                ),
                onSubmitted: (_) => _checkPassword(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPassword,
                child: Text(AppTexts.get(widget.lang, 'login')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Video Chat Sayfası ---
class VideoChatSayfasi extends StatefulWidget {
  final String lang;

  const VideoChatSayfasi({super.key, required this.lang});

  @override
  State<VideoChatSayfasi> createState() => _VideoChatSayfasiState();
}

class _VideoChatSayfasiState extends State<VideoChatSayfasi> {
  late VideoPlayerController _videoController;
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoPath =
        'assets/${widget.lang == 'tr' ? 'wakeuptr.mp4' : 'wakeup.mp4'}';
    _videoController = VideoPlayerController.asset(videoPath);
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.play();
    setState(() {});
  }

  void _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {

    _chatController.clear();
  }

  Future<void> _sendAutomationRequest() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/start_automation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'video_path': 'assets/test.mp4'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _messages.add({
            'sender': 'system',
            'text': AppTexts.get(widget.lang, 'automationStarted')
  }

        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoController.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          /// Mor katman
          Container(color: const Color(0xFFBB86FC).withOpacity(0.2)),

          /// Sohbet
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['sender'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blueAccent.withOpacity(0.7)
                              : Colors.purple.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(msg['text'] ?? '',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: AppTexts.get(widget.lang, 'command'),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: const Color(0xFFBB86FC),
                      child: const Icon(Icons.send, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
