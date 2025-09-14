import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Log model sınıfı
class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.stackTrace,
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

  void add(LogLevel level, String msg,
      [dynamic error, StackTrace? stackTrace]) {
    _logs.add(LogEntry(
      level: level,
      message: msg,
      timestamp: DateTime.now(),
      stackTrace: stackTrace?.toString(),
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
    logStorage.add(LogLevel.debug, "Debug log example");
    logStorage.add(LogLevel.info, "User logged in successfully");
    logStorage.add(LogLevel.warning, "API request took longer than 500ms");
    try {
      throw Exception("This is a test error message");
    } catch (e, s) {
      logStorage.add(LogLevel.error, "An unexpected error occurred", e, s);
  }

  void _clearLogs() {
    logStorage.clear();
    setState(() {});
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
        return Icons.bug_report_outlined;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warning:
      case LogLevel.error:
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
              Flexible(child: Text(entry.level.name.toUpperCase())),
            ],
          ),
          content: SingleChildScrollView(
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text:
                        "${_dateFormat.format(entry.timestamp)} ${_timeFormat.format(entry.timestamp)}\n"
                        "Message: ${entry.message}\n"
                        "${entry.stackTrace != null ? "Stack Trace:\n${entry.stackTrace}" : ""}"));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Log copied to clipboard")),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: Icon(_iconForLevel(entry.level),
            color: _colorForLevel(entry.level)),
        title: Text(
          entry.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_dateFormat.format(entry.timestamp)}  ${_timeFormat.format(entry.timestamp)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        onTap: () => _showLogDetails(entry),
        trailing: entry.stackTrace != null
            ? Tooltip(
                message: "Has stack trace",
                child:
                    Icon(Icons.description, size: 18, color: Colors.grey[500]),
              )
            : null,
      ),
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
            tooltip: "Generate Random Logs",
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addRandomLogs,
          ),
          IconButton(
            tooltip: "Clear All Logs",
            icon: const Icon(Icons.delete_outline),
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
                ? const Center(
                    child: Text("No logs to display",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    controller: _scrollController,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text("All"),
              selected: filter == null,
              onSelected: (_) => setState(() => filter = null),
            ),
            ...LogLevel.values.map((level) => ChoiceChip(
                  label: Text(level.name.capitalize()),
                  selected: filter == level,
                  onSelected: (_) => setState(() => filter = level),
                  avatar: CircleAvatar(
                    backgroundColor: _colorForLevel(level),
                    child: Icon(_iconForLevel(level),
                        size: 16, color: Colors.white),
                  ),
                )),
          ],
        ),
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
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
