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
<WebView
  source={{ uri: 'https://kineste-x-w.vercel.app' }}
  style={styles.webView}
  allowsFullscreenVideo={true}
  mediaPlaybackRequiresUserAction={false}
  onMessage={(event) => {
    if (event.nativeEvent.data === 'close') {
      toggleWebView();
    }
  }}
  javaScriptEnabled={true}
  mixedContentMode="always"
  allowFileAccessFromFileURLs={true}
  allowUniversalAccessFromFileURLs={true}
  allowsInlineMediaPlayback={true}
  geolocationEnabled={true}
/>
// ...
```

To include additional data, such as user ID, age, gender, and weight, update the `uri` prop as shown below:

```jsx
const userId = '12232dcdd'; // Replace this with the actual user ID from your data source
const age = 25; // Replace this with the actual age from your data source
const gender = 'male'; // Replace this with the actual gender from your data source
const weight = 70; // Replace this with the actual weight from your data source

<WebView
  source={{ uri: `https://myweb.vercel.app?id=${userId}&age=${age}&gender=${gender}&weight=${weight}` }}
  // ...other WebView props
/>
```

### Handling the Exit Event

Add the following code to handle the exit event when the user clicks the exit button:

```jsx
const handleMessage = (event) => {
  const message = JSON.parse(event.nativeEvent.data);

  if (message.type === "exit") {
    console.log("Received data:", message.data);
    // Process the received data as needed
    toggleWebView();
  }
};

// ...
<WebView
  source={{ uri: 'https://kineste-x-w.vercel.app' }}
  style={styles.webView}
  allowsFullscreenVideo={true}
  mediaPlaybackRequiresUserAction={false}
  onMessage={handleMessage}
  // ...other props
/>
// ...
```

All workout data will be sent when the user clicks the exit button. The data will also be stored in our database and made available to your app in real-time.

Please note that some parts are under development and testing. Contact vladimir@kinestex.com to schedule a demo and try out a beta version of KinesteX. We would appreciate any feedback!
```
