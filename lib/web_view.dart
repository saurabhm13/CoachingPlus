import 'package:coachingplusapp/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();

    requestPermission();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (webViewController != null) {
          webViewController!.reload();
        }
      },
    );
  }

  void requestPermission() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> storeTokenAndOnMobile() async {
    final token = await FirebaseApi().getToken();
    String tokenScript = 'localStorage.setItem("fcmToken", "$token");';
    String onMobileScript = 'localStorage.setItem("onmobileapp", "true");';
    await webViewController!.evaluateJavascript(source: tokenScript);
    await webViewController!.evaluateJavascript(source: onMobileScript);

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController?.canGoBack() ?? false) {
          webViewController!.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse("https://login.coachingplusapp.com/static/login"),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                cacheEnabled: true,
                clearCache: false,
                userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                cacheMode: AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
              ),
              ios: IOSInAppWebViewOptions(
                sharedCookiesEnabled: true,
                enableViewportScale: true,
              ),
            ),
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) async {
              webViewController = controller;
            },
            onLoadStop: (controller, url) async {
              pullToRefreshController?.endRefreshing();
              storeTokenAndOnMobile();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController?.endRefreshing();
              }
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              );
            },
          ),
        ),
      ),
    );
  }
}
