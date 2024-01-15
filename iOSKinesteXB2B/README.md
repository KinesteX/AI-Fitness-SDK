https://github.com/V-m1r/KinesteXSDK/assets/62508191/a796a98c-55c4-42d5-8ecd-731d2997e488

## Configuration

#### Info.plist

Add the following keys for camera usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for AI pose analysis.</string>
```

### Available categories to sort plans (param key is planC): 

| **Plan Category (key: planC)** | 
| --- | 
| **Strength** | 
| **Cardio** |
| **Rehabilitation** | 


### Available categories and sub categories to sort workouts: 

| **Category (key: category)** | 
| --- | 
| **Fitness** |
| **Rehabilitation** |

## WebView Camera 

This guide provides a detailed walkthrough of the SwiftUI code that integrates a web view with camera access and communicates with the KinesteX B2B. 

### Initial Setup

1. **Prerequisites**:
    - Ensure you've added the necessary permissions in `Info.plist`.

2. **Initialization**:
    
    - Setup a model that will pass, store, and modify necessary data points
    ```Swift
    
    import SwiftUI

    class ContentViewModel: ObservableObject {
    @Published var showWebView: Bool = false // toggled to display the Webview with KinesteX
    @AppStorage("apiKey") var apiKey: String = "YOUR API KEY"
    @AppStorage("companyName") var companyName: String = "YOUR COMPANY NAME"
    @AppStorage("userId") var userId: String = "YOUR USER ID"
    @AppStorage("planC") var planC: String = "Cardio"
    @AppStorage("category") var category: String = "Fitness"
    
    @Published var message: String = "" {
        didSet {
            handle(message: message)
        }
    }
    
    @Published var workoutData: String = "" // data about user's workout data can be accessed here

    func handle(message: String) {
           guard let data = message.data(using: .utf8),
                 let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                 let type = json["type"] as? String
           else {
               print("Could not parse JSON message from WebView.")
               return
           }

          
           switch type {
             case "kinestex_launched":
               // KinesteX was launched
                  workoutData += "\nKinesteX Launched: \(json["data"] ?? "")"
           case "finished_workout":
               // workout finished
               workoutData += "\nWorkout finished, data received: \(json["data"] ?? "")"
               
           case "error_occured":
               // error: camera access could not be granted
               showWebView = false
               workoutData += "\nThere was an error: \(json["data"] ?? "")"
               
           case "exercise_completed":
               workoutData += "\nExercise completed: \(json["data"] ?? "")"
              
           case "exitApp":
               // close the webview
               showWebView = false
               workoutData += "\nUser closed workout window"
               
           case "workoutOpened":
               // user opened a workout details page
                  workoutData += "\nWorkout opened: \(json["data"] ?? "")"
           case "workoutStarted":
               // user started a workout
                  workoutData += "\nWorkout started: \(json["data"] ?? "")"
               
           case "plan_unlocked":
               //user unlocked a new plan
               workoutData += "\nPlan unlocked: \(json["data"] ?? "")"
    
           default:
               break
           }
       }
       
 
   }

    ```
- Create a Webview component that will display KinesteX and handle data communication
  ```Swift

  import WebKit
  import SwiftUI

  struct WebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool // Binding state

    // OPTIONAL: Pass the model as an observed object so that we can handle the workout data with UI updates
   //  and have category and planC values dynamically change
    @ObservedObject var viewModel: ContentViewModel


    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        let preferences = WKPreferences()
        // important! Please enable javascript 
        preferences.javaScriptEnabled = true

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        contentController.add(context.coordinator, name: "listener")

         // specify the background color of the webview based on your KinesteX's theme
         webView.backgroundColor = .black
         webView.scrollView.backgroundColor = .black
          


        if let url = URL(string: self.url) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, isLoading: $isLoading)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        var isLoading: Binding<Bool> // Binding to the loading state

        init(_ parent: WebView, isLoading: Binding<Bool>) {
                    self.parent = parent
                    self.isLoading = isLoading
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading.wrappedValue = true // WebView init started, consider displaying a loading screen
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            // Webview init complete, displaying KinesteX
            isLoading.wrappedValue = false

            // add more parameters here like height, age, weight
            let script = """
            window.postMessage({
                'key': '\(parent.viewModel.apiKey)',
                'company': '\(parent.viewModel.companyName)',
                'userId': '\(parent.viewModel.userId)',
                'planC': '\(parent.viewModel.planC)',
                'category': '\(parent.viewModel.category)'
                
            });
            """
            // pass the values
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    print("JavaScript error: \(error)")
                }
            }
        }
        // listen for messages
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "listener", let messageBody = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.viewModel.message = messageBody
                }
            }
        }
      }
    }

  ```

### Bringing it all together

1. **Launching WebView**:
There is multiple ways to go about displaying Webview, you may choose to do `fullScreenCover`, but in our example we will display the Webview in the parent view
```Swift
// your parent view
NavigationView {

VStack {

if viewModel.showWebView {
    // main KinesteX URL:
    WebView(url: "https://kineste-x-w.vercel.app/", isLoading: $isLoading, viewModel: viewModel)
    // OPTIONAL: Show loading animation when WebView launches
    .overlay(LottieAnimation(showAnimation: $showAnimation, isLoading: $isLoading))
} else {

// ... 

}

}.navigationBarHidden(true) // we recommend to hide navigation bar as we provide the exit button in within KinesteX
// - if that is not possible, consider displaying KinesteX with fullScreenCover

} 

```

2. **Communicating Data**: 
   - `ContentViewModel` handles receiving data from KinesteX and  `WebView` handles passing it:
```
func handle(message: String) {
           guard let data = message.data(using: .utf8),
                 let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                 let type = json["type"] as? String
           else {
               print("Could not parse JSON message from WebView.")
               return
           }

           switch type {
            case "kinestex_launched":
               // KinesteX was launched
                  workoutData += "\nKinesteX Launched: \(json["data"] ?? "")"
           case "finished_workout":
               // workout finished
               workoutData += "\nWorkout finished, data received: \(json["data"] ?? "")"
               
           case "error_occured":
               // error: camera access could not be granted
               showWebView = false
               workoutData += "\nThere was an error: \(json["data"] ?? "")"
               
           case "exercise_completed":
               workoutData += "\nExercise completed: \(json["data"] ?? "")"
              
           case "exitApp":
               // close the webview
               showWebView = false
               workoutData += "\nUser closed workout window"
               
           case "workoutOpened":
               // user opened a workout details page
                  workoutData += "\nWorkout opened: \(json["data"] ?? "")"
           case "workoutStarted":
               // user started a workout
                  workoutData += "\nWorkout started: \(json["data"] ?? "")"
               
           case "plan_unlocked":
               //user unlocked a new plan
               workoutData += "\nPlan unlocked: \(json["data"] ?? "")"
           default:
               break
           }
       }

```

   The core of the `handleMessage` function is a switch statement that checks the `type` property of the parsed message. Each case corresponds to a different type of action or event that occurred in the KinesteX.
    
    - `kinestex_launched`: Logs when the KinesteX SDK is successfully launched.
    - `workout_opened`: Logs when a workout is opened.
    - `workout_started`: Logs when a workout is started.
    - `plan_unlocked`: Logs when a user unlocks a plan.
    - `finished_workout`: Logs when a workout is finished.
    - `error_occured`: Logs when there's an error. (Coming soon)
    - `exercise_completed`: Logs when an exercise is completed.
    - `exitApp`: Logs when the KinesteX window is closed and sets the `showWebview` to false, which will hide the WebView.
    - `default`: For all other message types, it just logs the received type and data.

   Each log entry is added to the `workoutData` string. You can process that data for your needs

   
- `Webview` sends data through the java script post message injection: 
```
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            // Webview init complete, displaying KinesteX
            isLoading.wrappedValue = false

            // add more parameters here like height, age, weight
            let script = """
            window.postMessage({
                'key': '\(parent.viewModel.apiKey)',
                'company': '\(parent.viewModel.companyName)',
                'userId': '\(parent.viewModel.userId)',
                'planC': '\(parent.viewModel.planC)',
                'category': '\(parent.viewModel.category)'   
                
            });
            """
            // pass the values
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    print("JavaScript error: \(error)")
                }
            }
        }
```



### What to keep in mind:

1. **For best feedback please share with us as much info about user as possible**:
   -  If you can share user's weight, height, and age that would greatly help us recommend the best plans. 
    - You can also specify the plans for the user yourselves by choosing the appropriate `planC` value or recommending workouts through `category` parameter.
    
2. **Make sure to use correct secret key and company name when openeing the webview**


### Conclusion

This implementation integrates the KinesteX B2B solution within a web view and maintains a logging system for all activities. The `handleMessage` function is central to the app's functionality, processing all communications from the web content and updating the logs accordingly. This provides a comprehensive record of user interactions with the KinesteX View.

Any questions? Contact us at support@kinestex.com
