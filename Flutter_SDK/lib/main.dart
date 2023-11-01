import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  String url = "https://kinestex-sdk-git-redesign-v-m1r.vercel.app/";
  bool showWebview = false;
  List<String> workoutLogs = [];
  bool showBottomSheetLogs = false;

  InAppWebViewController? _controller;
  Map<String, String> postData = {
    "userId": "userrrrabc", // REQUIRED PARAM
    "category": "Rehabilitation",
    "planC": "Cardio",
    "company": "YOUR COMPANY", // REQUIRED PARAM
    "key": "YOUR APP KEY" // REQUIRED PARAM
  };
  Map<String, TextEditingController> controllers = {};
  late InAppWebViewGroupOptions options;

  @override
  void initState() {
    super.initState();

    // Add inside your initState method after super.initState();
    postData.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });

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
// Add below your existing declarations in _MyHomePageState
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
     window.postMessage(${jsonEncode(postData)}, '*');
  """);
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
     print("CONSOLEEEEE: $consoleMessage");
   },
   onProgressChanged: (InAppWebViewController controller, int progress) {
     print("WebView is loading (progress : $progress%)");
   },
   onLoadError: (InAppWebViewController controller, Uri? url, int code, String message) {
     print("Failed to load: $url with error $message (Code: $code)");
   }
   ,
   androidOnPermissionRequest:
       (InAppWebViewController controller, String origin, List<String> resources) async {
     return PermissionRequestResponse(
         resources: resources, action: PermissionRequestResponseAction.GRANT);
   },
 )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: postData.keys.length,
              itemBuilder: (context, index) {
                String key = postData.keys.elementAt(index);
                return ListTile(
                  title: Text(key),
                  subtitle: TextField(
                    controller: controllers[key],
                    onChanged: (value) {
                      setState(() {
                        postData[key] = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  TextEditingController keyController = TextEditingController();
                  TextEditingController valueController = TextEditingController();

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Add New Parameter"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: keyController,
                              decoration: InputDecoration(hintText: "Key"),
                            ),
                            TextField(
                              controller: valueController,
                              decoration: InputDecoration(hintText: "Value"),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text("Add"),
                            onPressed: () {
                              setState(() {
                                String key = keyController.text;
                                String value = valueController.text;
                                postData[key] = value;
                                controllers[key] = TextEditingController(text: value);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Add New Parameter'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showWebview = true;
                  });
                },
                child: Text('Start'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showBottomSheetLogs = true;
                  });
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          children: [
                            Text("User Data Logging", style: TextStyle(fontStyle: FontStyle.italic)),
                            Expanded(
                              child: ListView.builder(
                                itemCount: workoutLogs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    title: Text(workoutLogs[index]),
                                  );
                                },
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      }
                  );
                },
                child: Text("Logs"),
              )
            ],
          )
        ],
      ),
    );

  }


  void handleMessage(String message) {
    var parsedMessage = jsonDecode(message);

    String currentTime = "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
//data handling. HTTP post communication
    switch (parsedMessage['type']) {
      case "kinestex_launched":
        workoutLogs.add("Successfully launched the app. @${parsedMessage['data']}");
        break;
   case "workout_opened":
    workoutLogs.add("Workout opened. ${parsedMessage['data']}");
    break;
    case "workout_started":
    workoutLogs.add("Workout started. ${parsedMessage['data']}");
    break;
    case "plan_unlocked":
    workoutLogs.add("User unlocked plan. Data: ${parsedMessage['data']}");
    break;
      case "finished_workout":
        workoutLogs.add("Workout finished. Data: ${parsedMessage['data']}");
        break;
      case "error_occured":
        workoutLogs.add("There was an error: ${parsedMessage['data']}");
        break;
      case "exercise_completed":
        workoutLogs.add("Exercise completed: ${parsedMessage['data']}");
        break;
      case "exitApp":
        if (showWebview) {
          setState(() {
            showWebview = false;
          });
        }
        workoutLogs.add("User closed KinesteX window @$currentTime");
        break;
      default:
        workoutLogs.add("Received: ${parsedMessage['type']} ${parsedMessage['data']}");
        break;
    }
    setState(() {}); // to refresh UI
  }

}
