import WebKit
import SwiftUI
struct WebView: UIViewRepresentable {
    let url: String
    @Binding var isLoading: Bool // Binding state

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
                  
            isLoading.wrappedValue = true // WebView init started
       
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
