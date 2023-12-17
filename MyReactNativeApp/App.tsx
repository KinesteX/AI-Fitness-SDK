import React, { useState, useRef } from 'react';
import { Button, SafeAreaView, StyleSheet } from 'react-native';
import WebView, { WebViewMessageEvent } from 'react-native-webview';

const App = () => {
  const [showWebView, setShowWebView] = useState(false);
  const webViewRef = useRef(null);
  const toggleWebView = () => {
    setShowWebView(!showWebView);
  };

  const url = 'https://kinestex-sdk-git-redesign-v-m1r.vercel.app/';

  const postData = {
    userId: 'userrrrabc',
    category: 'Fitness',
    planC: 'Strength',
    company: 'YOUR COMPANY NAME',
    key: 'YOUR COMPANY CODE',
    age: 50,
    height: 150, // in cm
    weight: 200,
    gender: 'Male'
  };

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

const sendPostData = () => {
  if (webViewRef.current) {
    const script = `
      window.postMessage(${JSON.stringify(postData)}, 'https://kinestex-sdk-git-redesign-v-m1r.vercel.app');
      true; // Note: true is required, or you'll sometimes get silent failures
    `;
    webViewRef.current.injectJavaScript(script);
  }
};
  return (
    <SafeAreaView style={styles.container}>
      {!showWebView && (
        <Button title="Open WebView" onPress={toggleWebView} />
        
      )}
      {showWebView && (
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
       debuggingEnabled={true} // remove for production release
       allowFileAccessFromFileURLs={true}
       allowUniversalAccessFromFileURLs={true}
       allowsInlineMediaPlayback={true}
     />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  webView: {
    flex: 1,
  },
});

export default App;
