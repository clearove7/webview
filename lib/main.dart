import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewNavigationEventsPage(),
    );
  }
}

class WebViewNavigationEventsPage extends StatefulWidget {
  const WebViewNavigationEventsPage({super.key});

  @override
  State<WebViewNavigationEventsPage> createState() =>
      _WebViewNavigationEventsPageState();
}

class _WebViewNavigationEventsPageState
    extends State<WebViewNavigationEventsPage> {
  late final WebViewController _controller;

  bool _isLoading = true;

  // ✅ 你的 HTML（内嵌在 main.dart 里）
  static const String _myHtmlString = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Asset WebView</title>
  <style>
    body {
      font-family: Arial;
      background-color: #f2f2f2;
      padding: 20px;
      text-align: center;
    }
    h1 {
      color: #2196F3;
    }
    button {
      padding: 10px 20px;
      background-color: #2196F3;
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
    }
  </style>
</head>
<body>
  <h1>Asset WebView Page 👋</h1>
  <p>This HTML file is loaded from <b>HTML String inside main.dart</b></p>

  <button onclick="alert('Hello from Asset WebView!')">
    Click Me
  </button>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // ✅ HUD：onPageStarted 显示
          onPageStarted: (url) {
            print("Page started loading: $url");
            setState(() => _isLoading = true);
          },
          // ✅ HUD：onPageFinished 关闭
          onPageFinished: (url) {
            print("Page finished loading: $url");
            setState(() => _isLoading = false);
          },

          // ✅ 导航控制：允许 flutter.dev + docs.flutter.dev
          // （你加载本地 HTML 时不受这个限制；只对网络跳转有效）
          onNavigationRequest: (request) {
            final url = request.url;

            final allowFlutter = url.startsWith("https://flutter.dev");
            final allowDocs = url.startsWith("https://docs.flutter.dev");

            if (allowFlutter || allowDocs) {
              return NavigationDecision.navigate;
            }

            // 其他网址拦截
            print("Blocked navigation to: $url");
            return NavigationDecision.prevent;
          },
        ),
      );

    // ✅ 默认先加载：你的 HTML String
    _controller.loadHtmlString(_myHtmlString);
  }

  Future<void> _loadFromAsset() async {
    // 如果你还想从 assets/index.html 加载（可选）
    final html = await rootBundle.loadString('assets/index.html');
    await _controller.loadHtmlString(html);
  }

  Future<void> _loadFromHtmlString() async {
    await _controller.loadHtmlString(_myHtmlString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebView Navigation & Events"),
        actions: [
          IconButton(
            tooltip: "Load HTML String",
            icon: const Icon(Icons.code),
            onPressed: _loadFromHtmlString,
          ),
          IconButton(
            tooltip: "Load Asset HTML",
            icon: const Icon(Icons.folder),
            onPressed: _loadFromAsset,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                await _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                await _controller.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
