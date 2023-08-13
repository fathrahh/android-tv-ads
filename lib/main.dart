import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:android_tv_ads/template/youtube_frame.dart';
import 'package:marquee/marquee.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    // late final PlatformWebViewControllerCreationParams params;
    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }

    final WebViewController controller = WebViewController();
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null &&
                change.url!.contains('youtube.com/watch?v=')) {
              RegExp regExp = RegExp(r'v=([A-Za-z0-9_\-]+)');
              Match? match = regExp.firstMatch(change.url!);
              debugPrint(change.url);
              debugPrint(match.toString());

              if (match != null && match.groupCount >= 1) {
                _controller.loadHtmlString(htmlTemplate(match.group(1)!));
              }
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://youtube.com'));

    // #docregion platform_features
    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: Colors.amber,
                        child: Column(children: [
                          const Row(
                            children: [
                              Text("Apotek Manjur"),
                              Expanded(
                                child: Text("APotek Manjur"),
                              )
                            ],
                          ),
                          Expanded(
                            child: WebViewWidget(
                              controller: _controller,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Colors.teal,
                        child: const Center(
                          child: Text("Iklan kanan"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 32.0),
                child: Row(
                  children: [
                    const Text(
                      "PROMO MERDEKA : ",
                    ),
                    Expanded(
                      child: Container(
                        width: double.maxFinite,
                        height: 40,
                        child: Marquee(text: 'Hello World', blankSpace: 300.0),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
