import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebViewPage extends StatefulWidget {
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final int bid = Get.arguments[0];
  final String url = Get.arguments[1];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: Uri.parse(
                //'http://khatokhal.org/khatokhal/payment/callback/idpay/?status=10&track_id=72294535&id=af7c7492a90c0605f723b5fd0399ba98&order_id=a51e47bb-be7c-4fd1-b1ce-3f0a5773ecae'
                url)),
            initialOptions: InAppWebViewGroupOptions(
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
            ),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              Uri uri = navigationAction.request.url!;
              if (["close"].contains(uri.scheme)) {
                Get.offNamedUntil(
                  '/book/$bid',
                  (route) {
                    return route.isFirst;
                  },
                );
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
          ),
        ),
      ),
    );
  }
}
