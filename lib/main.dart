import 'package:flutter/material.dart';
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

  // ✅ Progress HUD 控制
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // ✅ 作业要求：onPageStarted 显示 HUD
          onPageStarted: (url) {
            print("Page started loading: $url");
            setState(() => _isLoading = true);
          },

          // ✅ 作业要求：onPageFinished 关闭 HUD
          onPageFinished: (url) {
            print("Page finished loading: $url");
            setState(() => _isLoading = false);
          },

          // ✅ 导航控制：允许 flutter.dev 和 docs.flutter.dev
          onNavigationRequest: (request) {
            // 老师原本是 startsWith("https://flutter.dev")
            // 现在我们保持一样写法，但额外允许 docs.flutter.dev
            final url = request.url;

            final allowFlutter = url.startsWith("https://flutter.dev");
            final allowDocs = url.startsWith("https://docs.flutter.dev");

            if (allowFlutter || allowDocs) {
              return NavigationDecision.navigate;
            }

            print("Blocked navigation to: $url");
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse("https://flutter.dev"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebView Navigation & Events"),
        actions: [
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

      // ✅ HUD 用 Stack 叠在 WebView 上（不改老师结构，只加一层）
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          // Progress HUD
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
