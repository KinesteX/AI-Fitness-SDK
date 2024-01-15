import SwiftUI
import WebKit

import SwiftUI
struct ContentView: View {
 
    @ObservedObject private var viewModel = ContentViewModel()

    @State var showStats = false
    let planCategories = ["Cardio", "Rehabilitation", "Strength", "Weight Management"]
    let workoutCategories = ["Fitness", "Rehabilitation"]
    @State var showSettings = false

    @State private var isLoading: Bool = true

   @State var showAnimation = true

    
    var body: some View {

        NavigationView {
            VStack{
                if viewModel.showWebView {
                    // main KinesteX Url:
                    WebView(url: "https://kineste-x-w.vercel.app/", isLoading: $isLoading, viewModel: viewModel)
                       // OPTIONAL: Show loading animation when WebView launches
                        .overlay(LottieAnimation(showAnimation: $showAnimation, isLoading: $isLoading))
                } else {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.black]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                        VStack{
                            HStack(spacing: 30){
                                Spacer()
                             
                                Button(action: {
                                    showStats.toggle()
                                }, label: {
                                    Image("stats").opacity(0.8)
                                }).sheet(isPresented: $showStats){
                                   
                                        VStack{
                                            Text("User Data Logging").italic().padding(.top, 30)
                                            Spacer()
                                            List {
                                                Text(viewModel.workoutData == "" ? "No Data, click on Open KinesteX to start recording" : viewModel.workoutData)
                                            }.listStyle(InsetListStyle())
                                            
                                            
                                            Spacer()
                                            Button(action: {
                                                showStats.toggle()
                                            }, label: {
                                                Text("Done").bold().foregroundColor(.black)
                                            }).padding()
                                                .background(Color.white).cornerRadius(15)
                                                .padding(.bottom, 50)
                                        }
                                }
                                Button(action: {
                                    showSettings.toggle()
                                }, label: {
                                   Image("settings")
                                }).sheet(isPresented: $showSettings){
                                    if #available(iOS 16, *) {
                                        VStack{
                                   
                                                
                                                Text("Select Category for Plans")
                                                    .bold()
                                                    .foregroundColor(.white)
                                                    .padding(.top)
                                                
                                                
                                                Picker("Select Plan Category", selection: $viewModel.planC) {
                                                    ForEach(planCategories, id: \.self) {
                                                        Text($0).tag($0)
                                                    }
                                                }
                                                .pickerStyle(MenuPickerStyle())
                                                .padding(.horizontal, 16)
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(15)
                                                
                                                Text("Select Category for Workouts")
                                                    .bold()
                                                    .foregroundColor(.white)
                                                    .padding(.top)
                                                
                                                
                                                Picker("Select Workout Category", selection: $viewModel.category) {
                                                    ForEach(workoutCategories, id: \.self) {
                                                        Text($0).tag($0)
                                                    }
                                                }
                                                .pickerStyle(MenuPickerStyle())
                                                .padding(.horizontal, 16)
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(15)
                                                
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    showSettings.toggle()
                                                }, label: {
                                                    Text("Submit").foregroundColor(.black)
                                                }).padding()
                                                    .background(Color.white).cornerRadius(15)
                                                    .padding(.bottom, 50)
                                            }.padding().presentationDetents([.height(650)])
                                        }
                                     else {
                                        VStack{
                                        
                                        
                                         
                                            Text("Select Category for Plans")
                                                .bold()
                                                .foregroundColor(.white)
                                                .padding(.top)
                                            
                                            
                                            Picker("Select Plan Category", selection: $viewModel.planC) {
                                                ForEach(planCategories, id: \.self) {
                                                    Text($0).tag($0)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .padding(.horizontal, 16)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(15)
                                            
                                            Text("Select Category for Workouts")
                                                .bold()
                                                .foregroundColor(.white)
                                                .padding(.top)
                                            
                                            
                                            Picker("Select Workout Category", selection: $viewModel.category) {
                                                ForEach(workoutCategories, id: \.self) {
                                                    Text($0).tag($0)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .padding(.horizontal, 16)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(15)
                                            
                                     
                                            Spacer()
                                            
                                            Button(action: {
                                                showSettings.toggle()
                                            }, label: {
                                                Text("Submit").foregroundColor(.black)
                                            }).padding()
                                              .background(Color.white).cornerRadius(15)
                                              .padding(.bottom, 50)
                                        }.padding()
                                    }
                                }
                                
                                
                            }.padding(.trailing, 30).padding(.top, 10)
                            ScrollView(showsIndicators: false){
                                VStack {
                                    HStack{
                                            Text("Hello!").foregroundColor(.white).bold().font(.largeTitle)
                                            Spacer()
                                    }
                                    HStack{
                                        Text("Keep up the great work with a workout in KinesteX").foregroundColor(.white).font(.caption)
                                    Spacer()
                                    }
                                    HStack{
                                        Text("This screen is a demo UI of what your app could look like. When you click any button below, KinesteX will launch.\nKinesteX B2B experience can be fully customized. Contact us at support@kinestex.com to learn more").foregroundColor(.red).font(.caption)
                                    Spacer()
                                    }.padding(.top, 5)
                                   
                                    VStack {
                                        
                                        HStack{
                                            Text("Your Workout Plans").font(.title2).foregroundColor(.white).bold()
                                        Spacer()
                                        }.padding(.top)
                                        
                                        // one way to show the option for plans
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                FeatureButton(iconName: "abs", label: "Strength Plan", action: {
                                                    viewModel.planC = "Strength"
                                                    viewModel.showWebView = true
                                                })
                                                FeatureButton(iconName: "dance", label: "Cardio Plan", action: {
                                                    viewModel.planC = "Cardio"
                                                 viewModel.showWebView = true
                                                })
                                                FeatureButton(iconName: "abs", label: "Weight", action: {
                                                    
                                                    viewModel.planC = "Weight Management"
                                                  viewModel.showWebView = true
                                                    
                                                })
                                                FeatureButton(iconName: "yoga", label: "Yoga", action: {
                                                    
                                                    viewModel.planC = "Cardio"
                                                  viewModel.showWebView = true
                                                    
                                                })
                                            }.padding()
                                            
                                        }.background(
                                          Color.white.opacity(0.3).cornerRadius(20)
                                       )
                                  
                                 
                                        Button(action: {
                                            viewModel.showWebView.toggle()
                                        }, label: {
                                            Text("Open KinesteX").font(.title).foregroundColor(.white).bold().padding().background(Color.purple.opacity(0.25).cornerRadius(20))
                                        }).padding(.top, 50)
                                  
                                    }
                                }
                                .padding()
                    
                            }
                        }
                        
                   }
                }
                
            }
           .background(.black)
            .navigationBarHidden(true)
            
        }
          
        
    }
}


