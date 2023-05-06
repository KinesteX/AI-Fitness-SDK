install webview: 
npm install react-native-webview
Configure AndroidManifest.xml for camera usage:
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />

and Info.plist: 
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video streaming.</string>

In your App.tsx or App.js: 
import WebView from 'react-native-webview';
  ...
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
      )}
    </SafeAreaView>
...

This will display the window with all the workouts that we offer. You will be able 
to view the description of the workout and then start it. We're working on adding a 
communication point between Super App and KinesteX, and as I see it, it will be happening 
through the initialization in the link as a query parameter, like this: 
const userId = '12232dcdd'; // Replace this with the actual user ID from
your data source

<WebView
  source={{ uri: `https://myweb.vercel.app?id=${userId}` }}
  // ...other WebView props
/>

And other optional data: 
const userId = '12232dcdd'; // Replace this with the actual user ID from your data source
const age = 25; // Replace this with the actual age from your data source
const gender = 'male'; // Replace this with the actual gender from your data source
const weight = 70; // Replace this with the actual weight from your data source

<WebView
  source={{
    uri: `https://myweb.vercel.app?id=${userId}&age=${age}&gender=${gender}&weight=${weight}`,
  }}
  // ...other WebView props
/>

Once the training finishes or the user clicks on the exit button, a statistics window
will popup, showing the progress to the user with an option to finish.
When the user clicks on finish, we will show a short survey and we will post the exit handler on our side: 
//on our side
exitButton.addEventListener("click", () => {
  const message = {
    type: "exit",
    data: dataToSend,
  };

  window.ReactNativeWebView.postMessage(JSON.stringify(message));
});

// And you will need to handle exit in your app: 
const handleMessage = (event) => {
  const message = JSON.parse(event.nativeEvent.data);

  if (message.type === "exit") {

    console.log("Received data:", message.data);
    // Process the received data as needed
    toggleWebView();
  }
};

....
 <WebView
          source={{ uri: 'https://kineste-x-w.vercel.app' }}
          style={styles.webView}
          allowsFullscreenVideo={true}
          mediaPlaybackRequiresUserAction={false}
          onMessage={handleMessage}
         ... //other props
        />
..
All data from the workout is gonna be sent when the user clicks on exit button. 
And we will also store it on our database and will have it available 
for your app in real-time.
Please note that some parts are under development and testing. Contact vladimir@kinestex.com to schedule a demo and try out a beta version of KinesteX 
We would appreciate any feedback!
 
