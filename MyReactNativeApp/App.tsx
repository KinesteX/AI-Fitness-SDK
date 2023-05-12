import React, { useState } from 'react';
import { Button, SafeAreaView, StyleSheet } from 'react-native';
import WebView, { WebViewMessageEvent } from 'react-native-webview';

const App = () => {
  const [showWebView, setShowWebView] = useState(false);

  const toggleWebView = () => {
    setShowWebView(!showWebView);
  };

  const userId = 'user1';

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
