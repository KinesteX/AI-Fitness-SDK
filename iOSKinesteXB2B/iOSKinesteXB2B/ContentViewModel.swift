
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var showWebView: Bool = false
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
    
    @Published var workoutData: String = ""

    func handle(message: String) {
           guard let data = message.data(using: .utf8),
                 let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                 let type = json["type"] as? String
           else {
               print("Could not parse JSON message from WebView.")
               return
           }

           let currentTime = getCurrentTime()
           
           switch type {
           case "finished_workout":
               workoutData += "\nWorkout finished, data received: \(json["data"] ?? "") @\(currentTime)"
               
           case "error_occured":
               workoutData += "\nThere was an error: \(json["data"] ?? "") @\(currentTime)"
               
           case "exercise_completed":
               workoutData += "\nExercise completed: \(json["data"] ?? "") @\(currentTime)"
              
           case "exitApp":
               showWebView = false
               workoutData += "\nUser closed workout window @\(currentTime)"
           
           default:
               break
           }
       }
       
       private func getCurrentTime() -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd HH:mm:ss a"
           return formatter.string(from: Date())
       }
}
