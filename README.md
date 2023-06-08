```markdown
# README for Git

This guide will walk you through the installation and configuration of the WebView component for integrating KinesteX workouts into your app.

## Installation

Install `react-native-webview`:

```bash
npm install react-native-webview
```

## Configuration

### AndroidManifest.xml

Add the following permissions for camera and microphone usage:

```xml
<!-- Add this line inside the <manifest> tag -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### Info.plist

Add the following keys for camera and microphone usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video streaming.</string>
```

## Usage

### App.tsx or App.js

Import the WebView component and use it in your app:

```jsx
import WebView from 'react-native-webview';

// ...
 return (
    <SafeAreaView style={styles.container}>
      {!showWebView && (
        <Button title="Open WebView" onPress={toggleWebView} />
        
      )}
      {showWebView && (
        <WebView
          source={{ uri: `https://kineste-x-w.vercel.app?id=${userId}` }}
          style={styles.webView}
          allowsFullscreenVideo={true}
          mediaPlaybackRequiresUserAction={false}
          onMessage={handleMessage}
          javaScriptEnabled={true}
          originWhitelist={['*']}
          mixedContentMode="always"
          debuggingEnabled={true}
          allowFileAccessFromFileURLs={true}
          allowUniversalAccessFromFileURLs={true}
          allowsInlineMediaPlayback={true}
          geolocationEnabled={true}
        />
      )}
    </SafeAreaView>
  );
// ...
```

To include additional data, such as user ID, age, gender, and weight, update the `uri` prop as shown below:

```jsx
const userId = '123abcd'; // Replace this with the actual user ID from your data source
const age = 25; // Replace this with the actual age from your data source
const gender = 'male'; // Replace this with the actual gender from your data source
const weight = 70; // Replace this with the actual weight from your data source
const sub_category = 'Stay Fit'; // Replace this with the actual sub_category (You can pass multiple sub categories, 
//ex: sub_category = 'Stay Fit, Knee Therapy'
const category = 'Rehabilitation'; // Replace this with the actual category
const goals = 'Weight Management'; // Replace this with the actual goal 
// multiple goals ex:  goals = 'Weight Management, Mental Health'

<WebView
  source={{ uri: `https://myweb.vercel.app?userId=${userId}&age=${age}&gender=${gender}&weight=${weight}&sub_category=${sub_category}&category=$category}` }}
  // ...other WebView props
/>
```

### Handling the Exit Event

Add the following code to handle the exit event when the user clicks the exit button:

```jsx
 const handleMessage = (event: WebViewMessageEvent) => {
  try {
    const message = JSON.parse(event.nativeEvent.data);
    //finished the workout and now redirected to the all workouts section
    if (message.type === "finished_workout") {
      console.log("Received data:", message.data);
      // Process the received data as needed
     
    }
   
   
    if (message.type === "exitApp"){
      //clicked on exit, so handle the exit flow by removing WebView 
      toggleWebView();
    }
       if (message.type === "error_occured") {
       // saved workout data in case of an error that causes ui freeze
      console.log("Received data:", message.data);
      // close the webview 
          toggleWebView();
    }
    if (message.type === "exercise_completed") {
      // (Optional)
      // saved exercise data in case you want to cache the data of each exercise
      console.log("Received data:", message.data);
      // Example format: exercise: "Overhead Arms Raise", repeats: 20, timeSpent: 30, calories: 5.0
    }
  } catch (e) {
    console.error("Could not parse JSON message from WebView:", e);
  }
};

// ...
 return (
    <SafeAreaView style={styles.container}>
      {!showWebView && (
        <Button title="Open WebView" onPress={toggleWebView} />
        
      )}
      {showWebView && (
        <WebView
          source={{ uri: `https://kineste-x-w.vercel.app/?userId=${userId}` }}
          style={styles.webView}
          allowsFullscreenVideo={true}
          mediaPlaybackRequiresUserAction={false}
          onMessage={handleMessage}
          javaScriptEnabled={true}
          originWhitelist={['*']}
          mixedContentMode="always"
          debuggingEnabled={true}
          allowFileAccessFromFileURLs={true}
          allowUniversalAccessFromFileURLs={true}
          allowsInlineMediaPlayback={true}
          geolocationEnabled={true}
        />
      )}
    </SafeAreaView>
  );
// ...
```

All workout data will be sent when the user clicks the exit button. The data will also be stored in our database and can be made available to your app in real-time upon request (in case the user exited the flow incorrectly or something unexpected happened, we can discuss use cases)

Please note that some parts are under development and testing. Contact vladimir@kinestex.com to schedule a demo and try out a beta version of KinesteX. We would appreciate any feedback!
```
