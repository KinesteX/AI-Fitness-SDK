import SwiftUI
import WebKit

class ContentViewModel: ObservableObject {
    @Published var showWebView: Bool = false
    @Published var message: String = "" {
        didSet {
            handle(message: message)
        }
    }

    func handle(message: String) {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let type = json["type"] as? String
        else {
            print("Could not parse JSON message from WebView.")
            return
        }
       

        switch type {
        case "finished_workout":
            print("----------------------------------\nWorkout finished, data received: ", "\(json["data"] ?? "")\n----------------------------------")
            
        case "error_occured":
            print("There was an error: ", json["data"] ?? "")
            
        case "exercise_completed":
            print("Exercise completed: ", json["data"] ?? "")
           
        case "exitApp":
            showWebView = false
        
        default:
            break
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: String
    @ObservedObject var viewModel: ContentViewModel

    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()

        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        contentController.add(context.coordinator, name: "listener")

        if let url = URL(string: self.url) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "listener", let messageBody = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.viewModel.message = messageBody
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()
    var userId = "123abcd"
    var sub_category = "Cardio"
    var category = "Fitness"
    var body: some View {
        VStack {
            if viewModel.showWebView {
                WebView(url: "https://kineste-x-w.vercel.app/?userId=\(userId)&sub_category=\(sub_category)&category=\(category)", viewModel: viewModel)
               
            } else {
                Button(action: {
                    self.viewModel.showWebView.toggle()
                }) {
                    Text("Open KinesteX").foregroundColor(.white).bold().shadow(radius: 15).padding(30).background(
                        Color.green.cornerRadius(20)
                    )
                }
            }
        }
    }
}
