import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LogApp());
}

/// Ana uygulama
class LogApp extends StatelessWidget {
  const LogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Log Viewer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const LogHomePage(),
    );
  }
}

/// Log türlerini temsil eden enum
enum LogLevel { debug, info, warning, error }

/// Log model sınıfı
class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
  });
}

/// Global logger
final Logger logger = Logger(
  printer: PrettyPrinter(
    colors: false,
    printEmojis: true,
    printTime: true,
  ),
);

/// Log saklayıcı singleton
class LogStorage {
  static final LogStorage _instance = LogStorage._internal();
  factory LogStorage() => _instance;
  LogStorage._internal();

  final List<LogEntry> _logs = [];

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void add(LogLevel level, String msg) {
    _logs.add(LogEntry(
      level: level,
      message: msg,
      timestamp: DateTime.now(),
    ));
  }

  void clear() => _logs.clear();
}

/// Ana sayfa
class LogHomePage extends StatefulWidget {
  const LogHomePage({super.key});

  @override
  State<LogHomePage> createState() => _LogHomePageState();
}

class _LogHomePageState extends State<LogHomePage> {
  LogLevel? filter;
  String searchQuery = "";

  final logStorage = LogStorage();

  void _addRandomLogs() {
    logger.d("Debug log example");
    logStorage.add(LogLevel.debug, "Debug log example");

    logger.i("Info log example");
    logStorage.add(LogLevel.info, "Info log example");

    logger.w("Warning log example");
    logStorage.add(LogLevel.warning, "Warning log example");

    logger.e("Error log example");
    logStorage.add(LogLevel.error, "Error log example");

    setState(() {});
  }

  void _clearLogs() {
    logStorage.clear();
    setState(() {});
  }

  List<LogEntry> _filteredLogs() {
    return logStorage.logs
        .where((log) {
          final matchesFilter = filter == null || log.level == filter;
          final matchesSearch = searchQuery.isEmpty ||
              log.message.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesFilter && matchesSearch;
        })
        .toList()
        .reversed
        .toList();
  }

  IconData _iconForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
    }
  }

  Color _colorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.blueGrey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
    }
  }

  void _showLogDetails(LogEntry entry) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(_iconForLevel(entry.level),
                  color: _colorForLevel(entry.level)),
              const SizedBox(width: 8),
              Text(entry.level.name.toUpperCase()),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              "${entry.timestamp}\n\n${entry.message}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: entry.message));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Log copied!")),
                );
              },
              child: const Text("Copy"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogTile(LogEntry entry) {
    return ListTile(
      leading:
          Icon(_iconForLevel(entry.level), color: _colorForLevel(entry.level)),
      title: Text(
        entry.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(entry.timestamp.toIso8601String()),
      onTap: () => _showLogDetails(entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = _filteredLogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Log Viewer"),
        actions: [
          IconButton(
            tooltip: "Generate Logs",
            icon: const Icon(Icons.add),
            onPressed: _addRandomLogs,
          ),
          IconButton(
            tooltip: "Clear Logs",
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          _buildSearchBar(),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text("No logs yet"))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) => _buildLogTile(logs[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text("All"),
            selected: filter == null,
            onSelected: (_) => setState(() => filter = null),
          ),
          ChoiceChip(
            label: const Text("Debug"),
            selected: filter == LogLevel.debug,
            onSelected: (_) => setState(() => filter = LogLevel.debug),
          ),
          ChoiceChip(
            label: const Text("Info"),
            selected: filter == LogLevel.info,
            onSelected: (_) => setState(() => filter = LogLevel.info),
          ),
          ChoiceChip(
            label: const Text("Warning"),
            selected: filter == LogLevel.warning,
            onSelected: (_) => setState(() => filter = LogLevel.warning),
          ),
          ChoiceChip(
            label: const Text("Error"),
            selected: filter == LogLevel.error,
            onSelected: (_) => setState(() => filter = LogLevel.error),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search logs...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }
}
