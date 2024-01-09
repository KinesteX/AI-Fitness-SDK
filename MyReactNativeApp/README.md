https://github.com/V-m1r/KinesteXSDK/assets/62508191/a796a98c-55c4-42d5-8ecd-731d2997e488

This guide will walk you through the installation and configuration of the WebView component for integrating KinesteX plans and workouts into your app.

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
#### WebView library

Install `react-native-webview` webview:

```
npm i react-native-webview
```

### Available categories to sort plans (param key is planC): 

| **Plan Category (key: planC)** | 
| --- | 
| **Strength** | 
| **Cardio** |
| **Weight Management** | 
| **Rehabilitation** | 

Pleae note that the default plan category is Strength and all of the plans will be displayed under that category.


### Available categories and sub categories to sort workouts: 

| **Category (key: category)** | **Sub-category (key: sub_category)** |
| --- | --- |
| **Fitness** | Stay Fit, Stretching, Cardio |
| **Rehabilitation** | Back Relief, Knee Therapy, Neck Relief |


## Available parameters:
```jsx
  const postData = {
// REQUIRED
    userId: 'YOUR USER ID',
    company: 'YOUR COMPANY', // contact KinesteX
    key: apiKey, // STORE KEY SECURELY. WE RECOMMEND STORING AND RETRIEVING IT FROM YOUR DATABASE
// OPTIONAL
    category: 'Fitness',
    planC: 'Cardio',
    age: 50,
    height: 150, // in cm
    weight: 200, // in kg
    gender: 'Male'
  };
```
### Communicating with KinesteX:
Currently supported communication is via HTTP postMessages. 

When presenting webview, share the data in the following way: 

```jsx
const url = 'https://kinestex-sdk-git-redesign-v-m1r.vercel.app';

const sendPostData = () => {
  if (webViewRef.current) {
    const script = `
      window.postMessage(${JSON.stringify(postData)}, 'https://kinestex-sdk-git-redesign-v-m1r.vercel.app');
      true; // Note: true is required, or you'll sometimes get silent failures
    `;
    webViewRef.current.injectJavaScript(script);
  }
};
// sending message when webview loads:
<WebView
       ref={webViewRef}
       source={{ uri: url }}
       onLoadEnd={() => sendPostData()}
       originWhitelist={[url]}
       ... other config (see below)
     />

```


To listen to user events: 

  ```jsx
    const handleMessage = (event: WebViewMessageEvent) => {
  try {
    const message = JSON.parse(event.nativeEvent.data);

    if (message.type === "finished_workout") {
      console.log("Received data:", message.data);
      // Process the received data as needed
     
    }
    if (message.type === "exitApp"){
      console.log("EXITING: ", "EXIT");
      toggleWebView();
    }
  } catch (e) {
    console.error("Could not parse JSON message from WebView:", e);
  }
};

// adding listener to webview library:
return (
<WebView
       ref={webViewRef}
       source={{ uri: url }}
       onMessage={handleMessage}
       ... other configuration (see below)
     />
)
```
 **Message Types in handleMessage function**:
    The core of the `handleMessage` function is a switch statement that checks the `type` property of the parsed message. Each case corresponds to a different type of action or event that occurred in the KinesteX SDK.
    
   - `kinestex_launched`: Logs when the KinesteX SDK is successfully launched.
   - `workout_opened`: Logs when a workout is opened.
   - `workout_started`: Logs when a workout is started.
   - `plan_unlocked`: Logs when a user unlocks a plan.
   - `finished_workout`: Logs when a workout is finished.
  - `error_occured`: Logs when there's an error. (Coming soon)
   - `exercise_completed`: Logs when an exercise is completed.
  - `exitApp`: Logs when user clicks on exit button, triggering an exit message. The iframe should be hidden if this message is sent

------------------

## Displaying KinesteX through webview:
```jsx
  <WebView
       ref={webViewRef}
       source={{ uri: url }}
       style={styles.webView}
       allowsFullscreenVideo={true}
       mediaPlaybackRequiresUserAction={false}
       onMessage={handleMessage}
       javaScriptEnabled={true}
       onLoadEnd={() => sendPostData()}
       originWhitelist={[url]}
       mixedContentMode="always"
       allowFileAccessFromFileURLs={true}
       allowUniversalAccessFromFileURLs={true}
       allowsInlineMediaPlayback={true}
     />
```
See App.tsx for demo code

------------------

## Contact:
If you have any questions contact: help@kinestex.com
