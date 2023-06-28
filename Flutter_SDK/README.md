## Usage Flutter: 

1. Add necessary permissions and libraries to AndroidManifest, Info.plist, and pubspec.yaml
```xml
AndroidManifest.xml:

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.VIDEO_CAPTURE" />

Info.plist:

<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video streaming.</string>

pubspec.yaml:

permission_handler: ^9.0.0
flutter_inappwebview: ^5.3.2
```

2. Request camera access: 
```dart
// Example usage: 
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
// ensure that camera access is granted before opening the webview
 if (await Permission.camera.request() == PermissionStatus.granted) {

 runApp(MyApp());

 } else {

  print("Permission not granted");

 }

}

```


3. Specify parameters: 
```dart
String url = "";
String userId = "abc123";
String category = "Fitness";

// see other available parameters above
 
```
4. Show Webview: 

```dart

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
       // IMPORTANT: HANDLE PERMISSION AT RUN TIME 
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

  // handling postMessages from KinesteX. 
  void handleMessage(String message) {
    var parsedMessage = jsonDecode(message);

    print("Received data: ${parsedMessage['data']}");
    switch (parsedMessage['type']) {
      case "finished_workout":
        // called when user clicks on finish workout button. returns statistics from the exercise
        print("Received data: ${parsedMessage['data']}");
        break;

      case "exitApp":
       // when user clicks on exit button 
        print("Received data: ${parsedMessage['data']}");
        if (showWebview) {
          setState(() {
            showWebview = false;
          });
        }
        break;

      case "error_occured":
        // called when errors occur on the webpage during the workout
        print("Received data: ${parsedMessage['data']}");
        break;
      
      case "exercise_completed":
        // called when user completed the exercise and goes to the next exercise
        print("Received data: ${parsedMessage['data']}");
        break;
    }
  }
}


```
