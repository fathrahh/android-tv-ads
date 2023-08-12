import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          return null;
        },
      ));
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
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
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Colors.amber,
                        child: Column(children: [
                          Row(
                            children: [
                              Text("Apotek Manjur"),
                              Expanded(
                                child: Text("APotek Manjur"),
                              )
                            ],
                          ),
                          Expanded(
                            child: InAppWebView(
                              key: webViewKey,
                              initialUrlRequest: URLRequest(
                                  url: Uri.parse("https://www.youtube.com/")),
                              initialOptions: options,
                              pullToRefreshController:
                                  pullToRefreshController,
                              onWebViewCreated: (controller) {
                                webViewController = controller;
                              },
                              onLoadStart: (controller, url) {
                                setState(() {
                                  this.url = url.toString();
                                  urlController.text = this.url;
                                });
                              },
                              androidOnPermissionRequest:
                                  (controller, origin, resources) async {
                                return PermissionRequestResponse(
                                    resources: resources,
                                    action: PermissionRequestResponseAction
                                        .GRANT);
                              },
                              // shouldOverrideUrlLoading:
                              //     (controller, navigationAction) async {
                              //   var uri = navigationAction.request.url!;

                              //   if (![
                              //     "http",
                              //     "https",
                              //     "file",
                              //     "chrome",
                              //     "data",
                              //     "javascript",
                              //     "about"
                              //   ].contains(uri.scheme)) {
                              //     if (await canLaunch(url)) {
                              //       // Launch the App
                              //       await launch(
                              //         url,
                              //       );
                              //       // and cancel the request
                              //       return NavigationActionPolicy.CANCEL;
                              //     }
                              //   }

                              //   return NavigationActionPolicy.ALLOW;
                              // },
                              onLoadStop: (controller, url) async {
                                pullToRefreshController.endRefreshing();
                                setState(() {
                                  this.url = url.toString();
                                  urlController.text = this.url;
                                });
                              },
                              onLoadError: (controller, url, code, message) {
                                pullToRefreshController.endRefreshing();
                              },
                              onProgressChanged: (controller, progress) {
                                if (progress == 100) {
                                  pullToRefreshController.endRefreshing();
                                }
                                setState(() {
                                  this.progress = progress / 100;
                                  urlController.text = url;
                                });
                              },
                              onUpdateVisitedHistory:
                                  (controller, url, androidIsReload) {
                                setState(() {
                                  this.url = url.toString();
                                  urlController.text = this.url;
                                });
                              },
                              onEnterFullscreen: (controller) {
                                controller.evaluateJavascript(
                                  source: """
                                document.querySelector('video').webkitEnterFullScreen();
                                """,
                                );
                              },
                              onConsoleMessage: (controller, consoleMessage) {
                                print(consoleMessage);
                              },
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.teal,
                        child: Center(
                          child: Text("Iklan kanan disini"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Text(
                  "PROMO MERDEKA: SETIAP PEMBELIAN RHEA HEALTH BLA BLA BLA",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
