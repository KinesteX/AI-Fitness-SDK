## Configuration

#### AndroidManifest.xml

Add the following permissions for camera and microphone usage:

```xml
<!-- Add this line inside the <manifest> tag -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIDEO_CAPTURE" />

```

#### Info.plist

Add the following keys for camera and microphone usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video streaming.</string>
```
Add the following dependencies to pubsec.yaml:

```xml

permission_handler: ^9.0.0
flutter_inappwebview: ^5.3.2
```

### Available categories to sort plans: 

The empty spaces in urls are formatted like this %20 so if you want to sort the plan based on the category copy the category as specified below

| **Plan Category** | 
| --- | 
| **Strength** | 
| **Weight%20Management** | 
| **Cardio** |
| **Rehabilitation** | 

### Available categories and sub categories to sort workouts: 

The empty spaces in urls are formatted like this %20 so if you want to sort the workout based on the sub_category copy the sub _category as specified below

| **Category** | **Sub-category** |
| --- | --- |
| **Fitness** | Stay%20Fit, Stretching, Cardio |
| **Rehabilitation** | Back%20Relief, Knee%20Therapy, Neck%20Relief |

## Available parameters:
```jsx
userId = "123abcd"; // Replace this with the actual user ID from your data source
age = 25; // Replace this with the actual age from your data source
gender = "male"; // Replace this with the actual gender from your data source
weight = 70; // Replace this with the actual weight from your data source
sub_category = "Stay%20Fit"; //The spaces in url values have to have "%20" in them (You can pass multiple sub categories, 
//sub_category = 'Stay%20Fit,Knee%20Therapy,Cardio' (They have to be separated by a comma without a space) 
category = "Fitness"; // You can only have one category
goals = "Weight Management"; // Replace this with the actual goal (COMING SOON)
// multiple goals ex:  goals = 'Weight Management, Mental Health'

```
### Handling responses from KinesteX:
Currently supported communication is via web postMessages. You can add a listener to the webview events. See specifications for your language below, but generally we let you know when user completes following events:

  ```jsx
    //finished the workout and now redirected to the all workouts section
    if (message.type === "finished_workout") {
      console.log("Received data:", message.data);
    /*
    Format of the Received data:
    {
    date = "2023-06-09T17:34:49.426Z";
    totalCalories = "0.96";
    totalRepeats = 3;
    totalSeconds = 18;
    userId = 123abcd;
    workout = "Fitness Lite";
    }
    */
    
    }
   
    if (message.type === "exitApp"){
      //clicked on exit, so handle the exit flow by removing WebView
      
    }
       if (message.type === "error_occured") {
       // saved workout data in case of an error that causes ui freeze
      console.log("Received data:", message.data);
     
    }
    if (message.type === "exercise_completed") {
      // (Optional)
      // saved exercise data in case you want to cache the data of each exercise
      console.log("Received data:", message.data);  
      /*
      Format:
      {
      exercise: "Overhead Arms Raise";
      repeats: 20;
      timeSpent: 30;
      calories: "5.0";
      }
      */

    }
```

## Usage Flutter: 


1. Request camera access: 
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


2. Specify parameters: 
```dart
String url = "";
String userId = "abc123";
String category = "Fitness";
String planCategory = "Strength"; // for specifying required plan category
// see other available parameters above
 
```
3. Show Webview: 

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
    url = "https://kineste-x-w.vercel.app/?userId=$userId&planC=$planCategory&category=$category";

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
