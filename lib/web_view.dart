import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
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
                cacheEnabled: true,  // Enable caching
                clearCache: false,  // Do not clear cache on launch
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                cacheMode: AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,  // Use cache when available
              ),
              ios: IOSInAppWebViewOptions(
                sharedCookiesEnabled: true,
                enableViewportScale: true,
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
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
