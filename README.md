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
const userId = '12232dcdd'; // Replace this with the actual user ID from your data source
const age = 25; // Replace this with the actual age from your data source
const gender = 'male'; // Replace this with the actual gender from your data source
const weight = 70; // Replace this with the actual weight from your data source

<WebView
  source={{ uri: `https://myweb.vercel.app?userId=${userId}&age=${age}&gender=${gender}&weight=${weight}` }}
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

All workout data will be sent when the user clicks the exit button. The data will also be stored in our database and can be made available to your app in real-time upon request (in case the user exited the flow incorrectly or something unexpected happened, we can discuss use cases)

Please note that some parts are under development and testing. Contact vladimir@kinestex.com to schedule a demo and try out a beta version of KinesteX. We would appreciate any feedback!
```
