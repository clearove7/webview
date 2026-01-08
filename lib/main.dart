import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewChallengePage(),
    );
  }
}

class WebViewChallengePage extends StatefulWidget {
  const WebViewChallengePage({super.key});

  @override
  State<WebViewChallengePage> createState() => _WebViewChallengePageState();
}

class _WebViewChallengePageState extends State<WebViewChallengePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted); // 允许 alert / JS
  }

  Future<void> _loadFromAsset() async {
    // 1) Load from asset file: assets/index.html
    final html = await rootBundle.loadString('assets/index.html');
    await _controller.loadHtmlString(html);
  }

  Future<void> _loadFromHtmlString() async {
    // 2) Load from HTML String
    const htmlString = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>HTML String WebView</title>
  <style>
    body { font-family: Arial; background:#e3f2fd; padding: 20px; text-align:center; }
    h1 { color:#1976d2; }
    button { padding:10px 20px; border:none; border-radius:8px; font-size:16px; }
  </style>
</head>
<body>
  <h1>Hello from HTML String 👋</h1>
  <p>This page is loaded from <b>HTML String</b></p>
  <button onclick="alert('Hello from HTML String WebView!')">Click Me</button>
</body>
</html>
''';
    await _controller.loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge: WebView'),
        actions: [
          TextButton(
            onPressed: _loadFromAsset,
            child:
                const Text('Load Asset', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: _loadFromHtmlString,
            child: const Text('Load String',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadFromAsset, // 默认先加载 asset
        label: const Text('Start (Asset)'),
      ),
    );
  }
}
