import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// Logger örneği

//dependencies:
//  logger: ^2.4.0

var logger = Logger();

void main() {
  runApp(const MyApp());

  // Örnek loglar
  logger.d("Debug log");
  logger.i("Info log");
  logger.w("Warning log");
  logger.e("Error log");
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Log Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text("Log Kontrol")),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              logger.i("Butona basıldı!");
            },
            child: const Text("Log Gönder"),
          ),
        ),
      ),
    );
  }
}
