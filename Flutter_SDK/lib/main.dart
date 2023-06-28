import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 if (await Permission.camera.request() == PermissionStatus.granted) {
 runApp(MyApp());
 } else {
  print("Permission not granted");
 }

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userId = "abc123";
  String category = "Fitness";
  String url = "";
  bool showWebview = false;
  InAppWebViewController? _controller;

  late InAppWebViewGroupOptions options;

  @override
  void initState() {
    super.initState();
    url = "https://kineste-x-w.vercel.app/?userId=$userId&category=$category";

    options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView Camera Access'),
      ),
      body: showWebview
          ? InAppWebView(
        initialOptions: options,
        initialUrlRequest: URLRequest(url: Uri.parse(url)),
        onWebViewCreated: (InAppWebViewController controller) {
          _controller = controller;

          controller.addJavaScriptHandler(
            handlerName: 'messageHandler',
            callback: (args) {
              handleMessage(args[0]);
            },
          );
        },
        onLoadStop: (InAppWebViewController controller, Uri? url) async {
          await controller.evaluateJavascript(source: """
                  window.addEventListener('message', (event) => {
                    if (event.data === 'exitApp') {
                      window.flutter_inappwebview.callHandler('exitApp');
                    } else {
                      window.flutter_inappwebview.callHandler('messageHandler', event.data);
                    }
                  });
                """);
        },
        onConsoleMessage: (controller, consoleMessage) {
          print(consoleMessage);
        },
        onProgressChanged: (InAppWebViewController controller, int progress) {
          print("WebView is loading (progress : $progress%)");
        },
        androidOnPermissionRequest:
            (InAppWebViewController controller, String origin,
            List<String> resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        },
      )
          : Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              showWebview = true;
            });
          },
          child: Text('Start'),
        ),
      ),
    );
  }


  void handleMessage(String message) {
    var parsedMessage = jsonDecode(message);

    print("Received data: ${parsedMessage['data']}");
    switch (parsedMessage['type']) {
      case "finished_workout":
        print("Received data: ${parsedMessage['data']}");
        break;

      case "exitApp":
        print("Received data: ${parsedMessage['data']}");
        if (showWebview) {
          setState(() {
            showWebview = false;
          });
        }
        break;

      case "error_occured":
        print("Received data: ${parsedMessage['data']}");
        break;

      case "exercise_completed":
        print("Received data: ${parsedMessage['data']}");
        break;
    }
  }
}
